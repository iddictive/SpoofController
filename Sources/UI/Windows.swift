import Cocoa
import Foundation
import WebKit

struct ArgumentOption {
    let flag: String
    let description: String
}

final class SettingsWindowController: NSWindowController {
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
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let width = max(560, min(680, screen.width * 0.40))
        let height = max(620, min(780, screen.height * 0.78))

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.shared.settingsTitle
        AppTheme.styleWindow(window, minSize: NSSize(width: 560, height: 620))
        self.init(window: window)
        setupUI()
    }

    func setupUI() {
        let background = AppTheme.makeWindowBackground()
        window?.contentView = background

        let rootStack = NSStackView()
        rootStack.orientation = .vertical
        rootStack.spacing = 14
        rootStack.alignment = .leading
        background.addSubview(rootStack)
        rootStack.fill(parent: background, padding: 20)

        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 420).isActive = true

        let footerStack = NSStackView()
        footerStack.orientation = .horizontal
        footerStack.spacing = 10
        footerStack.alignment = .centerY

        let cancelBtn = NSButton(title: L10n.shared.cancel, target: self, action: #selector(cancelAction))
        AppTheme.styleSecondaryButton(cancelBtn)

        let saveButton = NSButton(title: L10n.shared.saveAndRestart, target: self, action: #selector(save))
        saveButton.keyEquivalent = "\r"
        AppTheme.stylePrimaryButton(saveButton)

        footerStack.addArrangedSubview(NSView())
        footerStack.addArrangedSubview(cancelBtn)
        footerStack.addArrangedSubview(saveButton)

        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = contentView

        let mainStack = NSStackView()
        mainStack.orientation = .vertical
        mainStack.spacing = 22
        mainStack.alignment = .leading
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.addArrangedSubview(scrollView)
        let footerSeparator = AppTheme.makeSeparator()
        rootStack.addArrangedSubview(footerSeparator)
        rootStack.addArrangedSubview(footerStack)

        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: rootStack.widthAnchor),
            footerSeparator.widthAnchor.constraint(equalTo: rootStack.widthAnchor),
            footerStack.widthAnchor.constraint(equalTo: rootStack.widthAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        func addSection(_ section: NSView) {
            mainStack.addArrangedSubview(section)
            section.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        }

        let coreSection = createSection(
            title: L10n.shared.sectionCore,
            subtitle: L10n.shared.isRussian ? "Где брать `spoofdpi` и как запускать его с нужными аргументами." : "Where `spoofdpi` is loaded from and how it is launched."
        )
        pathField = themedTextField(value: SettingsStore.shared.binaryPath, placeholder: L10n.shared.binaryPlaceholder)
        addRow(label: L10n.shared.binaryPath, control: pathField, to: coreSection, tooltip: L10n.shared.tipBinaryPath)
        addSection(coreSection)

        let networkSection = createSection(
            title: L10n.shared.sectionNetwork,
            subtitle: L10n.shared.isRussian ? "Локальный порт, хотспот и быстрые пресеты под мобильную раздачу." : "Local port, hotspot state, and mobile tethering presets."
        )

        let statusRow = NSStackView()
        statusRow.orientation = .horizontal
        statusRow.spacing = 10
        statusRow.alignment = .centerY
        let statusTitle = NSTextField(labelWithString: L10n.shared.hotspotStatusTitle)
        statusTitle.font = .systemFont(ofSize: 12, weight: .medium)
        statusTitle.textColor = AppTheme.textSecondary
        hotspotStatusLabel = NSTextField(labelWithString: L10n.shared.diagChecking)
        hotspotStatusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusRow.addArrangedSubview(statusTitle)
        statusRow.addArrangedSubview(hotspotStatusLabel)
        networkSection.addArrangedSubview(statusRow)
        statusRow.widthAnchor.constraint(equalTo: networkSection.widthAnchor).isActive = true

        let hotspotActions = NSStackView()
        hotspotActions.orientation = .horizontal
        hotspotActions.spacing = 12
        hotspotActions.alignment = .centerY
        hotspotFixButton = NSButton(title: L10n.shared.fixHotspotButton, target: self, action: #selector(fixHotspotAction))
        AppTheme.styleSecondaryButton(hotspotFixButton)
        hotspotFixButton.isHidden = true

        let presetBtn = NSButton(title: L10n.shared.mobilePresetTitle, target: self, action: #selector(applyMobilePreset))
        AppTheme.stylePrimaryButton(presetBtn)
        hotspotActions.addArrangedSubview(hotspotFixButton)
        hotspotActions.addArrangedSubview(presetBtn)
        networkSection.addArrangedSubview(hotspotActions)
        hotspotActions.widthAnchor.constraint(equalTo: networkSection.widthAnchor).isActive = true

        portField = themedTextField(value: SettingsStore.shared.localPort, placeholder: L10n.shared.portPlaceholder, width: 120)
        addRow(label: L10n.shared.portTitle, control: portField, to: networkSection, tooltip: L10n.shared.tipLocalPort)
        addSection(networkSection)
        updateHotspotStatus()

        let dpiSection = createSection(
            title: L10n.shared.sectionDPI,
            subtitle: L10n.shared.isRussian ? "Комбинируй strategy flags и численные параметры, не лезя в терминал." : "Blend strategy flags and tuning values without touching the terminal."
        )
        let selected = SettingsStore.shared.selectedFlags
        for option in options {
            let cb = NSButton(checkboxWithTitle: option.flag, target: nil, action: nil)
            cb.state = selected.contains(option.flag) ? .on : .off
            cb.font = .systemFont(ofSize: 13, weight: .medium)
            checkboxes.append(cb)

            let row = NSStackView()
            row.orientation = .horizontal
            row.spacing = 12
            row.alignment = .firstBaseline

            let spacer = NSView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.widthAnchor.constraint(equalToConstant: 140).isActive = true
            row.addArrangedSubview(spacer)
            row.addArrangedSubview(cb)

            let desc = NSTextField(wrappingLabelWithString: option.description)
            desc.font = .systemFont(ofSize: 12, weight: .regular)
            desc.textColor = AppTheme.textSecondary
            row.addArrangedSubview(desc)
            dpiSection.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: dpiSection.widthAnchor).isActive = true
        }

        ttlField = themedTextField(value: SettingsStore.shared.defaultTTL, placeholder: L10n.shared.ttlPlaceholder, width: 90)
        addRow(label: L10n.shared.ttlTitle, control: ttlField, to: dpiSection, tooltip: L10n.shared.tipTTL)

        splitModeButton = themedPopup(items: ["sni", "random", "chunk", "none"], selected: SettingsStore.shared.splitMode)
        addRow(label: L10n.shared.splitModeTitle, control: splitModeButton, to: dpiSection, tooltip: L10n.shared.tipSplitMode)

        let disorderStack = NSStackView()
        disorderStack.orientation = .horizontal
        disorderStack.spacing = 12
        disorderStack.alignment = .centerY

        let disorderSpacer = NSView()
        disorderSpacer.translatesAutoresizingMaskIntoConstraints = false
        disorderSpacer.widthAnchor.constraint(equalToConstant: 140).isActive = true
        disorderStack.addArrangedSubview(disorderSpacer)

        httpsDisorderButton = NSButton(checkboxWithTitle: L10n.shared.httpsDisorder, target: nil, action: nil)
        httpsDisorderButton.state = SettingsStore.shared.httpsDisorder ? .on : .off
        httpsDisorderButton.font = .systemFont(ofSize: 13, weight: .medium)
        disorderStack.addArrangedSubview(httpsDisorderButton)

        let fakeLabel = NSTextField(labelWithString: L10n.shared.httpsFakeCount)
        fakeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        fakeLabel.textColor = AppTheme.textSecondary
        httpsFakeCountField = themedTextField(value: SettingsStore.shared.httpsFakeCount, placeholder: "0", width: 68)

        let fakeStack = NSStackView()
        fakeStack.orientation = .horizontal
        fakeStack.spacing = 8
        fakeStack.alignment = .centerY
        fakeStack.addArrangedSubview(fakeLabel)
        fakeStack.addArrangedSubview(httpsFakeCountField)
        disorderStack.addArrangedSubview(NSView())
        disorderStack.addArrangedSubview(fakeStack)
        dpiSection.addArrangedSubview(disorderStack)
        disorderStack.widthAnchor.constraint(equalTo: dpiSection.widthAnchor).isActive = true

        httpsChunkSizeField = themedTextField(value: SettingsStore.shared.httpsChunkSize, placeholder: L10n.shared.httpsChunkPlaceholder, width: 90)
        addRow(label: L10n.shared.httpsChunkSize, control: httpsChunkSizeField, to: dpiSection, tooltip: L10n.shared.tipChunkSize)
        addSection(dpiSection)

        let dnsSection = createSection(
            title: L10n.shared.sectionDNS,
            subtitle: L10n.shared.isRussian ? "Поднимай собственный DNS path, включая HTTPS mode." : "Swap DNS transport and resolver endpoint without leaving the app."
        )
        dnsAddrField = themedTextField(value: SettingsStore.shared.dnsAddr, placeholder: "8.8.8.8:53")
        addRow(label: L10n.shared.dnsAddrTitle, control: dnsAddrField, to: dnsSection, tooltip: L10n.shared.tipDNSAddr)

        dnsModeButton = themedPopup(items: ["udp", "https", "system"], selected: SettingsStore.shared.dnsMode)
        addRow(label: L10n.shared.dnsModeTitle, control: dnsModeButton, to: dnsSection, tooltip: L10n.shared.tipDNSSystem)

        dnsHttpsUrlField = themedTextField(value: SettingsStore.shared.dnsHttpsUrl, placeholder: "https://dns.google/dns-query")
        addRow(label: "DoH URL", control: dnsHttpsUrlField, to: dnsSection)
        addSection(dnsSection)

        let appSection = createSection(
            title: L10n.shared.sectionApp,
            subtitle: L10n.shared.isRussian ? "Поведением клиента, апдейтами и reconnect управляем здесь." : "Client behavior, updates, and reconnect live here."
        )
        let loginCb = NSButton(checkboxWithTitle: L10n.shared.launchAtLogin, target: self, action: #selector(toggleLoginItem))
        loginCb.state = SettingsStore.shared.launchAtLogin ? .on : .off
        addCheckboxRow(button: loginCb, to: appSection)

        let updateCb = NSButton(checkboxWithTitle: L10n.shared.autoUpdateToggle, target: self, action: #selector(toggleUpdateItem))
        updateCb.state = SettingsStore.shared.autoUpdate ? .on : .off
        addCheckboxRow(button: updateCb, to: appSection)

        let ipv6Cb = NSButton(checkboxWithTitle: L10n.shared.disableIpv6, target: self, action: #selector(toggleIpv6))
        ipv6Cb.state = SettingsStore.shared.disableIpv6 ? .on : .off
        addCheckboxRow(button: ipv6Cb, to: appSection)

        let reconnectCb = NSButton(checkboxWithTitle: L10n.shared.autoReconnect, target: self, action: #selector(toggleReconnect))
        reconnectCb.state = SettingsStore.shared.autoReconnect ? .on : .off
        reconnectCb.toolTip = L10n.shared.tipAutoReconnect
        addCheckboxRow(button: reconnectCb, to: appSection)
        addSection(appSection)

        let manualSection = createSection(
            title: L10n.shared.sectionManual,
            subtitle: L10n.shared.isRussian ? "Для редких edge-case флагов, которые ещё не покрыты UI." : "For edge-case flags that still deserve a manual override."
        )
        manualArgsField = themedTextField(value: manualArgsValue(), placeholder: L10n.shared.manualArgsPlaceholder)
        manualSection.addArrangedSubview(manualArgsField)
        manualArgsField.widthAnchor.constraint(equalTo: manualSection.widthAnchor).isActive = true
        addSection(manualSection)
    }

    private func createSection(title: String, subtitle: String) -> NSStackView {
        let section = NSStackView()
        section.orientation = .vertical
        section.spacing = 12
        section.alignment = .leading
        section.translatesAutoresizingMaskIntoConstraints = false
        section.addArrangedSubview(sectionHeader(title: title, subtitle: subtitle))
        return section
    }

    private func sectionHeader(title: String, subtitle: String) -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 0
        stack.alignment = .leading

        let titleLabel = AppTheme.makeSectionTitle(title)
        stack.addArrangedSubview(titleLabel)
        return stack
    }

    private func themedTextField(value: String, placeholder: String, width: CGFloat? = nil) -> NSTextField {
        let field = NSTextField()
        field.stringValue = value
        field.placeholderString = placeholder
        AppTheme.styleInput(field)
        field.translatesAutoresizingMaskIntoConstraints = false
        if let width {
            field.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        return field
    }

    private func themedPopup(items: [String], selected: String) -> NSPopUpButton {
        let popup = NSPopUpButton(frame: .zero, pullsDown: false)
        popup.addItems(withTitles: items)
        popup.selectItem(withTitle: selected)
        AppTheme.styleInput(popup)
        popup.translatesAutoresizingMaskIntoConstraints = false
        return popup
    }

    private func addRow(label: String, control: NSView, to stack: NSStackView, tooltip: String? = nil) {
        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 12

        let labelView = NSTextField(labelWithString: label)
        labelView.font = .systemFont(ofSize: 12, weight: .medium)
        labelView.textColor = AppTheme.textSecondary
        labelView.alignment = .right
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.widthAnchor.constraint(equalToConstant: 140).isActive = true

        if let tooltip {
            control.toolTip = tooltip
        }

        control.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        row.addArrangedSubview(labelView)
        row.addArrangedSubview(control)
        stack.addArrangedSubview(row)
        row.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
    }

    private func addCheckboxRow(button: NSButton, to stack: NSStackView) {
        button.font = .systemFont(ofSize: 13, weight: .regular)

        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 12
        row.alignment = .centerY

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.widthAnchor.constraint(equalToConstant: 140).isActive = true
        row.addArrangedSubview(spacer)
        row.addArrangedSubview(button)
        stack.addArrangedSubview(row)
        row.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
    }

    private func manualArgsValue() -> String {
        let allArgs = SettingsStore.shared.customArgs.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        var manualParts: [String] = []
        var index = 0
        while index < allArgs.count {
            let arg = allArgs[index]
            if [
                "--default-ttl",
                "--https-split-mode",
                "--listen-addr",
                "--dns-addr",
                "--dns-mode",
                "--dns-https-url",
                "--https-disorder",
                "--https-fake-count",
                "--https-chunk-size"
            ].contains(arg) {
                index += 1
                if index < allArgs.count && !allArgs[index].hasPrefix("-") {
                    index += 1
                }
            } else if options.contains(where: { $0.flag == arg }) {
                index += 1
            } else {
                manualParts.append(arg)
                index += 1
            }
        }
        return manualParts.joined(separator: " ")
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
        if getSystemTTL() != 65 {
            fixHotspotAction()
        }
    }

    @objc func fixHotspotAction() {
        let script = "do shell script \"sysctl -w net.inet.ip.ttl=65 && sysctl -w net.inet6.ip6.hlim=65\" with administrator privileges"
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)

        if let error {
            AppLogger.log("AppleScript Error: \(error)")
            let alert = NSAlert()
            alert.messageText = L10n.shared.fixHotspotFailed
            alert.informativeText = "\(error["NSAppleScriptErrorMessage"] ?? "Unknown error")"
            alert.runModal()
        } else {
            updateHotspotStatus()
        }
    }

    func updateHotspotStatus() {
        let ttl = getSystemTTL()
        if ttl == 65 {
            hotspotStatusLabel.stringValue = L10n.shared.hotspotStatusOptimized
            hotspotStatusLabel.textColor = AppTheme.success
            hotspotFixButton.isHidden = true
        } else {
            hotspotStatusLabel.stringValue = L10n.shared.hotspotStatusThrottled
            hotspotStatusLabel.textColor = AppTheme.warning
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
            if let output = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               let value = Int(output) {
                return value
            }
        } catch {
            return 64
        }
        return 64
    }

    @objc func toggleLoginItem(_ sender: NSButton) {
        SettingsStore.shared.launchAtLogin = sender.state == .on
    }

    @objc func toggleDownloadItem(_ sender: NSButton) {
        SettingsStore.shared.autoDownload = sender.state == .on
    }

    @objc func toggleUpdateItem(_ sender: NSButton) {
        SettingsStore.shared.autoUpdate = sender.state == .on
    }

    @objc func toggleReconnect(_ sender: NSButton) {
        SettingsStore.shared.autoReconnect = sender.state == .on
    }

    @objc func toggleIpv6(_ sender: NSButton) {
        SettingsStore.shared.disableIpv6 = sender.state == .on
    }

    @objc func save() {
        var flags = Set<String>()
        for (index, checkbox) in checkboxes.enumerated() where checkbox.state == .on {
            flags.insert(options[index].flag)
        }

        let clampedPort = (Int(portField.stringValue.trimmingCharacters(in: .whitespaces)) ?? 8080).clamped(to: 1...65535)
        let clampedTTL = (Int(ttlField.stringValue.trimmingCharacters(in: .whitespaces)) ?? 128).clamped(to: 1...255)
        let clampedFakeCount = (Int(httpsFakeCountField.stringValue.trimmingCharacters(in: .whitespaces)) ?? 0).clamped(to: 0...100)
        let clampedChunkSize = (Int(httpsChunkSizeField.stringValue.trimmingCharacters(in: .whitespaces)) ?? 100).clamped(to: 1...1000)

        SettingsStore.shared.binaryPath = pathField.stringValue
        SettingsStore.shared.defaultTTL = String(clampedTTL)
        SettingsStore.shared.splitMode = splitModeButton.titleOfSelectedItem ?? "sni"
        SettingsStore.shared.httpsDisorder = httpsDisorderButton.state == .on
        SettingsStore.shared.httpsFakeCount = String(clampedFakeCount)
        SettingsStore.shared.httpsChunkSize = String(clampedChunkSize)
        SettingsStore.shared.localPort = String(clampedPort)
        SettingsStore.shared.dnsAddr = dnsAddrField.stringValue.trimmingCharacters(in: .whitespaces)
        SettingsStore.shared.dnsMode = dnsModeButton.titleOfSelectedItem ?? "udp"
        SettingsStore.shared.dnsHttpsUrl = dnsHttpsUrlField.stringValue.trimmingCharacters(in: .whitespaces)

        SettingsStore.shared.updateArgs(
            with: flags,
            manual: manualArgsField.stringValue,
            ttl: SettingsStore.shared.defaultTTL,
            splitMode: SettingsStore.shared.splitMode,
            splitPos: "1",
            port: SettingsStore.shared.localPort,
            dnsAddr: SettingsStore.shared.dnsAddr,
            dnsMode: SettingsStore.shared.dnsMode,
            dnsHttpsUrl: SettingsStore.shared.dnsHttpsUrl
        )

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

final class SpeedTestWindowController: NSWindowController, NSWindowDelegate {
    private var pingCard: MetricCardView!
    private var downloadCard: MetricCardView!
    private var uploadCard: MetricCardView!
    private var progressIndicator: NSProgressIndicator!
    private var startButton: NSButton!
    private var stageLabel: NSTextField!

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 400),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.shared.speedTest
        AppTheme.styleWindow(window, minSize: NSSize(width: 620, height: 360))
        self.init(window: window)
        window.delegate = self
        setupUI()
    }

    private func setupUI() {
        let background = AppTheme.makeWindowBackground()
        window?.contentView = background

        let contentStack = NSStackView()
        contentStack.orientation = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .leading
        background.addSubview(contentStack)
        contentStack.fill(parent: background, padding: 20)

        stageLabel = AppTheme.makeSecondaryText(
            L10n.shared.isRussian
                ? "Cloudflare probe через текущую сетевую цепочку приложения."
                : "Cloudflare probe routed through the app's current network chain."
        )
        contentStack.addArrangedSubview(stageLabel)

        pingCard = metricContainer(title: L10n.shared.ping, unit: L10n.shared.ms)
        downloadCard = metricContainer(title: L10n.shared.download, unit: L10n.shared.mbps)
        uploadCard = metricContainer(title: L10n.shared.upload, unit: L10n.shared.mbps)

        let metrics = NSGridView(views: [[pingCard!, downloadCard!, uploadCard!]])
        metrics.rowSpacing = 0
        metrics.columnSpacing = 16
        metrics.translatesAutoresizingMaskIntoConstraints = false

        progressIndicator = NSProgressIndicator()
        progressIndicator.style = .bar
        progressIndicator.isIndeterminate = true
        progressIndicator.startAnimation(nil)
        progressIndicator.isHidden = true
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false

        startButton = NSButton(title: L10n.shared.startTest, target: self, action: #selector(startClicked))
        AppTheme.stylePrimaryButton(startButton)

        let actions = NSStackView()
        actions.orientation = .horizontal
        actions.spacing = 0
        actions.alignment = .centerY
        actions.addArrangedSubview(NSView())
        actions.addArrangedSubview(startButton)

        contentStack.addArrangedSubview(metrics)
        contentStack.addArrangedSubview(progressIndicator)
        contentStack.addArrangedSubview(actions)

        NSLayoutConstraint.activate([
            metrics.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            progressIndicator.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            actions.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 220),
            startButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func metricContainer(title: String, unit: String) -> MetricCardView {
        let card = MetricCardView(title: title, unit: unit)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return card
    }

    @objc private func startClicked() {
        if startButton.title == L10n.shared.startTest {
            startButton.title = L10n.shared.stopTest
            progressIndicator.isHidden = false
            progressIndicator.startAnimation(nil)
            stageLabel.stringValue = L10n.shared.testingPing

            SpeedTestManager.shared.onUpdate = { [weak self] ping, down, up in
                DispatchQueue.main.async {
                    self?.pingCard.update(value: "\(Int(ping))")
                    self?.downloadCard.update(value: String(format: "%.2f", down))
                    self?.uploadCard.update(value: String(format: "%.2f", up))
                    if up > 0 {
                        self?.stageLabel.stringValue = L10n.shared.testingUpload
                    } else if down > 0 {
                        self?.stageLabel.stringValue = L10n.shared.testingDownload
                    }
                }
            }

            SpeedTestManager.shared.onFinished = { [weak self] in
                DispatchQueue.main.async {
                    self?.startButton.title = L10n.shared.startTest
                    self?.progressIndicator.stopAnimation(nil)
                    self?.progressIndicator.isHidden = true
                    self?.stageLabel.stringValue = L10n.shared.isRussian ? "Тест завершён." : "Test complete."
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
                    self?.progressIndicator.isHidden = true
                    self?.stageLabel.stringValue = error
                }
            }

            SpeedTestManager.shared.startTest()
        } else {
            SpeedTestManager.shared.stopTest()
        }
    }

    func windowWillClose(_ notification: Notification) {
        SpeedTestManager.shared.onUpdate = nil
        SpeedTestManager.shared.onFinished = nil
        SpeedTestManager.shared.onError = nil
        SpeedTestManager.shared.stopTest()
        (NSApp.delegate as? AppDelegate)?.speedTestWindow = nil
    }
}

final class LogWindowController: NSWindowController, NSWindowDelegate {
    private var textView: NSTextView!
    private var scrollView: NSScrollView!
    private var liveBadge: NSView!

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 460),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.shared.logsTitle
        AppTheme.styleWindow(window, minSize: NSSize(width: 620, height: 380))
        self.init(window: window)
        window.delegate = self
        setupUI()
    }

    override func showWindow(_ sender: Any?) {
        beginObservingLogs()
        super.showWindow(sender)
        updateLogs()
    }

    private func setupUI() {
        let background = AppTheme.makeWindowBackground()
        window?.contentView = background

        let contentStack = NSStackView()
        contentStack.orientation = .vertical
        contentStack.spacing = 14
        contentStack.alignment = .leading
        background.addSubview(contentStack)
        contentStack.fill(parent: background, padding: 20)

        let subtitle = AppTheme.makeSecondaryText(
            L10n.shared.isRussian
                ? "Живой circular buffer без спама в память."
                : "Live circular buffer without runaway memory growth."
        )
        liveBadge = AppTheme.makeStatusBadge(text: "STREAMING", color: AppTheme.accentSoft)
        contentStack.addArrangedSubview(subtitle)
        contentStack.addArrangedSubview(liveBadge)

        scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        textView = NSTextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.drawsBackground = false
        textView.textColor = AppTheme.textPrimary
        textView.textContainerInset = NSSize(width: 8, height: 10)
        scrollView.documentView = textView
        contentStack.addArrangedSubview(scrollView)
        scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 260).isActive = true

        let actions = NSStackView()
        actions.orientation = .horizontal
        actions.spacing = 12
        actions.alignment = .centerY

        let clearBtn = NSButton(title: L10n.shared.clearLogs, target: self, action: #selector(clearLogs))
        AppTheme.styleSecondaryButton(clearBtn)
        let copyBtn = NSButton(title: L10n.shared.copyLogs, target: self, action: #selector(copyLogs))
        AppTheme.stylePrimaryButton(copyBtn)
        actions.addArrangedSubview(NSView())
        actions.addArrangedSubview(clearBtn)
        actions.addArrangedSubview(copyBtn)
        contentStack.addArrangedSubview(actions)

        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            actions.widthAnchor.constraint(equalTo: contentStack.widthAnchor)
        ])
    }

    private func beginObservingLogs() {
        LogStore.shared.setProcessCaptureEnabled(true)
        LogStore.shared.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateLogs()
            }
        }
    }

    private func endObservingLogs() {
        LogStore.shared.setProcessCaptureEnabled(false)
        LogStore.shared.onUpdate = nil
    }

    private func updateLogs() {
        guard window?.isVisible == true else { return }
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
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(LogStore.shared.getAllLogs(), forType: .string)
    }

    func windowWillClose(_ notification: Notification) {
        endObservingLogs()
        textView.string = ""
        (NSApp.delegate as? AppDelegate)?.logWindow = nil
    }
}

final class HelpWindowController: NSWindowController {
    var webView: WKWebView!

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 780, height: 620),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.shared.helpTitle
        AppTheme.styleWindow(window, minSize: NSSize(width: 660, height: 500))
        self.init(window: window)
        setupUI()
        loadReadme()
    }

    func setupUI() {
        let background = AppTheme.makeWindowBackground()
        window?.contentView = background

        webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        webView.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(webView)
        webView.fill(parent: background, padding: 16)
    }

    func loadReadme() {
        guard let path = Bundle.main.path(forResource: "README", ofType: "md"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            webView.loadHTMLString(
                "<html><body>\(L10n.shared.isRussian ? "Инструкция недоступна." : "Manual not available.")</body></html>",
                baseURL: nil
            )
            return
        }

        let html = markdownToHTML(content)
        let styledHTML = """
        <html>
        <head>
        <style>
        :root { color-scheme: light dark; }
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; font-size: 15px; line-height: 1.65; padding: 24px 28px; color: #1d1d1f; background: #ffffff; }
        a { color: #0a84ff; }
        h1, h2, h3 { color: #1d1d1f; }
        h1 { font-size: 28px; border-bottom: 1px solid #d2d2d7; padding-bottom: 10px; }
        h2 { margin-top: 30px; }
        pre { background: #f5f5f7; padding: 14px; border-radius: 10px; overflow-x: auto; border: 1px solid #d2d2d7; }
        code { background: #f5f5f7; padding: 2px 5px; border-radius: 4px; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
        img { max-width: 100%; border-radius: 8px; border: 1px solid #d2d2d7; }
        li { margin: 6px 0; }
        hr { border: none; height: 1px; background: #d2d2d7; }
        @media (prefers-color-scheme: dark) {
        body { color: #f5f5f7; background: #1c1c1e; }
        a { color: #4ea1ff; }
        h1, h2, h3 { color: #ffffff; }
        h1 { border-bottom-color: #3a3a3c; }
        pre, code { background: #2c2c2e; border-color: #3a3a3c; }
        img { border-color: #3a3a3c; }
        hr { background: #3a3a3c; }
        }
        </style>
        </head>
        <body>\(html)</body>
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
                codeContent += line
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;") + "\n"
                continue
            }
            if trimmed.isEmpty {
                result += "<br>\n"
                continue
            }
            if trimmed.hasPrefix("<") {
                result += line + "\n"
                continue
            }
            if line.hasPrefix("# ") {
                result += "<h1>\(processInline(String(line.dropFirst(2))))</h1>\n"
            } else if line.hasPrefix("## ") {
                result += "<h2>\(processInline(String(line.dropFirst(3))))</h2>\n"
            } else if line.hasPrefix("### ") {
                result += "<h3>\(processInline(String(line.dropFirst(4))))</h3>\n"
            } else if trimmed == "---" {
                result += "<hr>\n"
            } else if trimmed.hasPrefix("- ") {
                result += "<li>\(processInline(String(trimmed.dropFirst(2))))</li>\n"
            } else {
                result += "<p>\(processInline(line))</p>\n"
            }
        }
        return result
    }

    private func processInline(_ text: String) -> String {
        var processed = text
        processed = processed.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "<b>$1</b>", options: .regularExpression)
        processed = processed.replacingOccurrences(of: "`([^`]+)`", with: "<code>$1</code>", options: .regularExpression)
        processed = processed.replacingOccurrences(of: "\\[([^\\]]+)\\]\\(([^\\)]+)\\)", with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        return processed
    }
}

final class LoadingWindowController: NSWindowController {
    private var sublabel: NSTextField?
    private var indicator: NSProgressIndicator?
    private var cancelButton: NSButton?
    var cancelHandler: (() -> Void)?

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 196),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        self.init(window: window)
        setupUI()
    }

    func setupUI() {
        let background = LoaderBackgroundView()
        window?.contentView = background

        let contentStack = NSStackView()
        contentStack.orientation = .vertical
        contentStack.spacing = 10
        contentStack.alignment = .centerX
        background.addSubview(contentStack)
        contentStack.fill(parent: background, padding: 24)

        let title = NSTextField(labelWithString: "DPI Killer")
        title.font = .systemFont(ofSize: 20, weight: .semibold)
        title.textColor = AppTheme.textPrimary
        title.alignment = .center

        let subtitle = NSTextField(labelWithString: L10n.shared.preparingBypass)
        subtitle.font = .systemFont(ofSize: 13, weight: .regular)
        subtitle.textColor = AppTheme.textSecondary
        subtitle.alignment = .center
        sublabel = subtitle

        indicator = NSProgressIndicator()
        indicator?.style = .spinning
        indicator?.isIndeterminate = true
        indicator?.startAnimation(nil)
        indicator?.translatesAutoresizingMaskIntoConstraints = false

        cancelButton = NSButton(title: L10n.shared.cancel, target: self, action: #selector(cancelClicked))
        if let cancelButton {
            AppTheme.styleSecondaryButton(cancelButton)
            cancelButton.isHidden = true
        }

        contentStack.addArrangedSubview(title)
        contentStack.addArrangedSubview(subtitle)
        if let indicator {
            contentStack.addArrangedSubview(indicator)
        }
        if let cancelButton {
            contentStack.addArrangedSubview(cancelButton)
            cancelButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
        }
    }

    func updateStatus(_ text: String, showCancel: Bool = false) {
        DispatchQueue.main.async {
            self.sublabel?.stringValue = text
            self.cancelButton?.isHidden = !showCancel
        }
    }

    func updateProgress(_ value: Double) {
        DispatchQueue.main.async {
            self.indicator?.isIndeterminate = false
            self.indicator?.doubleValue = value * 100
        }
    }

    func setProgressIndeterminate(_ value: Bool) {
        DispatchQueue.main.async {
            self.indicator?.isIndeterminate = value
            if value {
                self.indicator?.startAnimation(nil)
            }
        }
    }

    @objc func cancelClicked() {
        cancelHandler?()
    }

    func showWithFade() {
        window?.alphaValue = 0
        window?.center()
        showWindow(nil)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.22
            window?.animator().alphaValue = 1
        }
    }

    func closeWithFade(completion: @escaping () -> Void) {
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.18
            window?.animator().alphaValue = 0
        }, completionHandler: completion)
    }
}

final class LoaderBackgroundView: NSVisualEffectView {
    private let gradientLayer = CAGradientLayer()
    private let borderLayer = CAShapeLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        material = .hudWindow
        blendingMode = .withinWindow
        state = .active
        wantsLayer = true
        layer?.cornerRadius = 18
        layer?.masksToBounds = true

        gradientLayer.colors = [
            NSColor.windowBackgroundColor.blended(withFraction: 0.16, of: NSColor.controlAccentColor)?.cgColor ?? NSColor.windowBackgroundColor.cgColor,
            NSColor.windowBackgroundColor.blended(withFraction: 0.05, of: NSColor.systemBlue)?.cgColor ?? NSColor.windowBackgroundColor.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)

        borderLayer.fillColor = NSColor.clear.cgColor
        borderLayer.strokeColor = NSColor.separatorColor.withAlphaComponent(0.35).cgColor
        borderLayer.lineWidth = 1

        layer?.addSublayer(gradientLayer)
        layer?.addSublayer(borderLayer)
    }

    override func layout() {
        super.layout()
        gradientLayer.frame = bounds
        borderLayer.frame = bounds
        borderLayer.path = CGPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerWidth: 18,
            cornerHeight: 18,
            transform: nil
        )
    }
}
