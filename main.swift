import Cocoa
import Foundation

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
    
    private func autoDetectBinaryPath() -> String {
        let paths = ["/opt/homebrew/bin/spoofdpi", "/usr/local/bin/spoofdpi", "/usr/bin/spoofdpi"]
        for path in paths {
            if FileManager.default.fileExists(atPath: path) { return path }
        }
        return "spoofdpi" // Fallback to PATH
    }
}

// MARK: - Spoof Manager
class SpoofManager {
    static let shared = SpoofManager()
    private var process: Process?
    private(set) var isRunning = false
    private var outputPipe: Pipe?
    var logHandler: ((String) -> Void)?
    
    func start(completion: @escaping (Bool, String?) -> Void) {
        if isRunning { stop() }
        isRunning = false
        
        let binaryPath = SettingsStore.shared.binaryPath
        // Check if it exists at the preferred path
        if !FileManager.default.fileExists(atPath: binaryPath) {
            completion(false, "NOT_INSTALLED")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: binaryPath)
        
        let rawArgs = SettingsStore.shared.customArgs
        let args = rawArgs.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        process.arguments = args
        
        let pipe = Pipe()
        self.outputPipe = pipe
        process.standardOutput = pipe
        process.standardError = pipe
        
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                DispatchQueue.main.async {
                    self?.logHandler?(str)
                }
            }
        }
        
        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isRunning = false
                self?.process = nil
                self?.outputPipe?.fileHandleForReading.readabilityHandler = nil
                self?.outputPipe = nil
                (NSApp.delegate as? AppDelegate)?.refreshUI()
            }
        }
        
        do {
            try process.run()
            self.process = process
            self.isRunning = true
            completion(true, nil)
        } catch {
            self.isRunning = false
            completion(false, error.localizedDescription)
        }
    }
    
    func install(completion: @escaping (Bool, String?) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/brew")
        if !FileManager.default.fileExists(atPath: "/opt/homebrew/bin/brew") {
            process.executableURL = URL(fileURLWithPath: "/usr/local/bin/brew")
        }
        
        process.arguments = ["install", "spoofdpi"]
        
        do {
            try process.run()
            process.terminationHandler = { proc in
                DispatchQueue.main.async {
                    if proc.terminationStatus == 0 {
                        completion(true, nil)
                    } else {
                        completion(false, "Homebrew failed with exit code \(proc.terminationStatus)")
                    }
                }
            }
        } catch {
            completion(false, error.localizedDescription)
        }
    }

    func stop() {
        isRunning = false
        process?.terminate()
        process = nil
        outputPipe?.fileHandleForReading.readabilityHandler = nil
        outputPipe = nil
        (NSApp.delegate as? AppDelegate)?.refreshUI()
    }
}

// MARK: - Windows
class SettingsWindowController: NSWindowController {
    var pathField: NSTextField!
    var argsField: NSTextField!
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.center()
        window.title = "Settings"
        self.init(window: window)
        setupUI()
    }
    
    func setupUI() {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
        window?.contentView = view
        
        let pathLabel = NSTextField(labelWithString: "Binary Path:")
        pathLabel.frame = NSRect(x: 20, y: 150, width: 100, height: 20)
        view.addSubview(pathLabel)
        
        pathField = NSTextField(frame: NSRect(x: 120, y: 150, width: 260, height: 22))
        pathField.stringValue = SettingsStore.shared.binaryPath
        view.addSubview(pathField)
        
        let argsLabel = NSTextField(labelWithString: "Arguments:")
        argsLabel.frame = NSRect(x: 20, y: 110, width: 100, height: 20)
        view.addSubview(argsLabel)
        
        argsField = NSTextField(frame: NSRect(x: 120, y: 110, width: 260, height: 22))
        argsField.stringValue = SettingsStore.shared.customArgs
        view.addSubview(argsField)
        
        let saveButton = NSButton(title: "Save & Restart", target: self, action: #selector(save))
        saveButton.frame = NSRect(x: 275, y: 20, width: 110, height: 32)
        view.addSubview(saveButton)
    }
    
    @objc func save() {
        SettingsStore.shared.binaryPath = pathField.stringValue
        SettingsStore.shared.customArgs = argsField.stringValue
        if SpoofManager.shared.isRunning {
            SpoofManager.shared.stop()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SpoofManager.shared.start { _, _ in 
                    (NSApp.delegate as? AppDelegate)?.refreshUI()
                }
            }
        }
        window?.close()
    }
}

