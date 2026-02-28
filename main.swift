import Cocoa
import Foundation
import WebKit

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
    
    var selectedFlags: Set<String> {
        let args = customArgs.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        return Set(args.filter { $0.hasPrefix("-") })
    }
    
    func updateArgs(with flags: Set<String>, manual: String) {
        let uniqueFlags = flags.joined(separator: " ")
        customArgs = "\(uniqueFlags) \(manual)".trimmingCharacters(in: .whitespaces)
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
            script = "tell application \"System Events\" to make login item at end with properties {path:\"\(appPath)\", hidden:false, name:\"SpoofController\"}"
        } else {
            script = "tell application \"System Events\" to delete (every login item whose name is \"SpoofController\")"
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        try? process.run()
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
    private(set) var logBuffer = ""
    
    func start(completion: @escaping (Bool, String?) -> Void) {
        if isRunning { stop() }
        isRunning = false
        logBuffer = ""
        
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
                    self?.logBuffer += str
                    // Keep buffer reasonable
                    if self?.logBuffer.count ?? 0 > 100000 {
                        self?.logBuffer = String(self?.logBuffer.suffix(50000) ?? "")
                    }
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
struct ArgumentOption {
    let flag: String
    let description: String
}

class SettingsWindowController: NSWindowController {
    var pathField: NSTextField!
    var manualArgsField: NSTextField!
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
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 460),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.center()
        window.title = L10n.shared.settingsTitle
        self.init(window: window)
        setupUI()
    }
    
    func setupUI() {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 450, height: 460))
        window?.contentView = view
        
        var currentY: CGFloat = 420
        
        // 1. Binary Path
        let pathLabel = NSTextField(labelWithString: L10n.shared.binaryPath)
        pathLabel.font = .systemFont(ofSize: 13, weight: .bold)
        pathLabel.frame = NSRect(x: 20, y: currentY, width: 200, height: 20)
        view.addSubview(pathLabel)
        currentY -= 30
        
        pathField = NSTextField(frame: NSRect(x: 20, y: currentY, width: 410, height: 24))
        pathField.stringValue = SettingsStore.shared.binaryPath
        pathField.placeholderString = L10n.shared.binaryPlaceholder
        view.addSubview(pathField)
        currentY -= 45
        
        // 2. Predefined Flags
        let flagsLabel = NSTextField(labelWithString: L10n.shared.argumentsTitle)
        flagsLabel.font = .systemFont(ofSize: 13, weight: .bold)
        flagsLabel.frame = NSRect(x: 20, y: currentY, width: 300, height: 20)
        view.addSubview(flagsLabel)
        currentY -= 25
        
        let selected = SettingsStore.shared.selectedFlags
        
        for option in options {
            let cb = NSButton(checkboxWithTitle: option.flag, target: nil, action: nil)
            cb.frame = NSRect(x: 20, y: currentY, width: 150, height: 20)
            cb.state = selected.contains(option.flag) ? .on : .off
            view.addSubview(cb)
            checkboxes.append(cb)
            
            let desc = NSTextField(labelWithString: "— \(option.description)")
            desc.font = .systemFont(ofSize: 11)
            desc.textColor = .secondaryLabelColor
            desc.frame = NSRect(x: 170, y: currentY, width: 260, height: 18)
            view.addSubview(desc)
            
            currentY -= 22
        }
        currentY -= 15
        
        // 3. Manual Args
        let manualLabel = NSTextField(labelWithString: L10n.shared.manualArgsTitle)
        manualLabel.font = .systemFont(ofSize: 13, weight: .bold)
        manualLabel.frame = NSRect(x: 20, y: currentY, width: 300, height: 20)
        view.addSubview(manualLabel)
        currentY -= 30
        
        manualArgsField = NSTextField(frame: NSRect(x: 20, y: currentY, width: 410, height: 24))
        // Filter out predefined flags to show only manual ones
        let allArgs = SettingsStore.shared.customArgs.components(separatedBy: .whitespaces)
        let manual = allArgs.filter { arg in !options.contains { $0.flag == arg } }.joined(separator: " ")
        manualArgsField.stringValue = manual.trimmingCharacters(in: .whitespaces)
        manualArgsField.placeholderString = L10n.shared.manualArgsPlaceholder
        view.addSubview(manualArgsField)
        currentY -= 45
        
        // 4. Launch at Login
        let loginLabel = NSTextField(labelWithString: L10n.shared.autoLaunchTitle)
        loginLabel.font = .systemFont(ofSize: 13, weight: .bold)
        loginLabel.frame = NSRect(x: 20, y: currentY, width: 300, height: 20)
        view.addSubview(loginLabel)
        currentY -= 25
        
        let loginCheckbox = NSButton(checkboxWithTitle: L10n.shared.launchAtLogin, target: self, action: #selector(toggleLoginItem))
        loginCheckbox.frame = NSRect(x: 20, y: currentY, width: 410, height: 20)
        loginCheckbox.state = SettingsStore.shared.launchAtLogin ? .on : .off
        view.addSubview(loginCheckbox)
        
        // 5. Save Button
        let saveButton = NSButton(title: L10n.shared.saveAndRestart, target: self, action: #selector(save))
        saveButton.frame = NSRect(x: 220, y: 20, width: 210, height: 32)
        saveButton.bezelStyle = .rounded
        view.addSubview(saveButton)
    }
    
    @objc func toggleLoginItem(_ sender: NSButton) {
        SettingsStore.shared.launchAtLogin = (sender.state == .on)
    }
    
    @objc func save() {
        var flags = Set<String>()
        for (index, cb) in checkboxes.enumerated() {
            if cb.state == .on {
                flags.insert(options[index].flag)
            }
        }
        
        SettingsStore.shared.binaryPath = pathField.stringValue
        SettingsStore.shared.updateArgs(with: flags, manual: manualArgsField.stringValue)
        
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
        window.title = L10n.shared.logs
        self.init(window: window)
        setupUI()
        
        // Load existing logs
        appendLog(SpoofManager.shared.logBuffer)
        
        SpoofManager.shared.logHandler = { [weak self] text in
            self?.appendLog(text)
        }
    }
    func setupUI() {
        let scrollView = NSScrollView(frame: window!.contentView!.bounds)
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.width, .height]
        
        let contentSize = scrollView.contentSize
        textView = NSTextView(frame: NSRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        textView.minSize = NSSize(width: 0.0, height: contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        
        textView.isEditable = false
        textView.backgroundColor = .black
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        
        textView.textContainer?.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        
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

class HelpWindowController: NSWindowController {
    var webView: WKWebView!
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false)
        window.center()
        window.title = L10n.shared.helpTitle
        self.init(window: window)
        setupUI()
        loadReadme()
    }
    
    func setupUI() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: window!.contentView!.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.setValue(false, forKey: "drawsBackground") // Transparent background
        
        window?.contentView?.addSubview(webView)
    }
    
    func loadReadme() {
        guard let path = Bundle.main.path(forResource: "README", ofType: "md"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            webView.loadHTMLString("<html><body>\(L10n.shared.isRussian ? "Инструкция недоступна." : "Manual not available.")</body></html>", baseURL: nil)
            return
        }
        
        let html = markdownToHTML(content)
        let styledHTML = """
        <html>
        <head>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    font-size: 14px;
                    line-height: 1.5;
                    color: #333;
                    padding: 20px 40px;
                    max-width: 850px;
                    margin: 0 auto;
                    background-color: transparent;
                }
                @media (prefers-color-scheme: dark) {
                    body { color: #eee; }
                    a { color: #4dabf7; }
                    code { background: #333; }
                    pre { background: #222; }
                }
                h1 { font-size: 24px; border-bottom: 1px solid #eee; padding-bottom: 8px; margin-top: 10px; }
                h2 { font-size: 19px; margin-top: 25px; margin-bottom: 10px; }
                h3 { font-size: 16px; margin-top: 20px; margin-bottom: 8px; }
                p, li { margin: 6px 0; }
                code { background: #f4f4f4; padding: 2px 5px; border-radius: 4px; font-family: "SF Mono", Menlo, monospace; font-size: 0.9em; }
                pre { background: #f8f9fa; padding: 12px; border-radius: 8px; overflow-x: auto; border: 1px solid #eee; }
                pre code { background: transparent; padding: 0; color: inherit; }
                a { color: #007aff; text-decoration: none; }
                a:hover { text-decoration: underline; }
                img { max-width: 100%; height: auto; border-radius: 8px; display: block; margin: 10px auto; }
                hr { border: 0; border-top: 1px solid #eee; margin: 20px 0; }
                blockquote { border-left: 4px solid #eee; padding-left: 15px; color: #666; font-style: italic; margin: 15px 0; }
            </style>
        </head>
        <body>
            \(html)
        </body>
        </html>
        """
        
        webView.loadHTMLString(styledHTML, baseURL: Bundle.main.resourceURL)
    }
    
    private func markdownToHTML(_ markdown: String) -> String {
        var result = ""
        let lines = markdown.components(separatedBy: .newlines)
        var inCodeBlock = false
        var codeContent = ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Code Blocks
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
            
            // Empty lines
            if trimmed.isEmpty {
                continue
            }
            
            // HTML tags (Preserve banner and other manual HTML)
            if trimmed.hasPrefix("<") {
                result += line + "\n"
                continue
            }
            
            // Headers
            if line.hasPrefix("# ") {
                result += "<h1>\(processInline(String(line.dropFirst(2))))</h1>\n"
                continue
            }
            if line.hasPrefix("## ") {
                result += "<h2>\(processInline(String(line.dropFirst(3))))</h2>\n"
                continue
            }
            if line.hasPrefix("### ") {
                result += "<h3>\(processInline(String(line.dropFirst(4))))</h3>\n"
                continue
            }
            
            // Horizontal Rule
            if trimmed == "---" {
                result += "<hr>\n"
                continue
            }
            
            // Lists (simple)
            if trimmed.hasPrefix("- ") {
                result += "<li>\(processInline(String(trimmed.dropFirst(2))))</li>\n"
                continue
            }
            
            // Paragraph
            result += "<p>\(processInline(line))</p>\n"
        }
        
        return result
    }
    
    private func processInline(_ text: String) -> String {
        var processed = text
        // Bold
        processed = processed.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "<b>$1</b>", options: .regularExpression, range: nil)
        // Inline Code
        processed = processed.replacingOccurrences(of: "`([^`]+)`", with: "<code>$1</code>", options: .regularExpression, range: nil)
        // Links
        processed = processed.replacingOccurrences(of: "\\[([^\\]]+)\\]\\(([^\\)]+)\\)", with: "<a href=\"$2\">$1</a>", options: .regularExpression, range: nil)
        // HTML tags preservation for those <a> in README
        // (Actually they'll just work if we don't escape them here)
        return processed
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
        
        let sublabel = NSTextField(labelWithString: L10n.shared.preparingBypass)
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
    var helpWindow: HelpWindowController?
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
                        alert.messageText = L10n.shared.failedToStart
                        alert.informativeText = error ?? (L10n.shared.isRussian ? "Проверьте настройки." : "Check settings.")
                        alert.runModal()
                        self?.showSettings()
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
        info.messageText = L10n.shared.installing
        info.informativeText = L10n.shared.pleaseWaitBrew
        info.addButton(withTitle: "OK")
        info.runModal()
        
        SpoofManager.shared.install { [weak self] success, error in
            if success {
                let successAlert = NSAlert()
                successAlert.messageText = L10n.shared.installComplete
                successAlert.informativeText = L10n.shared.installSuccess
                successAlert.runModal()
                self?.attemptStart()
            } else {
                let failAlert = NSAlert()
                failAlert.messageText = L10n.shared.installFailed
                failAlert.informativeText = error ?? L10n.shared.installManual
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
        let status = SpoofManager.shared.isRunning ? L10n.shared.statusActive : L10n.shared.statusStopped
        menu.addItem(NSMenuItem(title: status, action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: SpoofManager.shared.isRunning ? L10n.shared.stop : L10n.shared.start, action: #selector(toggle), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: L10n.shared.settings, action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: L10n.shared.logs, action: #selector(showLogs), keyEquivalent: "l"))
        menu.addItem(NSMenuItem(title: L10n.shared.instructions, action: #selector(showHelp), keyEquivalent: "h"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: L10n.shared.quit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func toggle() {
        if SpoofManager.shared.isRunning {
            SpoofManager.shared.stop()
        } else {
            SpoofManager.shared.start { [weak self] success, error in
                if !success {
                    let alert = NSAlert()
                    alert.messageText = L10n.shared.failedToStart
                    alert.informativeText = error ?? (L10n.shared.isRussian ? "Проверьте настройки." : "Check settings.")
                    alert.runModal()
                }
                self?.refreshUI()
            }
        }
        refreshUI()
    }

    @objc func showSettings() { if settingsWindow == nil { settingsWindow = SettingsWindowController() }; NSApp.activate(ignoringOtherApps: true); settingsWindow?.showWindow(nil as Any?) }
    @objc func showLogs() { if logWindow == nil { logWindow = LogWindowController() }; NSApp.activate(ignoringOtherApps: true); logWindow?.showWindow(nil as Any?) }
    @objc func showHelp() { if helpWindow == nil { helpWindow = HelpWindowController() }; NSApp.activate(ignoringOtherApps: true); helpWindow?.showWindow(nil as Any?) }
    func applicationWillTerminate(_ notification: Notification) { SpoofManager.shared.stop() }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
