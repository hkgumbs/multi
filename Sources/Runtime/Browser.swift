import Shared
import WebKit

class Browser: NSObject {
    static let global = Browser()

    static let blocklist: String = {
        guard let url = Bundle.multi?.url(forResource: "blocklist", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json.lowercased()
    }()

    static func window(title: String, webView: WKWebView) -> NSWindow {
        let window = Program.window(
            title: title,
            contentRect: NSScreen.main!.frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable]
        )
        window.setFrameAutosaveName(title)
        webView.frame = window.frame
        window.contentView = webView
        window.tabbingMode = .preferred
        return window
    }

    func `open`(url: URL) {
        guard #available(macOS 10.15, *) else {
            NSWorkspace.shared.open(url)
            return
        }
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = !Config.openNewWindowsInBackground
        if let application = Config.openNewWindowsWith,
           let applicationURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: application) {
            NSWorkspace.shared.open([url], withApplicationAt: applicationURL, configuration: configuration)
        } else {
            NSWorkspace.shared.open(url, configuration: configuration)
        }
    }
}
