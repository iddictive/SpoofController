import Cocoa
import Foundation

final class DPIKillerManager {
    static let shared = DPIKillerManager()

    private(set) var process: Process?
    private var installProcess: Process?
    private(set) var isRunning = false
    private let maintenanceQueue = DispatchQueue(label: "com.iddictive.dpikiller.maintenance", qos: .utility)
    private let cleanupLock = NSLock()
    private var hasPerformedCleanup = false
    private var outputPipe: Pipe?
    private var watchdogTimer: DispatchSourceTimer?
    private var highCpuStrikes = 0
    private let maxStrikes = 5
    private let cpuThreshold = 400.0
    private let watchdogInterval: UInt64 = 30
    private var lastRestartTime: Date?
    private let restartCooldown: TimeInterval = 300
    private var wasRunningBeforeDisconnect = false
    private var shouldRestoreAfterDisconnect = false
    private var isConnectivityRestartInProgress = false

    init() {
        NetworkMonitor.shared.onConnectivityLost = { [weak self] in
            guard let self = self else { return }
            let wasActive = self.isRunning || self.process?.isRunning == true || self.wasRunningBeforeDisconnect
            guard wasActive else { return }
            self.shouldRestoreAfterDisconnect = true
            AppLogger.log("[Manager] Connectivity lost while spoofdpi was active. Marked for auto-restore.")
        }

        NetworkMonitor.shared.onConnectivityRestored = { [weak self] in
            guard let self = self else { return }
            guard SettingsStore.shared.autoReconnect, self.shouldRestoreAfterDisconnect else { return }
            guard !self.isConnectivityRestartInProgress else {
                AppLogger.log("[Manager] Connectivity restore is already in progress. Skipping duplicate restart.")
                return
            }
            self.isConnectivityRestartInProgress = true
            DispatchQueue.main.async {
                AppLogger.log("[Manager] Auto-restarting after network restoration...")
                self.restartAfterConnectivityRestoration { success, error in
                    if success {
                        AppLogger.log("[Manager] Auto-restart success.")
                    } else {
                        AppLogger.log("[Manager] Auto-restart failed: \(error ?? "unknown")")
                    }
                    self.isConnectivityRestartInProgress = false
                    (NSApp.delegate as? AppDelegate)?.refreshUI()
                }
            }
        }
        NetworkMonitor.shared.start()
    }

