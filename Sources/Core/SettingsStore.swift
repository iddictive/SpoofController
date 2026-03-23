import Cocoa
import Foundation

final class SettingsStore {
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

    var autoReconnect: Bool {
        get { defaults.object(forKey: "autoReconnect") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "autoReconnect") }
    }

    var launchAtLogin: Bool {
        get { defaults.bool(forKey: "launchAtLogin") }
        set {
            defaults.set(newValue, forKey: "launchAtLogin")
            toggleLaunchAtLogin(newValue)
        }
    }

    var selectedFlags: Set<String> {
        let args = customArgs.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        return Set(args.filter {
            $0.hasPrefix("-")
                && !$0.hasPrefix("--default-ttl")
                && !$0.hasPrefix("--https-chunk-size")
                && !$0.hasPrefix("--https-fake-count")
                && !$0.hasPrefix("--listen-addr")
                && !$0.hasPrefix("--dns-addr")
                && !$0.hasPrefix("--dns-mode")
                && !$0.hasPrefix("--dns-https-url")
                && !$0.hasPrefix("--https-split-mode")
        })
    }

    func applyIpv6Preference() {
        applyIpv6Settings(disableIpv6)
    }

    func restoreIpv6Defaults() {
        applyIpv6Settings(false)
    }

    func updateArgs(
        with flags: Set<String>,
        manual: String,
        ttl: String,
        splitMode: String,
        splitPos: String,
        port: String,
        dnsAddr: String,
        dnsMode: String,
        dnsHttpsUrl: String
    ) {
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
        if dnsMode == "https"
            && !dnsHttpsUrl.isEmpty
            && dnsHttpsUrl != "https://dns.google/dns-query" {
            uniqueFlags += " --dns-https-url \(dnsHttpsUrl)"
        }

        let manualParts = manual.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        var cleanedParts: [String] = []
        var index = 0
        while index < manualParts.count {
            let part = manualParts[index]
            if [
                "--default-ttl",
                "--https-split-mode",
                "--https-split-pos",
                "--listen-addr",
                "--dns-addr",
                "--dns-mode",
                "--dns-https-url"
            ].contains(part) {
                index += 2
            } else if flags.contains(part) {
                index += 1
            } else if Int(part) != nil {
                index += 1
            } else {
                cleanedParts.append(part)
                index += 1
            }
        }

        customArgs = "\(uniqueFlags) \(cleanedParts.joined(separator: " "))"
            .trimmingCharacters(in: .whitespaces)
    }

    private func applyIpv6Settings(_ disable: Bool) {
        let state = disable ? "off" : "on"
        let script = "services=$(networksetup -listallnetworkservices | grep -v '*'); while IFS= read -r service; do networksetup -setv6\(state) \"$service\" 2>/dev/null; done <<< \"$services\""
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", script]
        try? process.run()
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
        for path in paths where FileManager.default.fileExists(atPath: path) {
            return path
        }
        return "spoofdpi"
    }
}
