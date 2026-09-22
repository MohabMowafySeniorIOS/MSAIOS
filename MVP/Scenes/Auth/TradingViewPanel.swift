//
//  TradingViewPanel.swift
//  MSA
//
//  حاضنة widgets تريدنج فيو الرسمية — نفس صفحة الأندرويد بالظبط.
//

import SwiftUI
import WebKit

/// نوع الأداة المعروضة
enum TVWidgetKind: String {
    case chart
    case analysis
}

/// رموز المعادن على تريدنج فيو
enum TVSymbol {
    /// أونصة الذهب بالدولار — المعيار العالمي اللي التحليل الفني بيتبني عليه
    static let gold = "OANDA:XAUUSD"
    static let silver = "OANDA:XAGUSD"
}

struct TradingViewPanel: UIViewRepresentable {

    let widget: TVWidgetKind
    let symbol: String

    private var locale: String {
        L102Language.currentAppleLanguage() == "ar" ? "ar_AE" : "en"
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        // الإعدادات لازم توصل قبل ما سكربت الصفحة يشتغل، فبنحقنها
        // عند بداية المستند مش بعد التحميل.
        let script = WKUserScript(
            source: configScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        // نفس لون خلفية التطبيق عشان الأداة تندمج مع الشاشة
        webView.backgroundColor = UIColor(red: 0.180, green: 0.125, blue: 0.125, alpha: 1)
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator

        load(into: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // تغيير المعدن بيعيد بناء الأداة في نفس الصفحة من غير إعادة تحميل
        webView.evaluateJavaScript(configScript + " if (typeof render === 'function') { render(); }")
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        /// روابط تريدنج فيو تتفتح في السفاري مش جوّه الأداة
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }

    private var configScript: String {
        """
        window.MSA_CONFIG = {
            widget: '\(widget.rawValue)',
            symbol: '\(symbol)',
            locale: '\(locale)'
        };
        """
    }

    private func load(into webView: WKWebView) {
        guard let url = Bundle.main.url(forResource: "tradingview", withExtension: "html") else {
            return
        }
        // `allowingReadAccessTo` لازمة عشان الصفحة تقدر تحمّل سكربت تريدنج فيو
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}
