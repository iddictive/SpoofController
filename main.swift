import Cocoa
import Foundation
import WebKit
import Network

// MARK: - Localization
struct L10n {
    static let shared = L10n()
    let isRussian: Bool
    
    init() {
        let lang = Locale.preferredLanguages.first ?? "en"
        self.isRussian = lang.hasPrefix("ru")
    }
    
    // Menu
    var statusActive: String { isRussian ? "Статус: АКТИВЕН ✅" : "Status: ACTIVE ✅" }
    var statusStopped: String { isRussian ? "Статус: ОСТАНОВЛЕН ❌" : "Status: STOPPED ❌" }
    var start: String { isRussian ? "Запустить" : "Start" }
    var stop: String { isRussian ? "Остановить" : "Stop" }
    var settings: String { isRussian ? "Настройки..." : "Settings..." }
    var logs: String { isRussian ? "Логи" : "Logs" }
    var instructions: String { isRussian ? "Инструкции" : "Instructions" }
    var helpTitle: String { isRussian ? "Инструкция по использованию" : "User Guide & Instructions" }
    var quit: String { isRussian ? "Выйти" : "Quit" }
    
    // Settings Window
    var settingsTitle: String { isRussian ? "Расширенные настройки" : "Advanced Settings" }
    var binaryPath: String { isRussian ? "Путь к бинарнику:" : "Binary Path:" }
    var binaryPlaceholder: String { isRussian ? "Например: /opt/homebrew/bin/spoofdpi" : "e.g. /opt/homebrew/bin/spoofdpi" }
    var argumentsTitle: String { isRussian ? "Аргументы (флаги):" : "Arguments (Flags):" }
    var manualArgsTitle: String { isRussian ? "Доп. аргументы:" : "Manual Arguments:" }
    var manualArgsPlaceholder: String { isRussian ? "-p 8080 -window-size 10" : "-p 8080 -window-size 10" }
    var autoLaunchTitle: String { isRussian ? "Автозагрузка:" : "Auto Launch:" }
    var launchAtLogin: String { isRussian ? "Запускать при старте системы" : "Launch at system startup" }
    var saveAndRestart: String { isRussian ? "Сохранить и Перезапустить" : "Save & Restart" }
    
    // Advanced App Settings
    var ttlTitle: String { isRussian ? "TTL пакетов:" : "Packet TTL:" }
    var ttlPlaceholder: String { isRussian ? "По умолч: 64" : "Default: 64" }
    var ttlInstruction: String { isRussian ? "Помогает обходить некоторые типы DPI." : "Helps bypass certain DPI types." }
    var splitModeTitle: String { isRussian ? "Режим разделения (Split Mode):" : "HTTPS Split Mode:" }
    var splitInstruction: String { isRussian ? "sni, random, chunk или none." : "sni, random, chunk or none." }
    var httpsDisorder: String { isRussian ? "Перемешивание (Disorder):" : "HTTPS Disorder:" }
    var httpsFakeCount: String { isRussian ? "Фейковые пакеты (Fake Count):" : "HTTPS Fake Count:" }
    var httpsChunkSize: String { isRussian ? "Размер чанка (Chunk Size):" : "HTTPS Chunk Size:" }
    var httpsChunkPlaceholder: String { isRussian ? "По умолч: 0" : "Default: 0" }
    var mobilePresetTitle: String { isRussian ? "Оптимизировать для хотспота (iPhone/Android)" : "Optimize for Mobile Hotspot (iPhone/Android)" }
    
    var portTitle: String { isRussian ? "Локальный порт:" : "Local Port:" }
    var portPlaceholder: String { isRussian ? "По умолч: 8080" : "Default: 8080" }

    var hotspotStatusTitle: String { isRussian ? "Состояние хотспота:" : "Hotspot Status:" }
    var hotspotStatusOptimized: String { isRussian ? "Оптимизировано ✅" : "Optimized ✅" }
    var hotspotStatusThrottled: String { isRussian ? "Ограничено провайдером ⚠️" : "Throttled by ISP ⚠️" }
    var fixHotspotButton: String { isRussian ? "Снять ограничения (Sudo)" : "Remove Limits (Sudo)" }
    var fixHotspotSuccess: String { isRussian ? "Настройки TTL успешно применены! 🚀" : "TTL settings applied successfully! 🚀" }
    var fixHotspotFailed: String { isRussian ? "Не удалось применить настройки." : "Failed to apply settings." }
    
    var dnsTitle: String { isRussian ? "Настройки DNS:" : "DNS Settings:" }
    var dnsAddrTitle: String { isRussian ? "DNS Адрес:" : "DNS Address:" }
    var dnsModeTitle: String { isRussian ? "Режим DNS:" : "DNS Mode:" }
    var dnsHttpsTitle: String { isRussian ? "DoH URL:" : "DoH URL:" }

    
    // Flag Descriptions
    var descSystemProxy: String { isRussian ? "Использовать системный прокси" : "Use system-wide proxy" }
    var descSilent: String { isRussian ? "Скрыть баннер при запуске" : "Suppress startup banner" }
    var descIpv4Only: String { isRussian ? "Только IPv4 для DNS" : "IPv4 only for DNS" }
    var descDebug: String { isRussian ? "Режим отладки (info/debug)" : "Debug mode (info/debug)" }
    var descPolicyAuto: String { isRussian ? "Авто-детект заблокированных сайтов" : "Auto-detect blocked sites" }
    
    // Alerts/Installer
    var dependencyMissing: String { isRussian ? "Отсутствует зависимость" : "Dependency Missing" }
    var spoofDpiNeeded: String { isRussian ? "SpoofDPI не установлен. Установить через Homebrew?" : "SpoofDPI is not installed. Install via Homebrew?" }
    var install: String { isRussian ? "Установить" : "Install" }
    var installing: String { isRussian ? "Установка..." : "Installing..." }
    var pleaseWaitBrew: String { isRussian ? "Пожалуйста, подождите. Установка через brew может занять минуту." : "Please wait while we install spoofdpi via brew. This might take a minute." }
    var installComplete: String { isRussian ? "Установка завершена" : "Installation Complete" }
    var installSuccess: String { isRussian ? "SpoofDPI успешно установлен. Запуск сервиса..." : "SpoofDPI has been installed successfully. Starting service..." }
    var installFailed: String { isRussian ? "Ошибка установки" : "Installation Failed" }
    var installManual: String { isRussian ? "Неизвестная ошибка. Установите вручную: 'brew install spoofdpi'" : "Unknown error. Please install manually: 'brew install spoofdpi'" }
    var failedToStart: String { isRussian ? "Не удалось запустить" : "Failed to start" }
    var preparingBypass: String { isRussian ? "Подготовка обхода... ⚡️" : "Preparing your bypass... ⚡️" }
    var cancel: String { isRussian ? "Отмена" : "Cancel" }
    
    // Updates
    var updateCheck: String { isRussian ? "Проверить обновления..." : "Check for Updates..." }
    var updateChecking: String { isRussian ? "Проверка обновлений..." : "Checking for updates..." }
    var updateAvailable: String { isRussian ? "Доступно обновление" : "Update Available" }
    var updateLatest: String { isRussian ? "У вас установлена последняя версия." : "You are on the latest version." }
    var updateFound: String { isRussian ? "Доступна новая версия %@. Хотите обновиться?" : "A new version %@ is available. Would you like to update?" }
    var updateDownload: String { isRussian ? "Скачать и установить" : "Download & Install" }
    var updateLater: String { isRussian ? "Позже" : "Later" }
    var updateDownloading: String { isRussian ? "Загрузка обновления..." : "Downloading update..." }
    var updateInstalling: String { isRussian ? "Установка обновления..." : "Installing update..." }
    var updateFailed: String { isRussian ? "Ошибка обновления" : "Update Failed" }
    var autoUpdateTitle: String { isRussian ? "Обновления:" : "Updates:" }
    var autoUpdateToggle: String { isRussian ? "Автоматически проверять обновления" : "Automatically check for updates" }
    var autoDownloadToggle: String { isRussian ? "Автоматически скачивать обновления" : "Automatically download updates" }
    
    // Speed Test
    var speedTest: String { isRussian ? "Тест скорости" : "Speed Test" }
    var speedTestTitle: String { isRussian ? "Тестирование скорости" : "Speed Testing" }
    var startTest: String { isRussian ? "Начать тест" : "Start Test" }
    var stopTest: String { isRussian ? "Остановить" : "Stop Test" }
    var testingDownload: String { isRussian ? "Загрузка..." : "Downloading..." }
    var testingUpload: String { isRussian ? "Отдача..." : "Uploading..." }
    var testingPing: String { isRussian ? "Пинг..." : "Ping..." }
    var ping: String { isRussian ? "Пинг" : "Ping" }
    var download: String { isRussian ? "Загрузка" : "Download" }
    var upload: String { isRussian ? "Отдача" : "Upload" }
    var ms: String { isRussian ? "мс" : "ms" }
    var mbps: String { isRussian ? "Мбит/с" : "Mbps" }
    
    // Logs
    var logsTitle: String { isRussian ? "Логи событий" : "Event Logs" }
    var clearLogs: String { isRussian ? "Очистить" : "Clear" }
    var copyLogs: String { isRussian ? "Копировать" : "Copy" }
    
    // Diagnostics
    var diagTitle: String { isRussian ? "Диагностика связи" : "Connectivity Diagnostics" }
    var diagChecking: String { isRussian ? "Проверка..." : "Checking..." }
    var diagSuccess: String { isRussian ? "Обход работает! ✅" : "Bypass is working! ✅" }
    var diagFailed: String { isRussian ? "Обход не работает ❌" : "Bypass is failing ❌" }
    var diagNoProxy: String { isRussian ? "Прокси не запущен" : "Proxy is not running" }
    
