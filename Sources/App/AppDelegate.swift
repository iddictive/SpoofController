import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var settingsWindow: SettingsWindowController?
    var helpWindow: HelpWindowController?
    var loadingWindow: LoadingWindowController?
    var speedTestWindow: SpeedTestWindowController?
    var logWindow: LogWindowController?

    private var iconCache: [Bool: NSImage] = [:]
    private var lastRefreshTime: Date = .distantPast
    private let refreshThrottleInterval: TimeInterval = 0.5
    private var refreshPending = false
    private var signalSources: [DispatchSourceSignal] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupSignalHandlers()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        refreshUI()

        if loadingWindow == nil {
            loadingWindow = LoadingWindowController()
        }
        loadingWindow?.updateStatus(L10n.shared.preparingBypass)
        loadingWindow?.showWithFade()

        DPIKillerManager.shared.recoverEnvironment { [weak self] in
            GitHubUpdater.shared.checkForUpdates()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.attemptStart()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        DPIKillerManager.shared.fullCleanup()
    }

    func attemptStart() {
        DPIKillerManager.shared.start { [weak self] success, error in
            self?.loadingWindow?.closeWithFade {
                self?.loadingWindow = nil
                self?.refreshUI()
                if !success {
                    if error == "NOT_INSTALLED" {
                        self?.showInstallAlert()
                    } else {
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

    func refreshUI() {
        let now = Date()
        if now.timeIntervalSince(lastRefreshTime) < refreshThrottleInterval {
            if !refreshPending {
                refreshPending = true
                DispatchQueue.main.asyncAfter(deadline: .now() + refreshThrottleInterval) { [weak self] in
                    self?.refreshPending = false
                    self?.refreshUI()
                }
            }
            return
        }
        lastRefreshTime = now

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let button = self.statusItem?.button {
                let running = DPIKillerManager.shared.isRunning
                if self.iconCache[running] == nil {
                    self.iconCache[running] = self.createStatusIcon(isRunning: running)
                }
                button.image = self.iconCache[running]
                button.imagePosition = .imageOnly
            }
            self.setupMenu()
        }
    }

    @objc func toggle() {
        if DPIKillerManager.shared.isRunning {
            DPIKillerManager.shared.stop()
        } else {
            DPIKillerManager.shared.start { [weak self] success, error in
                if !success {
                    let alert = NSAlert()
                    alert.messageText = L10n.shared.failedToStart
                    alert.informativeText = error ?? "Check settings."
                    NSApp.activate(ignoringOtherApps: true)
                    alert.runModal()
                }
                self?.refreshUI()
            }
        }
        refreshUI()
    }

    @objc func showSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindowController()
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.showWindow(nil)
    }

    @objc func showHelp() {
        if helpWindow == nil {
            helpWindow = HelpWindowController()
        }
        NSApp.activate(ignoringOtherApps: true)
        helpWindow?.showWindow(nil)
    }

    @objc func showSpeedTest() {
        if speedTestWindow == nil {
            speedTestWindow = SpeedTestWindowController()
        }
        NSApp.activate(ignoringOtherApps: true)
        speedTestWindow?.showWindow(nil)
    }

    @objc func showLogs() {
        if logWindow == nil {
            logWindow = LogWindowController()
        }
        NSApp.activate(ignoringOtherApps: true)
        logWindow?.showWindow(nil)
    }

    @objc func runDiagnostics() {
        if loadingWindow == nil {
            loadingWindow = LoadingWindowController()
        }
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

    @objc func checkUpdate() {
        GitHubUpdater.shared.checkForUpdates(manual: true)
    }

    private func showInstallAlert() {
        let alert = NSAlert()
        alert.messageText = L10n.shared.dependencyMissing
        alert.informativeText = L10n.shared.spoofDpiNeeded
        alert.addButton(withTitle: L10n.shared.install)
        alert.addButton(withTitle: L10n.shared.quit)

        NSApp.activate(ignoringOtherApps: true)
        if let window = loadingWindow?.window ?? settingsWindow?.window {
            alert.beginSheetModal(for: window) { response in
                if response == .alertFirstButtonReturn {
                    self.performInstallation()
                } else {
                    NSApp.terminate(nil)
                }
            }
        } else if alert.runModal() == .alertFirstButtonReturn {
            performInstallation()
        } else {
            NSApp.terminate(nil)
        }
    }

    private func performInstallation() {
        if loadingWindow == nil {
            loadingWindow = LoadingWindowController()
        }
        loadingWindow?.updateStatus(L10n.shared.installing, showCancel: true)
        loadingWindow?.setProgressIndeterminate(true)
        loadingWindow?.cancelHandler = { [weak self] in
            DPIKillerManager.shared.cancelInstall()
            self?.loadingWindow?.closeWithFade {
                self?.loadingWindow = nil
                self?.refreshUI()
            }
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
                    if let error {
                        let fail = NSAlert()
                        fail.messageText = L10n.shared.installFailed
                        fail.informativeText = error
                        NSApp.activate(ignoringOtherApps: true)
                        fail.runModal()
                    }
                }
            }
        }
    }

    private func createStatusIcon(isRunning: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()

        if let appIcon = NSApp.applicationIconImage {
            appIcon.draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .sourceOver, fraction: 1)
        } else {
            NSColor.secondaryLabelColor.set()
            NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 14, height: 14)).fill()
        }

        let dotRect = NSRect(x: 12.5, y: 1.0, width: 4.5, height: 4.5)
        NSColor.white.set()
        NSBezierPath(ovalIn: dotRect.insetBy(dx: -1, dy: -1)).fill()
        (isRunning ? NSColor.systemGreen : NSColor.systemRed).set()
        NSBezierPath(ovalIn: dotRect).fill()
        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    private func setupMenu() {
        let menu = NSMenu()
        let status = DPIKillerManager.shared.isRunning ? L10n.shared.statusActive : L10n.shared.statusStopped
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

    private func setupSignalHandlers() {
        let signals = [SIGINT, SIGTERM]
        signalSources.removeAll()
        for signalNumber in signals {
            signal(signalNumber, SIG_IGN)
            let source = DispatchSource.makeSignalSource(signal: signalNumber, queue: .main)
            source.setEventHandler {
                DPIKillerManager.shared.fullCleanup()
                exit(0)
            }
            source.resume()
            signalSources.append(source)
        }
    }
}