class LogWindowController: NSWindowController {
    var textView: NSTextView!
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false)
        window.center()
        window.title = "Current Logs"
        self.init(window: window)
        setupUI()
        SpoofManager.shared.logHandler = { [weak self] text in
            self?.appendLog(text)
        }
    }
    func setupUI() {
        let scrollView = NSScrollView(frame: window!.contentView!.bounds)
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.width, .height]
        textView = NSTextView(frame: scrollView.bounds)
        textView.isEditable = false
        textView.backgroundColor = .black
        textView.textColor = .green
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.autoresizingMask = [.width]
        scrollView.documentView = textView
        window?.contentView?.addSubview(scrollView)
    }
    func appendLog(_ text: String) {
        let attrStr = NSAttributedString(string: text, attributes: [
            .foregroundColor: NSColor.green,
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        ])
        textView.textStorage?.append(attrStr)
        textView.scrollToEndOfDocument(nil)
    }
}

class LoadingWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 180),
            styleMask: [.borderless],
            backing: .buffered, defer: false)
        window.center()
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        self.init(window: window)
        setupUI()
    }
    func setupUI() {
        // Main container to ensure shadow follows the rounded shape
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 340, height: 180))
        container.wantsLayer = true
        container.layer?.cornerRadius = 32
        container.layer?.masksToBounds = true
        window?.contentView = container
        
        let visualEffect = NSVisualEffectView(frame: container.bounds)
        visualEffect.blendingMode = .behindWindow
        visualEffect.material = .underWindowBackground
        visualEffect.state = .active
        visualEffect.autoresizingMask = [.width, .height]
        container.addSubview(visualEffect)
        
        if let icon = NSApp.applicationIconImage {
            let iconView = NSImageView(frame: NSRect(x: 130, y: 85, width: 80, height: 80))
            iconView.image = icon
            container.addSubview(iconView)
        }
        
        let label = NSTextField(labelWithString: "SpoofController")
        label.font = NSFont.systemFont(ofSize: 22, weight: .semibold)
        label.frame = NSRect(x: 0, y: 55, width: 340, height: 30)
        label.alignment = .center
        container.addSubview(label)
        
        let sublabel = NSTextField(labelWithString: "Preparing your bypass... ⚡️")
        sublabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        sublabel.textColor = .secondaryLabelColor
        sublabel.frame = NSRect(x: 0, y: 35, width: 340, height: 20)
        sublabel.alignment = .center
        container.addSubview(sublabel)
        
        let indicator = NSProgressIndicator(frame: NSRect(x: 100, y: 15, width: 140, height: 20))
        indicator.style = .bar
        indicator.isIndeterminate = true
        indicator.startAnimation(nil)
        container.addSubview(indicator)
        
        // This ensures the shadow updates to match the layer-backed rounded view
        window?.invalidateShadow()
    }
    func showWithFade() {
        window?.alphaValue = 0
        showWindow(nil)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            window?.animator().alphaValue = 1.0
        }
    }
    func closeWithFade(completion: @escaping () -> Void) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            window?.animator().alphaValue = 0
        }, completionHandler: completion)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var settingsWindow: SettingsWindowController?
    var logWindow: LogWindowController?
    var loadingWindow: LoadingWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        refreshUI()
        
        loadingWindow = LoadingWindowController()
        loadingWindow?.showWithFade()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.attemptStart()
        }
    }

    func attemptStart() {
        SpoofManager.shared.start { [weak self] success, error in
            self?.loadingWindow?.closeWithFade {
                self?.loadingWindow = nil
                self?.refreshUI()
                
                if !success {
                    if error == "NOT_INSTALLED" {
                        self?.showInstallAlert()
                    } else {
                        let alert = NSAlert()
                        alert.messageText = "Failed to start"
                        alert.informativeText = error ?? "Check settings."
                        alert.runModal()
                        self?.showSettings()
                    }
                }
            }
        }
    }

    private func showInstallAlert() {
        let alert = NSAlert()
        alert.messageText = "Dependency Missing"
        alert.informativeText = "SpoofDPI is not installed. Would you like to install it via Homebrew?"
        alert.addButton(withTitle: "Install")
        alert.addButton(withTitle: "Quit")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            self.performInstallation()
        } else {
            NSApplication.shared.terminate(nil)
        }
    }

    private func performInstallation() {
        // Show a simple alert during installation
        let info = NSAlert()
        info.messageText = "Installing..."
        info.informativeText = "Please wait while we install spoofdpi via brew. This might take a minute."
        info.addButton(withTitle: "OK")
        info.runModal()
        
        SpoofManager.shared.install { [weak self] success, error in
            if success {
                let successAlert = NSAlert()
                successAlert.messageText = "Installation Complete"
                successAlert.informativeText = "SpoofDPI has been installed successfully. Starting service..."
                successAlert.runModal()
                self?.attemptStart()
            } else {
                let failAlert = NSAlert()
                failAlert.messageText = "Installation Failed"
                failAlert.informativeText = error ?? "Unknown error. Please install manually: 'brew install spoofdpi'"
                failAlert.runModal()
            }
        }
    }

    func refreshUI() {
        DispatchQueue.main.async { [weak self] in
            if let button = self?.statusItem?.button {
                button.image = self?.createStatusIcon(isRunning: SpoofManager.shared.isRunning)
                button.imagePosition = .imageOnly
            }
            self?.setupMenu()
        }
    }

    private func createStatusIcon(isRunning: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()
        
        if let appIcon = NSApp.applicationIconImage {
            appIcon.draw(in: NSRect(origin: .zero, size: size), from: .zero, operation: .sourceOver, fraction: 1.0)
        } else {
            NSColor.secondaryLabelColor.set()
            NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 14, height: 14)).fill()
        }
        
        // Status indicator (bottom-right) with offset
        let dotSize: CGFloat = 4.5
        let dotRect = NSRect(x: 12.5, y: 1.0, width: dotSize, height: dotSize)
        let dotPath = NSBezierPath(ovalIn: dotRect)
        
        // White outline for the dot
        NSColor.white.set()
        let whitePath = NSBezierPath(ovalIn: dotRect.insetBy(dx: -1.0, dy: -1.0))
        whitePath.fill()
        
        if isRunning {
            NSColor.systemGreen.set()
        } else {
            NSColor.systemRed.set()
        }
        dotPath.fill()
        
        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    func setupMenu() {
        let menu = NSMenu()
        let status = SpoofManager.shared.isRunning ? "Status: ACTIVE ✅" : "Status: STOPPED ❌"
        menu.addItem(NSMenuItem(title: status, action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: SpoofManager.shared.isRunning ? "Stop" : "Start", action: #selector(toggle), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "View Logs", action: #selector(showLogs), keyEquivalent: "l"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func toggle() {
        if SpoofManager.shared.isRunning {
            SpoofManager.shared.stop()
        } else {
            SpoofManager.shared.start { [weak self] success, error in
                if !success {
                    let alert = NSAlert()
                    alert.messageText = "Failed to start"
                    alert.informativeText = error ?? "Unknown error"
                    alert.runModal()
                }
                self?.refreshUI()
            }
        }
        refreshUI()
    }

    @objc func showSettings() { if settingsWindow == nil { settingsWindow = SettingsWindowController() }; NSApp.activate(ignoringOtherApps: true); settingsWindow?.showWindow(nil) }
    @objc func showLogs() { if logWindow == nil { logWindow = LogWindowController() }; NSApp.activate(ignoringOtherApps: true); logWindow?.showWindow(nil) }
    func applicationWillTerminate(_ notification: Notification) { SpoofManager.shared.stop() }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