    // IPv6
    var disableIpv6: String { isRussian ? "Отключить IPv6 (рекомендуется)" : "Disable IPv6 (recommended)" }
    var ipv6Warning: String { isRussian ? "Предотвращает утечки трафика мимо прокси." : "Prevents traffic leakage bypassing the proxy." }
}

// MARK: - Log Store (Circular Buffer)
class LogStore {
    static let shared = LogStore()
    private let maxLines = 1000
    private(set) var lines: [String] = []
    var onUpdate: (() -> Void)?
    
    private let queue = DispatchQueue(label: "com.iddictive.logstore", qos: .utility)
    
    // Throttling fields
    private var lastUpdate: Date = .distantPast
    private let throttleInterval: TimeInterval = 0.2 // 5Hz max refresh
    private var updatePending = false
    
    func append(_ text: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let newLines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
            if newLines.isEmpty { return }
            
            let timestamp = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withTime, .withColonSeparatorInTime])
            
            for line in newLines {
                self.lines.append("[\(timestamp)] \(line)")
            }
            
            if self.lines.count > self.maxLines {
                self.lines.removeFirst(self.lines.count - self.maxLines)
            }
            
            self.scheduleUpdate()
        }
    }

    private func scheduleUpdate() {
        dispatchPrecondition(condition: .onQueue(queue))
        
        guard !updatePending else { return }
        
        let now = Date()
        let timeSinceLast = now.timeIntervalSince(lastUpdate)
        
        if timeSinceLast >= throttleInterval {
            self.lastUpdate = now
            DispatchQueue.main.async { [weak self] in
                self?.onUpdate?()
                self?.queue.async { self?.updatePending = false }
            }
            updatePending = true
        } else {
            updatePending = true
            let delay = throttleInterval - timeSinceLast
            queue.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.lastUpdate = Date()
                DispatchQueue.main.async { [weak self] in
                    self?.onUpdate?()
                    self?.queue.async { self?.updatePending = false }
                }
            }
        }
    }
    
    func clear() {
        queue.async {
            self.lines.removeAll()
            DispatchQueue.main.async {
                self.onUpdate?()
            }
        }
    }
    
    func getAllLogs() -> String {
        return queue.sync {
            self.lines.joined(separator: "\n")
        }
    }
}

// MARK: - Settings Store
class SettingsStore {
    static let shared = SettingsStore()
    private let defaults = UserDefaults.standard
    
    var binaryPath: String {
        get { defaults.string(forKey: "binaryPath") ?? autoDetectBinaryPath() }
        set { defaults.set(newValue, forKey: "binaryPath") }
    }
    
    var customArgs: String {
        get { defaults.string(forKey: "customArgs") ?? "--system-proxy" }
        set { defaults.set(newValue, forKey: "customArgs") }
    }
    
    var defaultTTL: String {
        get { defaults.string(forKey: "defaultTTL") ?? "128" }
        set { defaults.set(newValue, forKey: "defaultTTL") }
    }
    
    var splitMode: String {
        get { defaults.string(forKey: "splitMode") ?? "random" }
        set { defaults.set(newValue, forKey: "splitMode") }
    }
    
    var httpsDisorder: Bool {
        get { defaults.object(forKey: "httpsDisorder") == nil ? true : defaults.bool(forKey: "httpsDisorder") }
        set { defaults.set(newValue, forKey: "httpsDisorder") }
    }
    
    var httpsFakeCount: String {
        get { defaults.string(forKey: "httpsFakeCount") ?? "0" }
        set { defaults.set(newValue, forKey: "httpsFakeCount") }
    }
    
    var httpsChunkSize: String {
        get { defaults.string(forKey: "httpsChunkSize") ?? "20" }
        set { defaults.set(newValue, forKey: "httpsChunkSize") }
    }
    
    var localPort: String {
        get { defaults.string(forKey: "localPort") ?? "8080" }
        set { defaults.set(newValue, forKey: "localPort") }
    }

    var dnsAddr: String {
        get { defaults.string(forKey: "dnsAddr") ?? "8.8.8.8:53" }
        set { defaults.set(newValue, forKey: "dnsAddr") }
    }

    var dnsMode: String {
        get { defaults.string(forKey: "dnsMode") ?? "udp" }
        set { defaults.set(newValue, forKey: "dnsMode") }
    }

    var dnsHttpsUrl: String {
        get { defaults.string(forKey: "dnsHttpsUrl") ?? "https://dns.google/dns-query" }
        set { defaults.set(newValue, forKey: "dnsHttpsUrl") }
    }
    
    var autoUpdate: Bool {
        get { defaults.object(forKey: "autoUpdate") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "autoUpdate") }
    }
    
    var autoDownload: Bool {
        get { defaults.object(forKey: "autoDownload") as? Bool ?? false }
        set { defaults.set(newValue, forKey: "autoDownload") }
    }
    
    var disableIpv6: Bool {
        get { defaults.bool(forKey: "disableIpv6") }
        set { 
            defaults.set(newValue, forKey: "disableIpv6")
            applyIpv6Settings(newValue)
        }
    }
    
    private func applyIpv6Settings(_ disable: Bool) {
        let state = disable ? "off" : "on"
        let script = "services=$(networksetup -listallnetworkservices | grep -v '*'); while IFS= read -r service; do networksetup -setv6\(state) \"$service\" 2>/dev/null; done <<< \"$services\""
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", script]
        try? process.run()
    }
    
    var selectedFlags: Set<String> {
        let args = customArgs.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        return Set(args.filter { $0.hasPrefix("-") && !$0.hasPrefix("--default-ttl") && !$0.hasPrefix("--https-chunk-size") && !$0.hasPrefix("--https-fake-count") && !$0.hasPrefix("--listen-addr") && !$0.hasPrefix("--dns-addr") && !$0.hasPrefix("--dns-mode") && !$0.hasPrefix("--dns-https-url") && !$0.hasPrefix("--https-split-mode") })
    }
    
    func updateArgs(with flags: Set<String>, manual: String, ttl: String, splitMode: String, splitPos: String, port: String, dnsAddr: String, dnsMode: String, dnsHttpsUrl: String) {
        var uniqueFlags = flags.joined(separator: " ")
        if let ttlInt = Int(ttl), ttlInt > 0 {
            uniqueFlags += " --default-ttl \(ttlInt)"
        }
        
        if !splitMode.isEmpty && splitMode != "sni" {
            uniqueFlags += " --https-split-mode \(splitMode)"
        }
        
        if let fakeCount = Int(SettingsStore.shared.httpsFakeCount), fakeCount > 0 {
            uniqueFlags += " --https-fake-count \(fakeCount)"
        }
        
        if let chunkSize = Int(SettingsStore.shared.httpsChunkSize), chunkSize > 0 {
            uniqueFlags += " --https-chunk-size \(chunkSize)"
        }
        
        if SettingsStore.shared.httpsDisorder {
            uniqueFlags += " --https-disorder"
        }
        
        let portToUse = port.trimmingCharacters(in: .whitespaces)
        if !portToUse.isEmpty && portToUse != "8080" {
            uniqueFlags += " --listen-addr 127.0.0.1:\(portToUse)"
        }

        if !dnsAddr.isEmpty && dnsAddr != "8.8.8.8:53" {
            uniqueFlags += " --dns-addr \(dnsAddr)"
        }

        if !dnsMode.isEmpty && dnsMode != "udp" {
            uniqueFlags += " --dns-mode \(dnsMode)"
        }

        if dnsMode == "https" && !dnsHttpsUrl.isEmpty && dnsHttpsUrl != "https://dns.google/dns-query" {
            uniqueFlags += " --dns-https-url \(dnsHttpsUrl)"
        }
        
        // Strict filtering for manual arguments
        let manualParts = manual.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        var cleanedParts: [String] = []
        var i = 0
        while i < manualParts.count {
            let part = manualParts[i]
            if part == "--default-ttl" || part == "--https-split-mode" || part == "--https-split-pos" || part == "--listen-addr" || part == "--dns-addr" || part == "--dns-mode" || part == "--dns-https-url" {
                i += 2 // Skip flag and value
            } else if flags.contains(part) {
                i += 1 // Skip known flag
            } else if Int(part) != nil {
                i += 1 
            } else {
                cleanedParts.append(part)
                i += 1
            }
        }
        customArgs = "\(uniqueFlags) \(cleanedParts.joined(separator: " "))".trimmingCharacters(in: .whitespaces)
    }
    
    var launchAtLogin: Bool {
        get { defaults.bool(forKey: "launchAtLogin") }
        set {
            defaults.set(newValue, forKey: "launchAtLogin")
            toggleLaunchAtLogin(newValue)
        }
    }
    
    private func toggleLaunchAtLogin(_ enabled: Bool) {
        let appPath = Bundle.main.bundlePath
        let script: String
        if enabled {
            script = "tell application \"System Events\" to make login item at end with properties {path:\"\(appPath)\", hidden:false, name:\"DPI Killer\"}"
        } else {
            script = "tell application \"System Events\" to delete (every login item whose name is \"DPI Killer\")"
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        try? process.run()
    }
    
    private func autoDetectBinaryPath() -> String {
        let bundlePath = Bundle.main.path(forResource: "spoofdpi-binary", ofType: nil, inDirectory: "MacOS")
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        let paths = [
            bundlePath,
            "/opt/homebrew/bin/spoofdpi",
            "/usr/local/bin/spoofdpi",
            "/usr/bin/spoofdpi",
            "\(homeDir)/.spoof-dpi/bin/spoofdpi",
            "\(homeDir)/.spoof-dpi/bin/spoof-dpi"
        ].compactMap { $0 }
        for path in paths {
            if FileManager.default.fileExists(atPath: path) { return path }
        }
        return "spoofdpi" // Fallback to PATH
    }
}

