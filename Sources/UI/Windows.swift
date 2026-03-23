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
        let width = max(640, min(920, screen.width * 0.48))
        let height = max(700, min(1080, screen.height * 0.82))

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .fullSizeContentView, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.shared.settingsTitle
        AppTheme.styleWindow(window, minSize: NSSize(width: 620, height: 680))
        self.init(window: window)
        setupUI()
    }

    func setupUI() {
        let backdrop = GradientBackdropView()
        window?.contentView = backdrop

        let headerCard = SurfaceCardView(spacing: 10)
        let heroRow = NSStackView()
        heroRow.orientation = .horizontal
        heroRow.spacing = 18
        heroRow.alignment = .centerY

        let iconContainer = NSView(frame: NSRect(x: 0, y: 0, width: 68, height: 68))
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.widthAnchor.constraint(equalToConstant: 68).isActive = true
        iconContainer.heightAnchor.constraint(equalToConstant: 68).isActive = true
        iconContainer.wantsLayer = true
        iconContainer.layer?.cornerRadius = 20
        iconContainer.layer?.backgroundColor = AppTheme.accent.withAlphaComponent(0.22).cgColor
        iconContainer.layer?.borderWidth = 1
        iconContainer.layer?.borderColor = AppTheme.accentSoft.withAlphaComponent(0.35).cgColor
        if let icon = NSApp.applicationIconImage {
            let iconView = NSImageView(image: icon)
            iconView.imageScaling = .scaleProportionallyUpOrDown
            iconContainer.addSubview(iconView)
            iconView.fill(parent: iconContainer, padding: 12)
        }

        let heroText = NSStackView()
        heroText.orientation = .vertical
        heroText.spacing = 8
        heroText.alignment = .leading
        heroText.addArrangedSubview(AppTheme.makeHeadline(L10n.shared.settingsTitle))
        heroText.addArrangedSubview(AppTheme.makeSubtitle(
            L10n.shared.isRussian
                ? "Модульная конфигурация обхода, DNS, прокси и автозапуска в одном окне."
                : "Modular control surface for bypass, DNS, proxy, and startup behavior."
        ))
        heroText.addArrangedSubview(AppTheme.makeStatusBadge(
            text: DPIKillerManager.shared.isRunning ? "LIVE SESSION" : "READY TO APPLY",
            color: DPIKillerManager.shared.isRunning ? AppTheme.success : AppTheme.warning
        ))

        heroRow.addArrangedSubview(iconContainer)
        heroRow.addArrangedSubview(heroText)
        headerCard.stack.addArrangedSubview(heroRow)

        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let footerCard = SurfaceCardView(spacing: 0)
        let footerStack = NSStackView()
        footerStack.orientation = .horizontal
        footerStack.spacing = 14
        footerStack.alignment = .centerY

        let cancelBtn = NSButton(title: L10n.shared.cancel, target: self, action: #selector(cancelAction))
        AppTheme.styleSecondaryButton(cancelBtn)

        let saveButton = NSButton(title: L10n.shared.saveAndRestart, target: self, action: #selector(save))
        saveButton.keyEquivalent = "\r"
        AppTheme.stylePrimaryButton(saveButton)

        footerStack.addArrangedSubview(cancelBtn)
        footerStack.addArrangedSubview(saveButton)
        footerCard.stack.addArrangedSubview(footerStack)

        let contentView = NSView()
        scrollView.documentView = contentView

        let mainStack = NSStackView()
        mainStack.orientation = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .centerX
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        backdrop.addSubview(headerCard)
        backdrop.addSubview(scrollView)
        backdrop.addSubview(footerCard)

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: backdrop.topAnchor, constant: 24),
            headerCard.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 24),
            headerCard.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -24),

            footerCard.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 24),
            footerCard.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -24),
            footerCard.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: -24),

            scrollView.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -8),
            scrollView.bottomAnchor.constraint(equalTo: footerCard.topAnchor, constant: -16),

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

        func addSection(_ section: SurfaceCardView) {
            mainStack.addArrangedSubview(section)
            section.widthAnchor.constraint(equalTo: mainStack.widthAnchor, constant: -32).isActive = true
        }

        let coreSection = createSection(
            title: L10n.shared.sectionCore,
            subtitle: L10n.shared.isRussian ? "Где брать `spoofdpi` и как запускать его с нужными аргументами." : "Where `spoofdpi` is loaded from and how it is launched."
        )
        pathField = themedTextField(value: SettingsStore.shared.binaryPath, placeholder: L10n.shared.binaryPlaceholder)
        addRow(label: L10n.shared.binaryPath, control: pathField, to: coreSection.stack, tooltip: L10n.shared.tipBinaryPath)
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
        statusTitle.textColor = .secondaryLabelColor
        hotspotStatusLabel = NSTextField(labelWithString: L10n.shared.diagChecking)
        hotspotStatusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusRow.addArrangedSubview(statusTitle)
        statusRow.addArrangedSubview(hotspotStatusLabel)
        networkSection.stack.addArrangedSubview(statusRow)

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
        networkSection.stack.addArrangedSubview(hotspotActions)

        portField = themedTextField(value: SettingsStore.shared.localPort, placeholder: L10n.shared.portPlaceholder, width: 120)
        addRow(label: L10n.shared.portTitle, control: portField, to: networkSection.stack, tooltip: L10n.shared.tipLocalPort)
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
            desc.textColor = .secondaryLabelColor
            row.addArrangedSubview(desc)
            dpiSection.stack.addArrangedSubview(row)
        }

        ttlField = themedTextField(value: SettingsStore.shared.defaultTTL, placeholder: L10n.shared.ttlPlaceholder, width: 90)
        addRow(label: L10n.shared.ttlTitle, control: ttlField, to: dpiSection.stack, tooltip: L10n.shared.tipTTL)

        splitModeButton = themedPopup(items: ["sni", "random", "chunk", "none"], selected: SettingsStore.shared.splitMode)
        addRow(label: L10n.shared.splitModeTitle, control: splitModeButton, to: dpiSection.stack, tooltip: L10n.shared.tipSplitMode)

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
        fakeLabel.textColor = .secondaryLabelColor
        httpsFakeCountField = themedTextField(value: SettingsStore.shared.httpsFakeCount, placeholder: "0", width: 68)

        let fakeStack = NSStackView()
        fakeStack.orientation = .horizontal
        fakeStack.spacing = 8
        fakeStack.alignment = .centerY
        fakeStack.addArrangedSubview(fakeLabel)
        fakeStack.addArrangedSubview(httpsFakeCountField)
        disorderStack.addArrangedSubview(NSView())
        disorderStack.addArrangedSubview(fakeStack)
        dpiSection.stack.addArrangedSubview(disorderStack)

        httpsChunkSizeField = themedTextField(value: SettingsStore.shared.httpsChunkSize, placeholder: L10n.shared.httpsChunkPlaceholder, width: 90)
        addRow(label: L10n.shared.httpsChunkSize, control: httpsChunkSizeField, to: dpiSection.stack, tooltip: L10n.shared.tipChunkSize)
        addSection(dpiSection)

        let dnsSection = createSection(
            title: L10n.shared.sectionDNS,
            subtitle: L10n.shared.isRussian ? "Поднимай собственный DNS path, включая HTTPS mode." : "Swap DNS transport and resolver endpoint without leaving the app."
        )
        dnsAddrField = themedTextField(value: SettingsStore.shared.dnsAddr, placeholder: "8.8.8.8:53")
        addRow(label: L10n.shared.dnsAddrTitle, control: dnsAddrField, to: dnsSection.stack, tooltip: L10n.shared.tipDNSAddr)

        dnsModeButton = themedPopup(items: ["udp", "https", "system"], selected: SettingsStore.shared.dnsMode)
        addRow(label: L10n.shared.dnsModeTitle, control: dnsModeButton, to: dnsSection.stack, tooltip: L10n.shared.tipDNSSystem)

        dnsHttpsUrlField = themedTextField(value: SettingsStore.shared.dnsHttpsUrl, placeholder: "https://dns.google/dns-query")
        addRow(label: "DoH URL", control: dnsHttpsUrlField, to: dnsSection.stack)
        addSection(dnsSection)

        let appSection = createSection(
            title: L10n.shared.sectionApp,
            subtitle: L10n.shared.isRussian ? "Поведением клиента, апдейтами и reconnect управляем здесь." : "Client behavior, updates, and reconnect live here."
        )
        let loginCb = NSButton(checkboxWithTitle: L10n.shared.launchAtLogin, target: self, action: #selector(toggleLoginItem))
        loginCb.state = SettingsStore.shared.launchAtLogin ? .on : .off
        addCheckboxRow(button: loginCb, to: appSection.stack)

        let updateCb = NSButton(checkboxWithTitle: L10n.shared.autoUpdateToggle, target: self, action: #selector(toggleUpdateItem))
        updateCb.state = SettingsStore.shared.autoUpdate ? .on : .off
        addCheckboxRow(button: updateCb, to: appSection.stack)

        let ipv6Cb = NSButton(checkboxWithTitle: L10n.shared.disableIpv6, target: self, action: #selector(toggleIpv6))
        ipv6Cb.state = SettingsStore.shared.disableIpv6 ? .on : .off
        addCheckboxRow(button: ipv6Cb, to: appSection.stack)

        let reconnectCb = NSButton(checkboxWithTitle: L10n.shared.autoReconnect, target: self, action: #selector(toggleReconnect))
        reconnectCb.state = SettingsStore.shared.autoReconnect ? .on : .off
        reconnectCb.toolTip = L10n.shared.tipAutoReconnect
        addCheckboxRow(button: reconnectCb, to: appSection.stack)
        addSection(appSection)

        let manualSection = createSection(
            title: L10n.shared.sectionManual,
            subtitle: L10n.shared.isRussian ? "Для редких edge-case флагов, которые ещё не покрыты UI." : "For edge-case flags that still deserve a manual override."
        )
        manualArgsField = themedTextField(value: manualArgsValue(), placeholder: L10n.shared.manualArgsPlaceholder)
        manualSection.stack.addArrangedSubview(manualArgsField)
        manualArgsField.widthAnchor.constraint(equalTo: manualSection.stack.widthAnchor).isActive = true
        addSection(manualSection)
    }

    private func createSection(title: String, subtitle: String) -> SurfaceCardView {
        let section = SurfaceCardView(spacing: 14)
        section.stack.addArrangedSubview(sectionHeader(title: title, subtitle: subtitle))
        return section
    }

    private func sectionHeader(title: String, subtitle: String) -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 6
        stack.alignment = .leading

        let titleLabel = NSTextField(labelWithString: title.uppercased())
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .secondaryLabelColor
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(AppTheme.makeSubtitle(subtitle))
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
        popup.font = .systemFont(ofSize: 13, weight: .medium)
        popup.wantsLayer = true
        popup.layer?.cornerRadius = 10
        popup.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.10).cgColor
        popup.layer?.borderWidth = 1
        popup.layer?.borderColor = AppTheme.cardStroke.cgColor
        popup.translatesAutoresizingMaskIntoConstraints = false
        return popup
    }

    private func addRow(label: String, control: NSView, to stack: NSStackView, tooltip: String? = nil) {
        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 12

        let labelView = NSTextField(labelWithString: label)
        labelView.font = .systemFont(ofSize: 12, weight: .medium)
        labelView.textColor = .secondaryLabelColor
        labelView.alignment = .right
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.widthAnchor.constraint(equalToConstant: 140).isActive = true

        if let tooltip {
            control.toolTip = tooltip
        }

        row.addArrangedSubview(labelView)
        row.addArrangedSubview(control)
        stack.addArrangedSubview(row)
    }

    private func addCheckboxRow(button: NSButton, to stack: NSStackView) {
        button.font = .systemFont(ofSize: 13, weight: .medium)

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
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 470),
            styleMask: [.titled, .closable, .fullSizeContentView, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.shared.speedTest
        AppTheme.styleWindow(window, minSize: NSSize(width: 720, height: 430))
        self.init(window: window)
        window.delegate = self
        setupUI()
    }

    private func setupUI() {
        let backdrop = GradientBackdropView()
        window?.contentView = backdrop

        let hero = SurfaceCardView(spacing: 10)
        hero.stack.addArrangedSubview(AppTheme.makeHeadline(L10n.shared.speedTestTitle))
        stageLabel = AppTheme.makeSubtitle(
            L10n.shared.isRussian
                ? "Cloudflare probe через текущую сетевую цепочку приложения."
                : "Cloudflare probe routed through the app's current network chain."
        )
        hero.stack.addArrangedSubview(stageLabel)

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

        backdrop.addSubview(hero)
        backdrop.addSubview(metrics)
        backdrop.addSubview(progressIndicator)
        backdrop.addSubview(startButton)

        NSLayoutConstraint.activate([
            hero.topAnchor.constraint(equalTo: backdrop.topAnchor, constant: 26),
            hero.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 26),
            hero.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -26),

            metrics.topAnchor.constraint(equalTo: hero.bottomAnchor, constant: 20),
            metrics.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 26),
            metrics.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -26),

            progressIndicator.topAnchor.constraint(equalTo: metrics.bottomAnchor, constant: 24),
            progressIndicator.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 26),
            progressIndicator.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -26),

            startButton.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 22),
            startButton.centerXAnchor.constraint(equalTo: backdrop.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 220),
            startButton.heightAnchor.constraint(equalToConstant: 42)
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
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 520),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.shared.logsTitle
        AppTheme.styleWindow(window, minSize: NSSize(width: 640, height: 420))
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
        let backdrop = GradientBackdropView()
        window?.contentView = backdrop

        let title = AppTheme.makeHeadline(L10n.shared.logsTitle)
        let subtitle = AppTheme.makeSubtitle(
            L10n.shared.isRussian
                ? "Живой circular buffer без спама в память."
                : "Live circular buffer without runaway memory growth."
        )
        liveBadge = AppTheme.makeStatusBadge(text: "STREAMING", color: AppTheme.accentSoft)

        let hero = SurfaceCardView(spacing: 10)
        hero.stack.addArrangedSubview(title)
        hero.stack.addArrangedSubview(subtitle)
        hero.stack.addArrangedSubview(liveBadge)

        let logCard = SurfaceCardView(spacing: 0)
        scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        textView = NSTextView()
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.drawsBackground = false
        textView.textColor = .labelColor
        textView.textContainerInset = NSSize(width: 8, height: 10)
        scrollView.documentView = textView
        logCard.addSubview(scrollView)
        scrollView.fill(parent: logCard, padding: 18)

        let actions = NSStackView()
        actions.orientation = .horizontal
        actions.spacing = 12
        actions.alignment = .centerY

        let clearBtn = NSButton(title: L10n.shared.clearLogs, target: self, action: #selector(clearLogs))
        AppTheme.styleSecondaryButton(clearBtn)
        let copyBtn = NSButton(title: L10n.shared.copyLogs, target: self, action: #selector(copyLogs))
        AppTheme.stylePrimaryButton(copyBtn)
        actions.addArrangedSubview(clearBtn)
        actions.addArrangedSubview(copyBtn)

        backdrop.addSubview(hero)
        backdrop.addSubview(logCard)
        backdrop.addSubview(actions)

        NSLayoutConstraint.activate([
            hero.topAnchor.constraint(equalTo: backdrop.topAnchor, constant: 24),
            hero.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 24),
            hero.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -24),

            logCard.topAnchor.constraint(equalTo: hero.bottomAnchor, constant: 16),
            logCard.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 24),
            logCard.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -24),
            logCard.bottomAnchor.constraint(equalTo: actions.topAnchor, constant: -16),

            actions.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 24),
            actions.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: -24)
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
            contentRect: NSRect(x: 0, y: 0, width: 860, height: 680),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = L10n.shared.helpTitle
        AppTheme.styleWindow(window, minSize: NSSize(width: 680, height: 520))
        self.init(window: window)
        setupUI()
        loadReadme()
    }

    func setupUI() {
        let backdrop = GradientBackdropView()
        window?.contentView = backdrop

        let hero = SurfaceCardView(spacing: 10)
        hero.stack.addArrangedSubview(AppTheme.makeHeadline(L10n.shared.helpTitle))
        hero.stack.addArrangedSubview(AppTheme.makeSubtitle(
            L10n.shared.isRussian
                ? "README рендерится локально внутри приложения."
                : "README rendered locally inside the app."
        ))

        let webCard = SurfaceCardView(spacing: 0)
        webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        webView.translatesAutoresizingMaskIntoConstraints = false
        webCard.addSubview(webView)
        webView.fill(parent: webCard, padding: 12)

        backdrop.addSubview(hero)
        backdrop.addSubview(webCard)

        NSLayoutConstraint.activate([
            hero.topAnchor.constraint(equalTo: backdrop.topAnchor, constant: 24),
            hero.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 24),
            hero.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -24),

            webCard.topAnchor.constraint(equalTo: hero.bottomAnchor, constant: 16),
            webCard.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 24),
            webCard.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -24),
            webCard.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: -24)
        ])
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
        body { font-family: -apple-system; font-size: 15px; line-height: 1.65; padding: 28px 36px; color: #eaf2ff; background: linear-gradient(180deg, #101724 0%, #0a111c 100%); }
        a { color: #71d6ff; }
        h1, h2, h3 { color: #ffffff; }
        h1 { font-size: 30px; border-bottom: 1px solid rgba(255,255,255,0.12); padding-bottom: 12px; }
        h2 { margin-top: 30px; }
        pre { background: rgba(255,255,255,0.06); padding: 14px; border-radius: 14px; overflow-x: auto; border: 1px solid rgba(255,255,255,0.08); }
        code { background: rgba(255,255,255,0.08); padding: 2px 6px; border-radius: 6px; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
        img { max-width: 100%; border-radius: 16px; border: 1px solid rgba(255,255,255,0.08); }
        li { margin: 6px 0; }
        hr { border: none; height: 1px; background: rgba(255,255,255,0.10); }
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
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 220),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.hasShadow = true
        self.init(window: window)
        setupUI()
    }

    func setupUI() {
        let backdrop = GradientBackdropView()
        backdrop.wantsLayer = true
        backdrop.layer?.cornerRadius = 28
        backdrop.layer?.masksToBounds = true
        window?.contentView = backdrop

        let card = SurfaceCardView(spacing: 10)
        backdrop.addSubview(card)
        card.centerXAnchor.constraint(equalTo: backdrop.centerXAnchor).isActive = true
        card.centerYAnchor.constraint(equalTo: backdrop.centerYAnchor).isActive = true
        card.widthAnchor.constraint(equalToConstant: 320).isActive = true

        let title = NSTextField(labelWithString: "DPI Killer")
        title.font = .systemFont(ofSize: 24, weight: .bold)
        title.textColor = .labelColor
        title.alignment = .center

        let subtitle = NSTextField(labelWithString: L10n.shared.preparingBypass)
        subtitle.font = .systemFont(ofSize: 13, weight: .medium)
        subtitle.textColor = .secondaryLabelColor
        subtitle.alignment = .center
        sublabel = subtitle

        let orb = NSView()
        orb.translatesAutoresizingMaskIntoConstraints = false
        orb.widthAnchor.constraint(equalToConstant: 64).isActive = true
        orb.heightAnchor.constraint(equalToConstant: 64).isActive = true
        orb.wantsLayer = true
        orb.layer?.cornerRadius = 20
        orb.layer?.backgroundColor = AppTheme.accent.withAlphaComponent(0.22).cgColor
        orb.layer?.borderWidth = 1
        orb.layer?.borderColor = AppTheme.accentSoft.withAlphaComponent(0.35).cgColor
        if let icon = NSApp.applicationIconImage {
            let iconView = NSImageView(image: icon)
            orb.addSubview(iconView)
            iconView.fill(parent: orb, padding: 10)
        }

        indicator = NSProgressIndicator()
        indicator?.style = .bar
        indicator?.isIndeterminate = true
        indicator?.startAnimation(nil)
        indicator?.translatesAutoresizingMaskIntoConstraints = false

        cancelButton = NSButton(title: L10n.shared.cancel, target: self, action: #selector(cancelClicked))
        if let cancelButton {
            AppTheme.styleSecondaryButton(cancelButton)
            cancelButton.isHidden = true
        }

        card.stack.alignment = .centerX
        card.stack.addArrangedSubview(orb)
        card.stack.addArrangedSubview(title)
        card.stack.addArrangedSubview(subtitle)
        if let indicator {
            card.stack.addArrangedSubview(indicator)
            indicator.widthAnchor.constraint(equalToConstant: 180).isActive = true
        }
        if let cancelButton {
            card.stack.addArrangedSubview(cancelButton)
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
