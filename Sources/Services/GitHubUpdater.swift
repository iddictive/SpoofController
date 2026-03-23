import Cocoa
import Foundation

final class GitHubUpdater {
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

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
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
                        let dmgAsset = assets?.first { ($0["name"] as? String)?.hasSuffix(".dmg") == true }
                        let downloadUrl = dmgAsset?["browser_download_url"] as? String

                        DispatchQueue.main.async {
                            if !manual,
                               SettingsStore.shared.autoDownload,
                               let dlUrl = downloadUrl,
                               let url = URL(string: dlUrl) {
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
                AppLogger.log("Update check error: \(error)")
            }
        }.resume()
    }

    private func compareVersions(current: String, latest: String) -> Bool {
        latest.compare(current, options: .numeric) == .orderedDescending
    }

    private func showUpdateAlert(version: String, downloadUrl: String?) {
        let alert = NSAlert()
        alert.messageText = L10n.shared.updateAvailable
        alert.informativeText = String(format: L10n.shared.updateFound, version)
        alert.addButton(withTitle: L10n.shared.updateDownload)
        alert.addButton(withTitle: L10n.shared.updateLater)

        NSApp.activate(ignoringOtherApps: true)
        let appDelegate = NSApp.delegate as? AppDelegate
        let parentWindow = appDelegate?.loadingWindow?.window ?? appDelegate?.settingsWindow?.window

        if let window = parentWindow {
            alert.beginSheetModal(for: window) { response in
                if response == .alertFirstButtonReturn,
                   let urlString = downloadUrl,
                   let url = URL(string: urlString) {
                    self.startAutomatedUpdate(url: url)
                }
            }
        } else if alert.runModal() == .alertFirstButtonReturn,
                  let urlString = downloadUrl,
                  let url = URL(string: urlString) {
            startAutomatedUpdate(url: url)
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
