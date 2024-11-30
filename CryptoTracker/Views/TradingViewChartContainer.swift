import SwiftUI
import WebKit

struct TradingViewChartContainer: UIViewRepresentable {
    let symbol: String
    let height: CGFloat
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <div class="tradingview-widget-container" style="height:100%;width:100%">
          <div id="tradingview_chart" style="height:100%;width:100%"></div>
        </div>
        <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
        <script type="text/javascript">
        new TradingView.widget({
          "width": "100%",
          "height": "100%",
          "symbol": "\(symbol)USDT",
          "interval": "60",
          "timezone": "exchange",
          "theme": "dark",
          "style": "1",
          "toolbar_bg": "#131722",
          "enable_publishing": false,
          "hide_top_toolbar": false,
          "hide_legend": true,
          "save_image": false,
          "container_id": "tradingview_chart",
          "withdateranges": true,
          "hide_side_toolbar": true,
          "allow_symbol_change": false,
          "disabled_features": ["chart_events", "header_widget"],
          "enabled_features": ["hide_left_toolbar_by_default"],
          "overrides": {
            "paneProperties.background": "#131722",
            "paneProperties.vertGridProperties.color": "#363c4e",
            "paneProperties.horzGridProperties.color": "#363c4e",
            "symbolWatermarkProperties.transparency": 90,
            "scalesProperties.textColor": "#AAA",
            "mainSeriesProperties.candleStyle.wickUpColor": '#26a69a',
            "mainSeriesProperties.candleStyle.wickDownColor": '#ef5350',
            "mainSeriesProperties.candleStyle.upColor": '#26a69a',
            "mainSeriesProperties.candleStyle.downColor": '#ef5350',
            "mainSeriesProperties.candleStyle.borderUpColor": '#26a69a',
            "mainSeriesProperties.candleStyle.borderDownColor": '#ef5350'
          }
        });
        </script>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}

struct TradingViewChartContainer_Previews: PreviewProvider {
    static var previews: some View {
        TradingViewChartContainer(symbol: "BTC", height: 300)
            .frame(height: 300)
    }
}