// MARK: - GitHub Auto-Update
class GitHubUpdater {
    static let shared = GitHubUpdater()
    private let repo = "iddictive/DPI-Killer"
    private let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private var isChecking = false
    private var downloadTask: URLSessionDownloadTask?
    private var observation: NSKeyValueObservation?

    func checkForUpdates(manual: Bool = false) {
        if !manual && !SettingsStore.shared.autoUpdate { return }
        guard !isChecking else { return }
        isChecking = true
        
        let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("DPIKillerUpdater", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isChecking = false }
            guard let data = data, error == nil else { 
                if manual {
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = L10n.shared.updateFailed
                        alert.informativeText = error?.localizedDescription ?? "Network error."
                        alert.runModal()
                    }
                }
                return 
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let tagName = json["tag_name"] as? String {
                    
                    let latestVersion = tagName.replacingOccurrences(of: "v", with: "")
                    if self?.compareVersions(current: self?.currentVersion ?? "", latest: latestVersion) == true {
                        let assets = json["assets"] as? [[String: Any]]
                        let dmgAsset = assets?.first(where: { ($0["name"] as? String)?.hasSuffix(".dmg") == true })
                        let downloadUrl = dmgAsset?["browser_download_url"] as? String
                        
                        DispatchQueue.main.async {
                            if !manual && SettingsStore.shared.autoDownload, let dlUrl = downloadUrl, let url = URL(string: dlUrl) {
                                self?.startAutomatedUpdate(url: url)
                            } else {
                                self?.showUpdateAlert(version: latestVersion, downloadUrl: downloadUrl)
                            }
                        }
                    } else if manual {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = L10n.shared.updateLatest
                            alert.runModal()
                        }
                    }
                }
            } catch {
                print("Update check error: \(error)")
            }
        }.resume()
    }

    private func compareVersions(current: String, latest: String) -> Bool {
        return latest.compare(current, options: .numeric) == .orderedDescending
    }

    private func showUpdateAlert(version: String, downloadUrl: String?) {
        let alert = NSAlert()
        alert.messageText = L10n.shared.updateAvailable
        alert.informativeText = String(format: L10n.shared.updateFound, version)
        alert.addButton(withTitle: L10n.shared.updateDownload)
        alert.addButton(withTitle: L10n.shared.updateLater)
        
        NSApp.activate(ignoringOtherApps: true)
        // Find the most appropriate window to show the sheet on
        let parentWindow = (NSApp.delegate as? AppDelegate)?.loadingWindow?.window ?? 
                          (NSApp.delegate as? AppDelegate)?.settingsWindow?.window
        
        if let window = parentWindow {
            alert.beginSheetModal(for: window) { response in
                if response == .alertFirstButtonReturn, let urlString = downloadUrl, let url = URL(string: urlString) {
                    self.startAutomatedUpdate(url: url)
                }
            }
        } else {
            // Fallback to modal if no windows are available to avoid the "bottom-left" bug
            if alert.runModal() == .alertFirstButtonReturn, let urlString = downloadUrl, let url = URL(string: urlString) {
                self.startAutomatedUpdate(url: url)
            }
        }
    }

    private func startAutomatedUpdate(url: URL) {
        DispatchQueue.main.async {
            let appDelegate = NSApp.delegate as? AppDelegate
            if appDelegate?.loadingWindow == nil {
                appDelegate?.loadingWindow = LoadingWindowController()
            }
            appDelegate?.loadingWindow?.updateStatus(L10n.shared.updateDownloading)
            appDelegate?.loadingWindow?.showWithFade()
        }
        
        downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] localURL, _, error in
            DispatchQueue.main.async {
                self?.observation = nil
                if let localURL = localURL, error == nil {
                    let tempPath = NSTemporaryDirectory() + "DPIKillerUpdate.dmg"
                    try? FileManager.default.removeItem(atPath: tempPath)
                    try? FileManager.default.copyItem(at: localURL, to: URL(fileURLWithPath: tempPath))
                    self?.performInstallation(dmgPath: tempPath)
                } else {
                    let fail = NSAlert()
                    fail.messageText = L10n.shared.updateFailed
                    fail.informativeText = error?.localizedDescription ?? "Download failed."
                    fail.runModal()
                    (NSApp.delegate as? AppDelegate)?.loadingWindow?.closeWithFade {
                        (NSApp.delegate as? AppDelegate)?.loadingWindow = nil
                    }
                }
            }
        }
        
        observation = downloadTask?.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                (NSApp.delegate as? AppDelegate)?.loadingWindow?.updateProgress(progress.fractionCompleted)
            }
        }
        
        downloadTask?.resume()
    }

    private func performInstallation(dmgPath: String) {
        DispatchQueue.main.async {
            (NSApp.delegate as? AppDelegate)?.loadingWindow?.updateStatus(L10n.shared.updateInstalling)
            (NSApp.delegate as? AppDelegate)?.loadingWindow?.setProgressIndeterminate(true)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let script = """
            mkdir -p /tmp/dpi_killer_update
            hdiutil attach "\(dmgPath)" -mountpoint /tmp/dpi_killer_update -nobrowse -quiet
            rm -rf /Applications/DPIKiller.app
            cp -R /tmp/dpi_killer_update/DPIKiller.app /Applications/
            hdiutil detach /tmp/dpi_killer_update -quiet
            """
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = ["-c", script]
            try? process.run()
            process.waitUntilExit()
            
            DispatchQueue.main.async {
                if process.terminationStatus == 0 {
                    self?.relaunch()
                } else {
                    let fail = NSAlert()
                    fail.messageText = L10n.shared.updateFailed
                    fail.informativeText = "Could not copy the new version to /Applications."
                    fail.runModal()
                    (NSApp.delegate as? AppDelegate)?.loadingWindow?.closeWithFade {
                        (NSApp.delegate as? AppDelegate)?.loadingWindow = nil
                    }
                }
            }
        }
    }

    private func relaunch() {
        let appPath = "/Applications/DPIKiller.app"
        let pid = ProcessInfo.processInfo.processIdentifier
        let script = "while kill -0 \(pid) 2>/dev/null; do sleep 0.1; done; open \"\(appPath)\""
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", script]
        try? process.run()
        NSApp.terminate(nil)
    }
}

// MARK: - Spoof Manager
class DPIKillerManager {
    static let shared = DPIKillerManager()
    private(set) var process: Process?
    private var installProcess: Process?
    private(set) var isRunning = false
    
    private var outputPipe: Pipe?
    
    // MARK: CPU Watchdog
    private var watchdogTimer: DispatchSourceTimer?
    private var highCpuStrikes = 0
    private let maxStrikes = 3           // 3 consecutive checks before restart
    private let cpuThreshold = 150.0     // % CPU per-process threshold
    private let watchdogInterval: UInt64 = 30 // seconds between checks
    private var lastRestartTime: Date?
    private let restartCooldown: TimeInterval = 60 // min seconds between auto-restarts

    private var wasRunningBeforeDisconnect = false

    init() {
        NetworkMonitor.shared.onConnectivityRestored = { [weak self] in
            guard let self = self else { return }
            if self.wasRunningBeforeDisconnect {
                print("[Manager] Auto-restarting after network restoration...")
                self.start { success, error in
                    if success {
                        print("[Manager] Auto-restart success.")
                    } else {
                        print("[Manager] Auto-restart failed: \(error ?? "unknown")")
                    }
                    (NSApp.delegate as? AppDelegate)?.refreshUI()
                }
            }
        }
        NetworkMonitor.shared.start()
    }
    
    func start(completion: @escaping (Bool, String?) -> Void) {
        if isRunning { stop() }
        killOrphans() // Ensure clean state
        isRunning = false
        wasRunningBeforeDisconnect = true // Mark that we intend to be running
        
        let binaryPath = SettingsStore.shared.binaryPath
        print("[Manager] Starting with binary: \(binaryPath)")
        if !FileManager.default.fileExists(atPath: binaryPath) {
            completion(false, "NOT_INSTALLED")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: binaryPath)
        
        let rawArgs = SettingsStore.shared.customArgs
        let args = rawArgs.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        process.arguments = args
        
        
        
        
        // Setup Pipe for async logging
        let pipe = Pipe()
        self.outputPipe = pipe
        process.standardOutput = pipe
        process.standardError = pipe
        
        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                LogStore.shared.append(str)
            }
        }
        
        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
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
    
    // MARK: Watchdog lifecycle
    
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
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
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
            print("[Watchdog] High CPU detected: \(cpu)% (strike \(highCpuStrikes)/\(maxStrikes))")
            
            if highCpuStrikes >= maxStrikes {
                print("[Watchdog] CPU threshold exceeded for \(highCpuStrikes) consecutive checks. Auto-restarting spoofdpi...")
                DispatchQueue.main.async { [weak self] in
                    self?.restartDueToHighCPU()
                }
            }
        } else {
            if highCpuStrikes > 0 {
                print("[Watchdog] CPU back to normal: \(cpu)%. Resetting strikes.")
            }
            highCpuStrikes = 0
        }
    }
    
    private func restartDueToHighCPU() {
        // Cooldown check
        if let lastRestart = lastRestartTime, Date().timeIntervalSince(lastRestart) < restartCooldown {
            print("[Watchdog] Cooldown active, skipping restart.")
            return
        }
        
        lastRestartTime = Date()
        highCpuStrikes = 0
        
        // Stop current process
        stopWatchdog()
        process?.terminate()
        process = nil
        isRunning = false
        killOrphans()
        
        // Restart after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.start { success, error in
                if success {
                    print("[Watchdog] spoofdpi restarted successfully.")
                } else {
                    print("[Watchdog] Failed to restart spoofdpi: \(error ?? "unknown error")")
                }
                (NSApp.delegate as? AppDelegate)?.refreshUI()
            }
        }
    }
    
    func install(completion: @escaping (Bool, String?) -> Void) {
        let brewPaths = ["/opt/homebrew/bin/brew", "/usr/local/bin/brew"]
        let brewPath = brewPaths.first { FileManager.default.fileExists(atPath: $0) }
        
        let process = Process()
        if let bp = brewPath {
            process.executableURL = URL(fileURLWithPath: bp)
            process.arguments = ["install", "spoofdpi"]
        } else {
            // Fallback to official shell script if no brew
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-c", "curl -fsSL https://raw.githubusercontent.com/xvzc/spoofdpi/main/install.sh | bash"]
        }
        
        self.installProcess = process
        
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
            self.installProcess = nil
            completion(false, error.localizedDescription)
        }
    }

    func cancelInstall() {
        installProcess?.terminate()
        installProcess = nil
    }

    func stop() {
        isRunning = false
        wasRunningBeforeDisconnect = false // User manually stopped, don't auto-restart
        stopWatchdog()
        
        outputPipe?.fileHandleForReading.readabilityHandler = nil
        outputPipe = nil
        
        process?.terminate()
        process = nil
        killOrphans() // Double safety cleanup
        disableSystemProxy()
        (NSApp.delegate as? AppDelegate)?.refreshUI()
    }

    func fullCleanup() {
        print("[Manager] Performing full cleanup...")
        stop()
        // Ensure IPv6 is restored to default (on)
        SettingsStore.shared.disableIpv6 = false
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

// MARK: - Network Monitor
class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private var lastPathStatus: NWPath.Status = .satisfied
    
    var onConnectivityRestored: (() -> Void)?
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let status = path.status
            print("[NetworkMonitor] Connection status: \(status)")
            
            // Если соединение восстановилось (было не satisfied, стало satisfied)
            if self.lastPathStatus != .satisfied && status == .satisfied {
                print("[NetworkMonitor] Connectivity restored. Notifying...")
                // Даем 2 секунды на стабилизацию интерфейса (получение IP и т.д.)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.onConnectivityRestored?()
                }
            }
            
            self.lastPathStatus = status
        }
    }
    
    func start() {
        monitor.start(queue: queue)
    }
    
    func stop() {
        monitor.cancel()
    }
}