    func start(completion: @escaping (Bool, String?) -> Void) {
        if isRunning {
            stop()
        }
        killOrphans()
        isRunning = false
        wasRunningBeforeDisconnect = true
        shouldRestoreAfterDisconnect = false

        let binaryPath = SettingsStore.shared.binaryPath
        AppLogger.log("[Manager] Starting with binary: \(binaryPath)")
        guard FileManager.default.fileExists(atPath: binaryPath) else {
            completion(false, "NOT_INSTALLED")
            return
        }
        if SettingsStore.shared.disableIpv6 {
            SettingsStore.shared.applyIpv6Preference()
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: binaryPath)
        process.arguments = SettingsStore.shared.customArgs
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        let pipe = Pipe()
        outputPipe = pipe
        process.standardOutput = pipe
        process.standardError = pipe

        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.isEmpty {
                handle.readabilityHandler = nil
                return
            }
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                let shouldStore = LogStore.shared.shouldCaptureProcessLogs()
                    || SettingsStore.shared.selectedFlags.contains("--debug")
                if shouldStore {
                    LogStore.shared.append(str)
                }
            }
        }

        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.outputPipe?.fileHandleForReading.readabilityHandler = nil
                self?.outputPipe = nil
                self?.isRunning = false
                self?.process = nil
                self?.stopWatchdog()
                (NSApp.delegate as? AppDelegate)?.refreshUI()
            }
        }

        do {
            try process.run()
            self.process = process
            self.isRunning = true
            startWatchdog()
            completion(true, nil)
        } catch {
            self.isRunning = false
            completion(false, error.localizedDescription)
        }
    }

    func install(completion: @escaping (Bool, String?) -> Void) {
        let brewPaths = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
        let brewPath = brewPaths.first { FileManager.default.fileExists(atPath: $0) }

        let process = Process()
        if let brewPath {
            process.executableURL = URL(fileURLWithPath: brewPath)
            process.arguments = ["install", "spoofdpi"]
        } else {
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-c", "curl -fsSL https://raw.githubusercontent.com/xvzc/spoofdpi/main/install.sh | bash"]
        }

        installProcess = process

        do {
            try process.run()
            process.terminationHandler = { [weak self] proc in
                DispatchQueue.main.async {
                    self?.installProcess = nil
                    if proc.terminationStatus == 0 {
                        completion(true, nil)
                    } else {
                        completion(false, "Installation failed with exit code \(proc.terminationStatus)")
                    }
                }
            }
        } catch {
            installProcess = nil
            completion(false, error.localizedDescription)
        }
    }

    func cancelInstall() {
        installProcess?.terminate()
        installProcess = nil
    }

    func stop() {
        isRunning = false
        wasRunningBeforeDisconnect = false
        shouldRestoreAfterDisconnect = false
        isConnectivityRestartInProgress = false
        stopWatchdog()
        outputPipe?.fileHandleForReading.readabilityHandler = nil
        outputPipe = nil
        process?.terminate()
        process = nil
        killOrphans()
        disableSystemProxy()
        (NSApp.delegate as? AppDelegate)?.refreshUI()
    }

    func fullCleanup() {
        cleanupLock.lock()
        if hasPerformedCleanup {
            cleanupLock.unlock()
            return
        }
        hasPerformedCleanup = true
        cleanupLock.unlock()

        AppLogger.log("[Manager] Performing full cleanup...")
        stop()
        SettingsStore.shared.restoreIpv6Defaults()
    }

    func recoverEnvironment(completion: (() -> Void)? = nil) {
        maintenanceQueue.async {
            AppLogger.log("[Manager] Recovering environment after previous run...")
            self.killOrphans()
            self.disableSystemProxy()
            SettingsStore.shared.restoreIpv6Defaults()
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    private func startWatchdog() {
        stopWatchdog()
        highCpuStrikes = 0
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .utility))
        timer.schedule(deadline: .now() + .seconds(Int(watchdogInterval)), repeating: .seconds(Int(watchdogInterval)))
        timer.setEventHandler { [weak self] in
            self?.checkCPU()
        }
        timer.resume()
        watchdogTimer = timer
    }

    private func stopWatchdog() {
        watchdogTimer?.cancel()
        watchdogTimer = nil
        highCpuStrikes = 0
    }

    private func getCPUUsage() -> Double? {
        guard let proc = process, proc.isRunning else { return nil }
        let pid = proc.processIdentifier
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-p", "\(pid)", "-o", "%cpu="]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               let cpu = Double(output) {
                return cpu
            }
        } catch {}
        return nil
    }

    private func checkCPU() {
        guard isRunning, let cpu = getCPUUsage() else {
            highCpuStrikes = 0
            return
        }
        if cpu > cpuThreshold {
            highCpuStrikes += 1
            AppLogger.log("[Watchdog] High CPU detected: \(cpu)% (strike \(highCpuStrikes)/\(maxStrikes))")
            if highCpuStrikes >= maxStrikes {
                AppLogger.log("[Watchdog] CPU threshold exceeded for \(highCpuStrikes) consecutive checks. Auto-restarting spoofdpi...")
                DispatchQueue.main.async { [weak self] in
                    self?.restartDueToHighCPU()
                }
            }
        } else {
            if highCpuStrikes > 0 {
                AppLogger.log("[Watchdog] CPU back to normal: \(cpu)%. Resetting strikes.")
            }
            highCpuStrikes = 0
        }
    }

    private func restartDueToHighCPU() {
        if let lastRestart = lastRestartTime, Date().timeIntervalSince(lastRestart) < restartCooldown {
            AppLogger.log("[Watchdog] Cooldown active, skipping restart.")
            return
        }

        lastRestartTime = Date()
        highCpuStrikes = 0
        stopWatchdog()
        process?.terminate()
        process = nil
        isRunning = false
        killOrphans()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.start { success, error in
                if success {
                    AppLogger.log("[Watchdog] spoofdpi restarted successfully.")
                } else {
                    AppLogger.log("[Watchdog] Failed to restart spoofdpi: \(error ?? "unknown error")")
                }
                (NSApp.delegate as? AppDelegate)?.refreshUI()
            }
        }
    }

    private func restartAfterConnectivityRestoration(completion: @escaping (Bool, String?) -> Void) {
        shouldRestoreAfterDisconnect = false
        highCpuStrikes = 0
        stopWatchdog()
        outputPipe?.fileHandleForReading.readabilityHandler = nil
        outputPipe = nil
        process?.terminate()
        process = nil
        isRunning = false
        killOrphans()
        disableSystemProxy()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.start(completion: completion)
        }
    }

    private func killOrphans() {
        let killer = Process()
        killer.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        killer.arguments = ["-9", "spoofdpi"]
        try? killer.run()
        killer.waitUntilExit()
    }

    func disableSystemProxy() {
        let script = "services=$(networksetup -listallnetworkservices | grep -v '*'); while IFS= read -r service; do networksetup -setwebproxystate \"$service\" off 2>/dev/null; networksetup -setsecurewebproxystate \"$service\" off 2>/dev/null; done <<< \"$services\""
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", script]
        try? process.run()
        process.waitUntilExit()
    }
}
