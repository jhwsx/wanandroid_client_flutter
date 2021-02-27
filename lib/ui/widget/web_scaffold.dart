import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanandroid_client_flutter/util/navigator_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebScaffold extends StatefulWidget {
  const WebScaffold({Key key, this.title, this.url}) : super(key: key);

  final String title;
  final String url;

  @override
  _WebScaffoldState createState() => _WebScaffoldState();
}

class _WebScaffoldState extends State<WebScaffold> {
  WebViewController _webViewController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: /*WillPopScope(
          child:*/ WebView(
            initialUrl: widget.url,
            // 加载 js
            javascriptMode: JavascriptMode.unrestricted,
            // 拦截请求
            navigationDelegate: (NavigationRequest navigation) {
              debugPrint('navigate to ${navigation.url}');
              if (!navigation.url.startsWith('http')) {
                openAppByUrl(navigation.url);
                return NavigationDecision.prevent;
              } else {
                return NavigationDecision.navigate;
              }
            },
            onWebViewCreated: (WebViewController controller) {
              _webViewController = controller;
            },
          ),
          /*onWillPop: () async {
            if (_webViewController == null) return true;
            if (await _webViewController.canGoBack()) {
              _webViewController.goBack();
              return false;
            }
            return true;
          }),*/
    );
  }

  static openAppByUrl(url) async {
    await launch(url);
  }
}