// MARK: - Speed Test Manager
class SpeedTestManager: NSObject, URLSessionDownloadDelegate, URLSessionTaskDelegate {
    static let shared = SpeedTestManager()
    
    private var session: URLSession?
    private var downloadTask: URLSessionDownloadTask?
    private var uploadTask: URLSessionUploadTask?
    
    private var startTime: Date?
    private var totalBytesReceived: Int64 = 0
    private var totalBytesSent: Int64 = 0
    
    var onUpdate: ((Double, Double, Double) -> Void)? // Ping, Down, Up
    var onFinished: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private var pingValue: Double = 0
    private var downloadValue: Double = 0
    private var uploadValue: Double = 0
    
    func startTest() {
        reset()
        measurePing()
    }
    
    func stopTest() {
        downloadTask?.cancel()
        uploadTask?.cancel()
        session?.invalidateAndCancel()
        onFinished?()
    }
    
    private func reset() {
        pingValue = 0; downloadValue = 0; uploadValue = 0
        totalBytesReceived = 0; totalBytesSent = 0
    }
    
    private func measurePing() {
        let url = URL(string: "https://speed.cloudflare.com/cdn-cgi/trace")!
        let start = Date()
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            if let error = error {
                self?.onError?(error.localizedDescription)
                return
            }
            self?.pingValue = Date().timeIntervalSince(start) * 1000
            self?.notify()
            self?.startDownload()
        }.resume()
    }
    
    private func startDownload() {
        let url = URL(string: "https://speed.cloudflare.com/__down?bytes=50000000")!
        let config = URLSessionConfiguration.ephemeral
        if DPIKillerManager.shared.isRunning {
            let port = Int(SettingsStore.shared.localPort) ?? 8080
            config.connectionProxyDictionary = [
                kCFNetworkProxiesHTTPEnable: 1,
                kCFNetworkProxiesHTTPProxy: "127.0.0.1",
                kCFNetworkProxiesHTTPPort: port,
                kCFNetworkProxiesHTTPSEnable: 1,
                kCFNetworkProxiesHTTPSProxy: "127.0.0.1",
                kCFNetworkProxiesHTTPSPort: port
            ]
        }
        let queue = OperationQueue()
        queue.name = "SpeedTestQueue"
        queue.maxConcurrentOperationCount = 1
        session = URLSession(configuration: config, delegate: self, delegateQueue: queue)
        startTime = Date()
        downloadTask = session?.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let start = startTime else { return }
        let duration = Date().timeIntervalSince(start)
        if duration > 0 {
            downloadValue = (Double(totalBytesWritten) * 8) / (duration * 1_000_000) // Mbps
            notify()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        forceNotify()
        startUpload()
    }
    
    private func startUpload() {
        let url = URL(string: "https://speed.cloudflare.com/__up")!
        let data = Data(count: 10_000_000) // 10MB upload
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let config = URLSessionConfiguration.ephemeral
        if DPIKillerManager.shared.isRunning {
            let port = Int(SettingsStore.shared.localPort) ?? 8080
            config.connectionProxyDictionary = [
                kCFNetworkProxiesHTTPEnable: 1,
                kCFNetworkProxiesHTTPProxy: "127.0.0.1",
                kCFNetworkProxiesHTTPPort: port,
                kCFNetworkProxiesHTTPSEnable: 1,
                kCFNetworkProxiesHTTPSProxy: "127.0.0.1",
                kCFNetworkProxiesHTTPSPort: port
            ]
        }
        
        let uploadSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        startTime = Date()
        uploadTask = uploadSession.uploadTask(with: request, from: data)
        uploadTask?.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let start = startTime else { return }
        let duration = Date().timeIntervalSince(start)
        if duration > 0 {
            uploadValue = (Double(totalBytesSent) * 8) / (duration * 1_000_000) // Mbps
            notify()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            onError?(error.localizedDescription)
        } else if task == uploadTask {
            forceNotify()
            onFinished?()
        }
    }
    
    private var lastNotifyTime: Date = .distantPast
    private let notifyThrottle: TimeInterval = 0.3 // ~3 updates per second

    private func notify() {
        let now = Date()
        if now.timeIntervalSince(lastNotifyTime) >= notifyThrottle {
            lastNotifyTime = now
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.onUpdate?(self.pingValue, self.downloadValue, self.uploadValue)
            }
        }
    }
    
    func forceNotify() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onUpdate?(self.pingValue, self.downloadValue, self.uploadValue)
        }
    }
}

// MARK: - Diagnostics Manager
class DiagnosticsManager: NSObject {
    static let shared = DiagnosticsManager()
    
    func checkBypass(completion: @escaping (Bool, String?) -> Void) {
        guard DPIKillerManager.shared.isRunning else {
            completion(false, L10n.shared.diagNoProxy)
            return
        }
        
        let url = URL(string: "https://www.google.com")!
        let config = URLSessionConfiguration.ephemeral
        let port = Int(SettingsStore.shared.localPort) ?? 8080
        
        config.connectionProxyDictionary = [
            kCFNetworkProxiesHTTPEnable: 1,
            kCFNetworkProxiesHTTPProxy: "127.0.0.1",
            kCFNetworkProxiesHTTPPort: port,
            kCFNetworkProxiesHTTPSEnable: 1,
            kCFNetworkProxiesHTTPSProxy: "127.0.0.1",
            kCFNetworkProxiesHTTPSPort: port
        ]
        
        // Timeout 5s
        config.timeoutIntervalForRequest = 5.0
        
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                // If it's 200, it's likely working. 
                // Redirects to auth pages/providers would result in different status codes or content.
                if httpResponse.statusCode == 200 {
                    completion(true, nil)
                } else {
                    completion(false, "Status code: \(httpResponse.statusCode)")
                }
            } else {
                completion(false, "Unknown response")
            }
        }
        task.resume()
    }
}

struct ArgumentOption {
    let flag: String
    let description: String
}

class SettingsWindowController: NSWindowController {
    var pathField: NSTextField!
    var manualArgsField: NSTextField!
    var ttlField: NSTextField!
    var splitModeButton: NSPopUpButton!
    var httpsDisorderButton: NSButton!
    var httpsFakeCountField: NSTextField!
    var httpsChunkSizeField: NSTextField!
    var portField: NSTextField!
    var dnsAddrField: NSTextField!
    var dnsModeButton: NSPopUpButton!
    var dnsHttpsUrlField: NSTextField!
    var hotspotStatusLabel: NSTextField!
    var hotspotFixButton: NSButton!
    var checkboxes: [NSButton] = []
    
    let options = [
        ArgumentOption(flag: "--system-proxy", description: L10n.shared.descSystemProxy),
        ArgumentOption(flag: "--silent", description: L10n.shared.descSilent),
        ArgumentOption(flag: "--dns-ipv4-only", description: L10n.shared.descIpv4Only),
        ArgumentOption(flag: "--debug", description: L10n.shared.descDebug),
        ArgumentOption(flag: "--policy-auto", description: L10n.shared.descPolicyAuto)
    ]
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 400),
            styleMask: [.titled, .closable, .fullSizeContentView, .miniaturizable],
            backing: .buffered, defer: false)
        window.center()
        window.title = L10n.shared.settingsTitle
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        self.init(window: window)
        setupUI()
    }
    
    private func addSectionHeader(_ title: String, at y: inout CGFloat, to view: NSView) {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .labelColor
        label.frame = NSRect(x: 20, y: y, width: 600, height: 20)
        view.addSubview(label)
        y -= 25
    }
    
    private func addSeparator(at y: inout CGFloat, to view: NSView) {
        y -= 10
        let box = NSBox(frame: NSRect(x: 20, y: y, width: 600, height: 1))
        box.boxType = .separator
        view.addSubview(box)
        y -= 20
    }
    
    func setupUI() {
        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 640, height: 400))
        visualEffectView.material = .sidebar
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        window?.contentView = visualEffectView
        
        let scrollView = NSScrollView(frame: visualEffectView.bounds)
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.autoresizingMask = [.width, .height]
        visualEffectView.addSubview(scrollView)
        
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 640, height: 1100))
        scrollView.documentView = contentView
        
        var currentY: CGFloat = 1060
        
        // --- SECTION 1: CORE ---
        addSectionHeader(L10n.shared.binaryPath, at: &currentY, to: contentView)
        pathField = NSTextField(frame: NSRect(x: 20, y: currentY, width: 600, height: 24))
        pathField.stringValue = SettingsStore.shared.binaryPath
        pathField.placeholderString = L10n.shared.binaryPlaceholder
        contentView.addSubview(pathField)
        currentY -= 40
        
        // --- SECTION 2: HOTSPOT OPTIMIZATION ---
        addSeparator(at: &currentY, to: contentView)
        addSectionHeader("Mobile Hotspot Strategy", at: &currentY, to: contentView)
        
        let statusLabel = NSTextField(labelWithString: L10n.shared.hotspotStatusTitle)
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.frame = NSRect(x: 20, y: currentY, width: 140, height: 20)
        contentView.addSubview(statusLabel)
        
        hotspotStatusLabel = NSTextField(labelWithString: L10n.shared.diagChecking)
        hotspotStatusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        hotspotStatusLabel.frame = NSRect(x: 160, y: currentY, width: 220, height: 20)
        contentView.addSubview(hotspotStatusLabel)
        
        hotspotFixButton = NSButton(title: "🛠 \(L10n.shared.fixHotspotButton)", target: self, action: #selector(fixHotspotAction))
        hotspotFixButton.bezelStyle = .rounded
        hotspotFixButton.frame = NSRect(x: 390, y: currentY - 5, width: 230, height: 28)
        hotspotFixButton.isHidden = true
        contentView.addSubview(hotspotFixButton)
        currentY -= 35
        
        let presetBtn = NSButton(title: "⚡️ \(L10n.shared.mobilePresetTitle)", target: self, action: #selector(applyMobilePreset))
        presetBtn.bezelStyle = .rounded
        presetBtn.controlSize = .large
        presetBtn.isHighlighted = true
        presetBtn.frame = NSRect(x: 20, y: currentY, width: 600, height: 32)
        contentView.addSubview(presetBtn)
        currentY -= 45
        
        updateHotspotStatus()
        
        // --- SECTION 3: DPI STRATEGY ---
        addSeparator(at: &currentY, to: contentView)
        addSectionHeader(L10n.shared.argumentsTitle, at: &currentY, to: contentView)
        
        let selected = SettingsStore.shared.selectedFlags
        for option in options {
            let cb = NSButton(checkboxWithTitle: option.flag, target: nil, action: nil)
            cb.frame = NSRect(x: 20, y: currentY, width: 160, height: 20)
            cb.state = selected.contains(option.flag) ? .on : .off
            contentView.addSubview(cb)
            checkboxes.append(cb)
            
            let desc = NSTextField(labelWithString: "— \(option.description)")
            desc.font = .systemFont(ofSize: 11)
            desc.textColor = .secondaryLabelColor
            desc.frame = NSRect(x: 185, y: currentY, width: 440, height: 18)
            contentView.addSubview(desc)
            currentY -= 22
        }
        currentY -= 15
        
        // Packet TTL & Port
        let ttlLabel = NSTextField(labelWithString: L10n.shared.ttlTitle)
        ttlLabel.frame = NSRect(x: 20, y: currentY, width: 110, height: 20)
        contentView.addSubview(ttlLabel)
        
        ttlField = NSTextField(frame: NSRect(x: 135, y: currentY - 2, width: 80, height: 22))
        ttlField.stringValue = SettingsStore.shared.defaultTTL
        contentView.addSubview(ttlField)
        
        let pLabel = NSTextField(labelWithString: L10n.shared.portTitle)
        pLabel.frame = NSRect(x: 240, y: currentY, width: 100, height: 20)
        contentView.addSubview(pLabel)
        
        portField = NSTextField(frame: NSRect(x: 345, y: currentY - 2, width: 80, height: 22))
        portField.stringValue = SettingsStore.shared.localPort
        contentView.addSubview(portField)
        currentY -= 35
        
        // Split Mode
        let smLabel = NSTextField(labelWithString: L10n.shared.splitModeTitle)
        smLabel.frame = NSRect(x: 20, y: currentY, width: 180, height: 20)
        contentView.addSubview(smLabel)
        
        splitModeButton = NSPopUpButton(frame: NSRect(x: 205, y: currentY - 2, width: 120, height: 22), pullsDown: false)
        splitModeButton.addItems(withTitles: ["sni", "random", "chunk", "none"])
        splitModeButton.selectItem(withTitle: SettingsStore.shared.splitMode)
        contentView.addSubview(splitModeButton)
        currentY -= 35
        
        // --- SECTION 4: HTTPS FRAGMENTATION ---
        addSeparator(at: &currentY, to: contentView)
        addSectionHeader("HTTPS Bypass Strategy", at: &currentY, to: contentView)
        
        let disorderLabel = NSTextField(labelWithString: L10n.shared.httpsDisorder)
        disorderLabel.frame = NSRect(x: 20, y: currentY, width: 180, height: 20)
        contentView.addSubview(disorderLabel)
        
        httpsDisorderButton = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        httpsDisorderButton.frame = NSRect(x: 205, y: currentY, width: 22, height: 20)
        httpsDisorderButton.state = SettingsStore.shared.httpsDisorder ? .on : .off
        contentView.addSubview(httpsDisorderButton)
        currentY -= 30
        
        let fakeLabel = NSTextField(labelWithString: L10n.shared.httpsFakeCount)
        fakeLabel.frame = NSRect(x: 20, y: currentY, width: 180, height: 20)
        contentView.addSubview(fakeLabel)
        
        httpsFakeCountField = NSTextField(frame: NSRect(x: 205, y: currentY - 2, width: 80, height: 22))
        httpsFakeCountField.stringValue = SettingsStore.shared.httpsFakeCount
        contentView.addSubview(httpsFakeCountField)
        currentY -= 30
        
        let chunkSizeLabel = NSTextField(labelWithString: L10n.shared.httpsChunkSize)
        chunkSizeLabel.frame = NSRect(x: 20, y: currentY, width: 180, height: 20)
        contentView.addSubview(chunkSizeLabel)
        
        httpsChunkSizeField = NSTextField(frame: NSRect(x: 205, y: currentY - 2, width: 80, height: 22))
        httpsChunkSizeField.stringValue = SettingsStore.shared.httpsChunkSize
        contentView.addSubview(httpsChunkSizeField)
        currentY -= 40
        
        // --- SECTION 5: DNS ---
        addSeparator(at: &currentY, to: contentView)
        addSectionHeader(L10n.shared.dnsTitle, at: &currentY, to: contentView)
        
        let daLabel = NSTextField(labelWithString: L10n.shared.dnsAddrTitle)
        daLabel.frame = NSRect(x: 20, y: currentY, width: 140, height: 20)
        contentView.addSubview(daLabel)
        dnsAddrField = NSTextField(frame: NSRect(x: 160, y: currentY - 2, width: 440, height: 22))
        dnsAddrField.stringValue = SettingsStore.shared.dnsAddr
        contentView.addSubview(dnsAddrField)
        currentY -= 30
        
        let dmLabel = NSTextField(labelWithString: L10n.shared.dnsModeTitle)
        dmLabel.frame = NSRect(x: 20, y: currentY, width: 140, height: 20)
        contentView.addSubview(dmLabel)
        dnsModeButton = NSPopUpButton(frame: NSRect(x: 160, y: currentY - 2, width: 140, height: 22), pullsDown: false)
        dnsModeButton.addItems(withTitles: ["udp", "https", "system"])
        dnsModeButton.selectItem(withTitle: SettingsStore.shared.dnsMode)
        contentView.addSubview(dnsModeButton)
        currentY -= 30
        
        let dhLabel = NSTextField(labelWithString: "DoH/DoT URL:")
        dhLabel.frame = NSRect(x: 20, y: currentY, width: 140, height: 20)
        contentView.addSubview(dhLabel)
        dnsHttpsUrlField = NSTextField(frame: NSRect(x: 160, y: currentY - 2, width: 440, height: 22))
        dnsHttpsUrlField.stringValue = SettingsStore.shared.dnsHttpsUrl
        contentView.addSubview(dnsHttpsUrlField)
        currentY -= 45
        
        // --- SECTION 6: SYSTEM ---
        addSeparator(at: &currentY, to: contentView)
        addSectionHeader("Application Behavior", at: &currentY, to: contentView)
        
        let loginCheckbox = NSButton(checkboxWithTitle: L10n.shared.launchAtLogin, target: self, action: #selector(toggleLoginItem))
        loginCheckbox.frame = NSRect(x: 20, y: currentY, width: 600, height: 20)
        loginCheckbox.state = SettingsStore.shared.launchAtLogin ? .on : .off
        contentView.addSubview(loginCheckbox)
        currentY -= 25
        
        let updateCheckbox = NSButton(checkboxWithTitle: L10n.shared.autoUpdateToggle, target: self, action: #selector(toggleUpdateItem))
        updateCheckbox.frame = NSRect(x: 20, y: currentY, width: 600, height: 20)
        updateCheckbox.state = SettingsStore.shared.autoUpdate ? .on : .off
        contentView.addSubview(updateCheckbox)
        currentY -= 22
        
        let downloadCheckbox = NSButton(checkboxWithTitle: L10n.shared.autoDownloadToggle, target: self, action: #selector(toggleDownloadItem))
        downloadCheckbox.frame = NSRect(x: 20, y: currentY, width: 600, height: 20)
        downloadCheckbox.state = SettingsStore.shared.autoDownload ? .on : .off
        downloadCheckbox.isEnabled = SettingsStore.shared.autoUpdate
        contentView.addSubview(downloadCheckbox)
        currentY -= 25
        
        let ipv6Checkbox = NSButton(checkboxWithTitle: L10n.shared.disableIpv6, target: self, action: #selector(toggleIpv6))
        ipv6Checkbox.frame = NSRect(x: 20, y: currentY, width: 600, height: 20)
        ipv6Checkbox.state = SettingsStore.shared.disableIpv6 ? .on : .off
        contentView.addSubview(ipv6Checkbox)
        currentY -= 16
        
        let ipv6Desc = NSTextField(labelWithString: L10n.shared.ipv6Warning)
        ipv6Desc.font = .systemFont(ofSize: 11)
        ipv6Desc.textColor = .secondaryLabelColor
        ipv6Desc.frame = NSRect(x: 40, y: currentY, width: 580, height: 18)
        contentView.addSubview(ipv6Desc)
        currentY -= 40
        
        // --- SECTION 7: ADVANCED ---
        addSeparator(at: &currentY, to: contentView)
        addSectionHeader(L10n.shared.manualArgsTitle, at: &currentY, to: contentView)
        
        manualArgsField = NSTextField(frame: NSRect(x: 20, y: currentY, width: 600, height: 24))
        let allArgs = SettingsStore.shared.customArgs.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        var manualParts: [String] = []
        var i = 0
        while i < allArgs.count {
            let arg = allArgs[i]
            if arg == "--default-ttl" || arg == "--https-split-mode" || arg == "--listen-addr" || arg == "--dns-addr" || arg == "--dns-mode" || arg == "--dns-https-url" || arg == "--https-disorder" || arg == "--https-fake-count" || arg == "--https-chunk-size" {
                // Skip flag and its potential value if it's already covered by UI
                i += 1 
                if i < allArgs.count && !allArgs[i].hasPrefix("-") { i += 1 }
            } else if options.contains(where: { $0.flag == arg }) {
                i += 1
            } else {
                manualParts.append(arg)
                i += 1
            }
        }
        manualArgsField.stringValue = manualParts.joined(separator: " ")
        manualArgsField.placeholderString = L10n.shared.manualArgsPlaceholder
        contentView.addSubview(manualArgsField)
        currentY -= 45
        
        // --- FOOTER: ACTIONS ---
        addSeparator(at: &currentY, to: contentView)
        
        let cancelBtn = NSButton(title: L10n.shared.cancel, target: self, action: #selector(cancelAction))
        cancelBtn.frame = NSRect(x: 20, y: currentY - 5, width: 290, height: 32)
        cancelBtn.bezelStyle = .rounded
        contentView.addSubview(cancelBtn)
        
        let saveButton = NSButton(title: L10n.shared.saveAndRestart, target: self, action: #selector(save))
        saveButton.frame = NSRect(x: 330, y: currentY - 5, width: 290, height: 32)
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"
        contentView.addSubview(saveButton)
        
        currentY -= 50
        contentView.frame.size.height = 1060 - currentY + 20
    }
    
    @objc func cancelAction() {
        window?.close()
    }
    
    @objc func applyMobilePreset() {
        ttlField.stringValue = "128"
        splitModeButton.selectItem(withTitle: "random")
        httpsChunkSizeField.stringValue = "20"
        httpsDisorderButton.state = .on
        httpsFakeCountField.stringValue = "0"
        
        // Visual feedback
        ttlField.layer?.backgroundColor = NSColor.systemGreen.withAlphaComponent(0.2).cgColor
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 1.0
            self.ttlField.layer?.backgroundColor = NSColor.clear.cgColor
        }
        
        if getSystemTTL() != 65 {
            fixHotspotAction()
        }
    }
    
    @objc func fixHotspotAction() {
        let script = "do shell script \"sysctl -w net.inet.ip.ttl=65 && sysctl -w net.inet6.ip6.hlim=65\" with administrator privileges"
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)
        
        if let err = error {
            print("AppleScript Error: \(err)")
            let alert = NSAlert()
            alert.messageText = L10n.shared.fixHotspotFailed
            alert.informativeText = "\(err["NSAppleScriptErrorMessage"] ?? "Unknown error")"
            alert.runModal()
        } else {
            updateHotspotStatus()
        }
    }
    
    func updateHotspotStatus() {
        let ttl = getSystemTTL()
        if ttl == 65 {
            hotspotStatusLabel.stringValue = L10n.shared.hotspotStatusOptimized
            hotspotStatusLabel.textColor = .systemGreen
            hotspotFixButton.isHidden = true
        } else {
            hotspotStatusLabel.stringValue = L10n.shared.hotspotStatusThrottled
            hotspotStatusLabel.textColor = .systemOrange
            hotspotFixButton.isHidden = false
        }
    }
    
    func getSystemTTL() -> Int {
        let task = Process()
        task.launchPath = "/usr/sbin/sysctl"
        task.arguments = ["-n", "net.inet.ip.ttl"]
        let pipe = Pipe()
        task.standardOutput = pipe
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               let val = Int(output) {
                return val
            }
        } catch {
            return 64
        }
        return 64
    }
    
    @objc func toggleLoginItem(_ sender: NSButton) {
        SettingsStore.shared.launchAtLogin = (sender.state == .on)
    }
    
    @objc func toggleDownloadItem(_ sender: NSButton) {
        SettingsStore.shared.autoDownload = (sender.state == .on)
    }
    
    @objc func toggleUpdateItem(_ sender: NSButton) {
        SettingsStore.shared.autoUpdate = (sender.state == .on)
    }
    
    @objc func toggleIpv6(_ sender: NSButton) {
        SettingsStore.shared.disableIpv6 = (sender.state == .on)
    }
    
    @objc func save() {
        var flags = Set<String>()
        for (index, cb) in checkboxes.enumerated() {
            if cb.state == .on { flags.insert(options[index].flag) }
        }
        SettingsStore.shared.binaryPath = pathField.stringValue
        SettingsStore.shared.defaultTTL = ttlField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        SettingsStore.shared.splitMode = splitModeButton.titleOfSelectedItem ?? "sni"
        SettingsStore.shared.httpsDisorder = httpsDisorderButton.state == .on
        SettingsStore.shared.httpsFakeCount = httpsFakeCountField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        SettingsStore.shared.httpsChunkSize = httpsChunkSizeField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        SettingsStore.shared.localPort = portField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        SettingsStore.shared.dnsAddr = dnsAddrField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        SettingsStore.shared.dnsMode = dnsModeButton.titleOfSelectedItem ?? "udp"
        SettingsStore.shared.dnsHttpsUrl = dnsHttpsUrlField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Re-apply IPv6 settings just in case
        SettingsStore.shared.disableIpv6 = SettingsStore.shared.disableIpv6
        
        SettingsStore.shared.updateArgs(with: flags, manual: manualArgsField.stringValue, 
                                        ttl: SettingsStore.shared.defaultTTL, 
                                        splitMode: SettingsStore.shared.splitMode, 
                                        splitPos: "1", 
                                        port: SettingsStore.shared.localPort,
                                        dnsAddr: SettingsStore.shared.dnsAddr,
                                        dnsMode: SettingsStore.shared.dnsMode,
                                        dnsHttpsUrl: SettingsStore.shared.dnsHttpsUrl)
        
        if DPIKillerManager.shared.isRunning {
            DPIKillerManager.shared.stop()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                DPIKillerManager.shared.start { _, _ in 
                    (NSApp.delegate as? AppDelegate)?.refreshUI()
                }
            }
        }
        window?.close()
    }
}

// MARK: - Speed Test Window
class SpeedTestWindowController: NSWindowController {
    private var pingLabel: NSTextField!
    private var downloadLabel: NSTextField!
    private var uploadLabel: NSTextField!
    private var progressIndicator: NSProgressIndicator!
    private var startButton: NSButton!
    
    convenience init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 400),
                              styleMask: [.titled, .closable, .fullSizeContentView, .miniaturizable],
                              backing: .buffered, defer: false)
        window.center()
        window.title = L10n.shared.speedTest
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        self.init(window: window)
        setupUI()
    }
    
    private func setupUI() {
        let visualEffectView = NSVisualEffectView(frame: window!.contentView!.bounds)
        visualEffectView.material = .windowBackground
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]
        window?.contentView = visualEffectView
        
        let titleLabel = NSTextField(labelWithString: L10n.shared.speedTestTitle)
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.frame = NSRect(x: 20, y: 340, width: 600, height: 30)
        titleLabel.alignment = .center
        visualEffectView.addSubview(titleLabel)
        
        pingLabel = createValueLabel(title: L10n.shared.ping, unit: L10n.shared.ms, y: 260)
        downloadLabel = createValueLabel(title: L10n.shared.download, unit: L10n.shared.mbps, y: 220)
        uploadLabel = createValueLabel(title: L10n.shared.upload, unit: L10n.shared.mbps, y: 180)
        
        visualEffectView.addSubview(pingLabel)
        visualEffectView.addSubview(downloadLabel)
        visualEffectView.addSubview(uploadLabel)
        
        progressIndicator = NSProgressIndicator(frame: NSRect(x: 120, y: 140, width: 400, height: 20))
        progressIndicator.style = .bar
        progressIndicator.isIndeterminate = false
        progressIndicator.minValue = 0
        progressIndicator.maxValue = 100
        progressIndicator.doubleValue = 0
        progressIndicator.isDisplayedWhenStopped = true
        visualEffectView.addSubview(progressIndicator)
        
        startButton = NSButton(title: L10n.shared.startTest, target: self, action: #selector(startClicked))
        startButton.frame = NSRect(x: 220, y: 40, width: 200, height: 40)
        startButton.bezelStyle = .rounded
        startButton.controlSize = .large
        visualEffectView.addSubview(startButton)
    }
    
    private func createValueLabel(title: String, unit: String, y: CGFloat) -> NSTextField {
        let label = NSTextField(labelWithString: "\(title): — \(unit)")
        label.frame = NSRect(x: 20, y: y, width: 600, height: 24)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.alignment = .center
        return label
    }
    
    @objc private func startClicked() {
        if startButton.title == L10n.shared.startTest {
            startButton.title = L10n.shared.stopTest
            progressIndicator.startAnimation(nil)
            
            SpeedTestManager.shared.onUpdate = { [weak self] ping, down, up in
                DispatchQueue.main.async {
                    self?.pingLabel.stringValue = "\(L10n.shared.ping): \(Int(ping)) \(L10n.shared.ms)"
                    self?.downloadLabel.stringValue = "\(L10n.shared.download): \(String(format: "%.2f", down)) \(L10n.shared.mbps)"
                    self?.uploadLabel.stringValue = "\(L10n.shared.upload): \(String(format: "%.2f", up)) \(L10n.shared.mbps)"
                }
            }
            
            SpeedTestManager.shared.onFinished = { [weak self] in
                DispatchQueue.main.async {
                    self?.startButton.title = L10n.shared.startTest
                    self?.progressIndicator.stopAnimation(nil)
                }
            }
            
            SpeedTestManager.shared.onError = { [weak self] error in
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = error
                    alert.runModal()
                    self?.startButton.title = L10n.shared.startTest
                    self?.progressIndicator.stopAnimation(nil)
                }
            }
            
            SpeedTestManager.shared.startTest()
        } else {
            SpeedTestManager.shared.stopTest()
        }
    }
}

// MARK: - Log Window
class LogWindowController: NSWindowController {
    private var textView: NSTextView!
    private var scrollView: NSScrollView!
    
    convenience init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 400),
                              styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
                              backing: .buffered, defer: false)
        window.center()
        window.title = L10n.shared.logsTitle
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        self.init(window: window)
        setupUI()
        
        LogStore.shared.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateLogs()
            }
        }
        updateLogs()
    }
    
    private func setupUI() {
        let visualEffectView = NSVisualEffectView(frame: window!.contentView!.bounds)
        visualEffectView.material = .sidebar
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]
        window?.contentView = visualEffectView
        
        scrollView = NSScrollView(frame: NSRect(x: 0, y: 50, width: 640, height: 350))
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.autoresizingMask = [.width, .height]
        
        textView = NSTextView(frame: scrollView.documentView?.bounds ?? scrollView.bounds)
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.autoresizingMask = [.width]
        textView.drawsBackground = false
        textView.textColor = .labelColor
        
        scrollView.documentView = textView
        visualEffectView.addSubview(scrollView)
        
        let bottomBar = NSView(frame: NSRect(x: 0, y: 0, width: 640, height: 50))
        bottomBar.autoresizingMask = [.width, .maxYMargin]
        visualEffectView.addSubview(bottomBar)
        
        let clearBtn = NSButton(title: L10n.shared.clearLogs, target: self, action: #selector(clearLogs))
        clearBtn.bezelStyle = .rounded
        clearBtn.frame = NSRect(x: 20, y: 10, width: 120, height: 32)
        bottomBar.addSubview(clearBtn)
        
        let copyBtn = NSButton(title: L10n.shared.copyLogs, target: self, action: #selector(copyLogs))
        copyBtn.bezelStyle = .rounded
        copyBtn.frame = NSRect(x: 150, y: 10, width: 120, height: 32)
        bottomBar.addSubview(copyBtn)
    }
    
    private func updateLogs() {
        let text = LogStore.shared.getAllLogs()
        let wasAtBottom = scrollView.verticalScroller?.floatValue ?? 1.0 > 0.95
        
        textView.string = text
        
        if wasAtBottom {
            textView.scrollToEndOfDocument(nil)
        }
    }
    
    @objc private func clearLogs() {
        LogStore.shared.clear()
    }
    
    @objc private func copyLogs() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(LogStore.shared.getAllLogs(), forType: .string)
    }
}

// MARK: - Help Window

class HelpWindowController: NSWindowController {
    var webView: WKWebView!
    convenience init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 600), 
                              styleMask: [.titled, .closable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.center()
        window.title = L10n.shared.helpTitle
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        self.init(window: window)
        setupUI()
        loadReadme()
    }
    func setupUI() {
        let visualEffectView = NSVisualEffectView(frame: window!.contentView!.bounds)
        visualEffectView.material = .sidebar
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]
        window?.contentView = visualEffectView
        
        webView = WKWebView(frame: visualEffectView.bounds)
        webView.autoresizingMask = [.width, .height]
        webView.setValue(false, forKey: "drawsBackground")
        visualEffectView.addSubview(webView)
    }
    func loadReadme() {
        guard let path = Bundle.main.path(forResource: "README", ofType: "md"), let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            webView.loadHTMLString("<html><body>\(L10n.shared.isRussian ? "Инструкция недоступна." : "Manual not available.")</body></html>", baseURL: nil)
            return
        }; let html = markdownToHTML(content)
        let styledHTML = "<html><head><style>body { font-family: -apple-system; font-size: 14px; line-height: 1.5; padding: 20px 40px; color: #333; } @media (prefers-color-scheme: dark) { body { color: #eee; } a { color: #4dabf7; } code { background: #333; } pre { background: #222; } } h1 { font-size: 24px; border-bottom: 1px solid #eee; } pre { background: #f8f9fa; padding: 12px; border-radius: 8px; overflow-x: auto; } code { background: #f4f4f4; padding: 2px 5px; border-radius: 4px; font-family: monospace; } img { max-width: 100%; border-radius: 8px; }</style></head><body>\(html)</body></html>"
        webView.loadHTMLString(styledHTML, baseURL: Bundle.main.resourceURL)
    }
    private func markdownToHTML(_ markdown: String) -> String {
        var result = ""; let lines = markdown.components(separatedBy: .newlines); var inCodeBlock = false; var codeContent = ""
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("```") {
                if inCodeBlock { 
                    result += "<pre><code>\(codeContent.trimmingCharacters(in: .whitespacesAndNewlines))</code></pre>\n"
                    codeContent = ""
                    inCodeBlock = false 
                } else { 
                    inCodeBlock = true 
                }
                continue
            }
            if inCodeBlock { 
                codeContent += line.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;") + "\n"
                continue 
            }
            if trimmed.isEmpty { result += "<br>\n"; continue }
            if trimmed.hasPrefix("<") { result += line + "\n"; continue }
            
            if line.hasPrefix("# ") { result += "<h1>\(processInline(String(line.dropFirst(2))))</h1>\n"; continue }
            if line.hasPrefix("## ") { result += "<h2>\(processInline(String(line.dropFirst(3))))</h2>\n"; continue }
            if line.hasPrefix("### ") { result += "<h3>\(processInline(String(line.dropFirst(4))))</h3>\n"; continue }
            if trimmed == "---" { result += "<hr>\n"; continue }
            if trimmed.hasPrefix("- ") { result += "<li>\(processInline(String(trimmed.dropFirst(2))))</li>\n"; continue }
            result += "<p>\(processInline(line))</p>\n"
        }
        return result
    }
    private func processInline(_ text: String) -> String {
        var p = text
        p = p.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "<b>$1</b>", options: .regularExpression)
        p = p.replacingOccurrences(of: "`([^`]+)`", with: "<code>$1</code>", options: .regularExpression)
        p = p.replacingOccurrences(of: "\\[([^\\]]+)\\]\\(([^\\)]+)\\)", with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        return p
    }
}

class LoadingWindowController: NSWindowController {
    private var sublabel: NSTextField?
    private var indicator: NSProgressIndicator?
    private var cancelButton: NSButton?
    var cancelHandler: (() -> Void)?
    convenience init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 340, height: 180), styleMask: [.borderless], backing: .buffered, defer: false)
        window.center(); window.isOpaque = false; window.backgroundColor = .clear; window.level = .floating; window.hasShadow = true; window.isMovableByWindowBackground = true
        self.init(window: window); setupUI()
    }
    func setupUI() {
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 340, height: 180))
        container.wantsLayer = true; container.layer?.cornerRadius = 32; container.layer?.masksToBounds = true; window?.contentView = container
        let visualEffect = NSVisualEffectView(frame: container.bounds); visualEffect.blendingMode = .behindWindow; visualEffect.material = .underWindowBackground; visualEffect.state = .active
        container.addSubview(visualEffect)
        if let icon = NSApp.applicationIconImage { let iconView = NSImageView(frame: NSRect(x: 130, y: 85, width: 80, height: 80)); iconView.image = icon; container.addSubview(iconView) }
        let label = NSTextField(labelWithString: "DPI Killer"); label.font = .systemFont(ofSize: 22, weight: .semibold); label.frame = NSRect(x: 0, y: 55, width: 340, height: 30); label.alignment = .center; container.addSubview(label)
        let sublabel = NSTextField(labelWithString: L10n.shared.preparingBypass); sublabel.font = .systemFont(ofSize: 13, weight: .medium); sublabel.textColor = .secondaryLabelColor
        sublabel.frame = NSRect(x: 0, y: 35, width: 340, height: 20); sublabel.alignment = .center; self.sublabel = sublabel; container.addSubview(sublabel)
        indicator = NSProgressIndicator(frame: NSRect(x: 100, y: 15, width: 140, height: 20)); indicator?.style = .bar; indicator?.isIndeterminate = true; indicator?.startAnimation(nil); container.addSubview(indicator!)
        cancelButton = NSButton(title: L10n.shared.cancel, target: self, action: #selector(cancelClicked)); cancelButton?.frame = NSRect(x: 120, y: 5, width: 100, height: 20); cancelButton?.bezelStyle = .recessed; cancelButton?.isHidden = true; container.addSubview(cancelButton!)
        window?.invalidateShadow()
    }
    func updateStatus(_ text: String, showCancel: Bool = false) { DispatchQueue.main.async { self.sublabel?.stringValue = text; self.cancelButton?.isHidden = !showCancel } }
    func updateProgress(_ value: Double) { DispatchQueue.main.async { self.indicator?.isIndeterminate = false; self.indicator?.doubleValue = value * 100 } }
    func setProgressIndeterminate(_ value: Bool) { DispatchQueue.main.async { self.indicator?.isIndeterminate = value; if value { self.indicator?.startAnimation(nil) } } }
    @objc func cancelClicked() { cancelHandler?() }
    func showWithFade() { 
        window?.alphaValue = 0
        window?.center() // Ensure it's centered before showing
        showWindow(nil)
        NSAnimationContext.runAnimationGroup { $0.duration = 0.4; window?.animator().alphaValue = 1.0 } 
    }
    func closeWithFade(completion: @escaping () -> Void) { 
        NSAnimationContext.runAnimationGroup({ $0.duration = 0.4; window?.animator().alphaValue = 0 }, completionHandler: completion) 
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var settingsWindow: SettingsWindowController?
    var helpWindow: HelpWindowController?
    var loadingWindow: LoadingWindowController?
    var speedTestWindow: SpeedTestWindowController?
    var logWindow: LogWindowController?
    
    private var iconCache: [Bool: NSImage] = [:]
    private var lastRefreshTime: Date = .distantPast
    private let refreshThrottleInterval: TimeInterval = 0.5

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupSignalHandlers()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        refreshUI()
        
        // Fail-safe: Restore settings on startup in case of previous crash
        DPIKillerManager.shared.fullCleanup()
        
        // Ensure only one instance of loadingWindow exists
        if loadingWindow == nil { loadingWindow = LoadingWindowController() }
        loadingWindow?.showWithFade()
        
        GitHubUpdater.shared.checkForUpdates()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in self?.attemptStart() }
    }

    func attemptStart() {
        DPIKillerManager.shared.start { [weak self] success, error in
            self?.loadingWindow?.closeWithFade {
                self?.loadingWindow = nil; self?.refreshUI()
                if !success {
                    if error == "NOT_INSTALLED" { self?.showInstallAlert() }
                    else {
                        let alert = NSAlert()
                        alert.messageText = L10n.shared.failedToStart
                        alert.informativeText = error ?? (L10n.shared.isRussian ? "Проверьте настройки." : "Check settings.")
                        NSApp.activate(ignoringOtherApps: true)
                        alert.beginSheetModal(for: self?.settingsWindow?.window ?? NSWindow()) { _ in
                            self?.showSettings()
                        }
                    }
                }
            }
        }
    }

    private func showInstallAlert() {
        let alert = NSAlert()
        alert.messageText = L10n.shared.dependencyMissing
        alert.informativeText = L10n.shared.spoofDpiNeeded
        alert.addButton(withTitle: L10n.shared.install)
        alert.addButton(withTitle: L10n.shared.quit)
        
        NSApp.activate(ignoringOtherApps: true)
        // Use an existing window or run modal as a fallback
        if let window = loadingWindow?.window ?? settingsWindow?.window {
            alert.beginSheetModal(for: window) { response in
                if response == .alertFirstButtonReturn { self.performInstallation() } else { NSApp.terminate(nil) }
            }
        } else {
            if alert.runModal() == .alertFirstButtonReturn { performInstallation() } else { NSApp.terminate(nil) }
        }
    }

    private func performInstallation() {
        if loadingWindow == nil { loadingWindow = LoadingWindowController() }
        loadingWindow?.updateStatus(L10n.shared.installing, showCancel: true)
        loadingWindow?.setProgressIndeterminate(true)
        loadingWindow?.cancelHandler = { [weak self] in 
            DPIKillerManager.shared.cancelInstall()
            self?.loadingWindow?.closeWithFade { self?.loadingWindow = nil; self?.refreshUI() } 
        }
        loadingWindow?.showWithFade()
        
        DPIKillerManager.shared.install { [weak self] success, error in
            if success {
                self?.loadingWindow?.updateStatus(L10n.shared.installComplete)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.loadingWindow?.closeWithFade {
                        self?.loadingWindow = nil
                        self?.refreshUI()
                        self?.attemptStart()
                    }
                }
            } else {
                self?.loadingWindow?.closeWithFade {
                    self?.loadingWindow = nil
                    self?.refreshUI()
                    if let error = error {
                        let f = NSAlert()
                        f.messageText = L10n.shared.installFailed
                        f.informativeText = error
                        NSApp.activate(ignoringOtherApps: true)
                        f.runModal()
                    }
                }
            }
        }
    }

    func refreshUI() {
        let now = Date()
        if now.timeIntervalSince(lastRefreshTime) < refreshThrottleInterval {
            DispatchQueue.main.asyncAfter(deadline: .now() + refreshThrottleInterval) { [weak self] in self?.refreshUI() }
            return
        }
        lastRefreshTime = now
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let button = self.statusItem?.button {
                let isRunning = DPIKillerManager.shared.isRunning
                if self.iconCache[isRunning] == nil { self.iconCache[isRunning] = self.createStatusIcon(isRunning: isRunning) }
                button.image = self.iconCache[isRunning]; button.imagePosition = .imageOnly
            }
            self.setupMenu()
        }
    }

    private func createStatusIcon(isRunning: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18); let image = NSImage(size: size); image.lockFocus()
        if let ai = NSApp.applicationIconImage { ai.draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .sourceOver, fraction: 1.0) }
        else { NSColor.secondaryLabelColor.set(); NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 14, height: 14)).fill() }
        let dotRect = NSRect(x: 12.5, y: 1.0, width: 4.5, height: 4.5); NSColor.white.set(); NSBezierPath(ovalIn: dotRect.insetBy(dx: -1.0, dy: -1.0)).fill()
        if isRunning { NSColor.systemGreen.set() } else { NSColor.systemRed.set() }; NSBezierPath(ovalIn: dotRect).fill(); image.unlockFocus(); image.isTemplate = false; return image
    }

    func setupMenu() {
        let menu = NSMenu(); let status = DPIKillerManager.shared.isRunning ? L10n.shared.statusActive : L10n.shared.statusStopped
        menu.addItem(NSMenuItem(title: status, action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: DPIKillerManager.shared.isRunning ? L10n.shared.stop : L10n.shared.start, action: #selector(toggle), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: L10n.shared.diagTitle, action: #selector(runDiagnostics), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: L10n.shared.speedTest, action: #selector(showSpeedTest), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: L10n.shared.logsTitle, action: #selector(showLogs), keyEquivalent: "l"))
        menu.addItem(NSMenuItem(title: L10n.shared.settings, action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: L10n.shared.updateCheck, action: #selector(checkUpdate), keyEquivalent: "u"))
        menu.addItem(NSMenuItem(title: L10n.shared.instructions, action: #selector(showHelp), keyEquivalent: "h"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: L10n.shared.quit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func toggle() {
        if DPIKillerManager.shared.isRunning { DPIKillerManager.shared.stop() }
        else { DPIKillerManager.shared.start { [weak self] s, e in if !s { let a = NSAlert(); a.messageText = L10n.shared.failedToStart; a.informativeText = e ?? "Check settings."; NSApp.activate(ignoringOtherApps: true); a.runModal() }; self?.refreshUI() } }
        refreshUI()
    }

    @objc func showSettings() { if settingsWindow == nil { settingsWindow = SettingsWindowController() }; NSApp.activate(ignoringOtherApps: true); settingsWindow?.showWindow(nil) }
    @objc func showHelp() { if helpWindow == nil { helpWindow = HelpWindowController() }; NSApp.activate(ignoringOtherApps: true); helpWindow?.showWindow(nil) }
    @objc func showSpeedTest() { if speedTestWindow == nil { speedTestWindow = SpeedTestWindowController() }; NSApp.activate(ignoringOtherApps: true); speedTestWindow?.showWindow(nil) }
    @objc func showLogs() { if logWindow == nil { logWindow = LogWindowController() }; NSApp.activate(ignoringOtherApps: true); logWindow?.showWindow(nil) }
    
    @objc func runDiagnostics() {
        if loadingWindow == nil { loadingWindow = LoadingWindowController() }
        loadingWindow?.updateStatus(L10n.shared.diagChecking)
        loadingWindow?.showWithFade()
        
        DiagnosticsManager.shared.checkBypass { [weak self] success, error in
            DispatchQueue.main.async {
                self?.loadingWindow?.closeWithFade {
                    self?.loadingWindow = nil
                    let alert = NSAlert()
                    alert.messageText = success ? L10n.shared.diagSuccess : L10n.shared.diagFailed
                    alert.informativeText = error ?? ""
                    NSApp.activate(ignoringOtherApps: true)
                    alert.runModal()
                }
            }
        }
    }
    
    @objc func checkUpdate() { GitHubUpdater.shared.checkForUpdates(manual: true) }
    
    func applicationWillTerminate(_ notification: Notification) {
        DPIKillerManager.shared.fullCleanup()
    }

    private func setupSignalHandlers() {
        let signals = [SIGINT, SIGTERM]
        for sig in signals {
            signal(sig, SIG_IGN)
            let source = DispatchSource.makeSignalSource(signal: sig, queue: .main)
            source.setEventHandler { 
                DPIKillerManager.shared.fullCleanup()
                exit(0) 
            }
            source.resume()
        }
    }
}

// Ensure cleanup on any exit
atexit {
    DPIKillerManager.shared.fullCleanup()
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
