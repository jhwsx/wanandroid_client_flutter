import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanandroid_client_flutter/common/common.dart';
import 'package:wanandroid_client_flutter/util/navigator_util.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'widgets.dart';

/// 异常：当跳转时会出现。
/// E/AndroidRuntime(13240): FATAL EXCEPTION: main
/// E/AndroidRuntime(13240): Process: com.wan.android.wanandroid_client_flutter, PID: 13240
/// E/AndroidRuntime(13240): java.lang.NullPointerException: Attempt to read from field 'android.view.WindowManager$LayoutParams android.view.ViewRootImpl.mWindowAttributes' on a null object reference
/// E/AndroidRuntime(13240): 	at android.view.inputmethod.InputMethodManager.startInputInner(InputMethodManager.java:1628)
/// E/AndroidRuntime(13240): 	at android.view.inputmethod.InputMethodManager.checkFocus(InputMethodManager.java:1872)
/// E/AndroidRuntime(13240): 	at android.view.inputmethod.InputMethodManager.isActive(InputMethodManager.java:1184)
/// E/AndroidRuntime(13240): 	at io.flutter.plugins.webviewflutter.InputAwareWebView$1.run(InputAwareWebView.java:188)
/// E/AndroidRuntime(13240): 	at android.os.Handler.handleCallback(Handler.java:883)
/// E/AndroidRuntime(13240): 	at android.os.Handler.dispatchMessage(Handler.java:100)
/// E/AndroidRuntime(13240): 	at android.os.Looper.loop(Looper.java:224)
/// E/AndroidRuntime(13240): 	at android.app.ActivityThread.main(ActivityThread.java:7574)
/// E/AndroidRuntime(13240): 	at java.lang.reflect.Method.invoke(Native Method)
/// E/AndroidRuntime(13240): 	at com.android.internal.os.RuntimeInit$MethodAndArgsCaller.run(RuntimeInit.java:539)
/// E/AndroidRuntime(13240): 	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:950)
class WebScaffold extends StatefulWidget {
  const WebScaffold({Key key, this.title, this.url}) : super(key: key);

  final String title;
  final String url;

  @override
  _WebScaffoldState createState() => _WebScaffoldState();
}

class _WebScaffoldState extends State<WebScaffold> {
  WebViewController _webViewController;
  int _loadState = LoadState.loading;
  ValueNotifier<bool> _canGoForwardNotifier = ValueNotifier(false);
  ValueNotifier<bool> _canGoBackNotifier = ValueNotifier(false);
  bool _isReload = false;
  bool _isGoBack = false;
  bool _isGoForward = false;
  bool _isNavigate = false;

  void _updateLoadState(int value) {
    setState(() {
      _loadState = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.launch),
            onPressed: () async {
              await launch(widget.url);
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              await Share.share("${widget.title} ${widget.url}");
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Expanded(
                // 不加 Expanded，会报错：RenderAndroidView object was given an infinite size during layout.
                child: WebView(
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
                      _isNavigate = true;
                      return NavigationDecision.navigate;
                    }
                  },
                  onWebViewCreated: (WebViewController controller) {
                    _webViewController = controller;
                    _webViewController
                        .currentUrl()
                        .then((value) => debugPrint('当前 url：$value'));
                  },
                  onPageFinished: (String url) {
                    debugPrint('加载完成：$url');
                    _updateLoadState(LoadState.success);
                    _refreshGoBackAndGoForward();
                  },
                  onPageStarted: (String url) {
                    debugPrint('加载开始：$url');
                    if (!_doNotShowLoading()) {
                      _updateLoadState(LoadState.loading);
                    }
                    _resetFlags();
                  },
                  onWebResourceError: (WebResourceError error) {
                    debugPrint('加载出错：$error');
                    _updateLoadState(LoadState.fail);
                  },
                ),
              ),
              BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ValueListenableBuilder(
                      valueListenable: _canGoBackNotifier,
                      builder:
                          (BuildContext context, bool value, Widget child) {
                        debugPrint("canGoBack: $value");
                        return IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          color: value ? Colors.black : Colors.grey[600],
                          onPressed: !value
                              ? null
                              : () {
                                  _isGoBack = true;
                                  _webViewController?.goBack();
                                  _refreshGoBackAndGoForward();
                                },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                        valueListenable: _canGoForwardNotifier,
                        builder:
                            (BuildContext context, bool value, Widget child) {
                          debugPrint("canGoForward: $value");
                          return IconButton(
                            color: value ? Colors.black : Colors.grey[600],
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: !value
                                ? null
                                : () {
                                    _isGoForward = true;
                                    _webViewController?.goForward();
                                    _refreshGoBackAndGoForward();
                                  },
                          );
                        }),
                    IconButton(
                      icon: Icon(Icons.sync_rounded),
                      onPressed: () {
                        _isReload = true;
                        _webViewController?.reload();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          StatusViews(
            _loadState,
            onTap: () {
              debugPrint("重新尝试");
              _webViewController?.reload();
            },
          ),
        ],
      ),
    );
  }

  void _refreshGoBackAndGoForward() {
    _webViewController
        ?.canGoBack()
        ?.then((value) => _canGoBackNotifier.value = value);
    _webViewController
        ?.canGoForward()
        ?.then((value) => _canGoForwardNotifier.value = value);
  }

  bool _doNotShowLoading() {
    return _isReload | _isGoForward | _isGoBack | _isNavigate;
  }

  void _resetFlags() {
    _isReload = false;
    _isGoBack = false;
    _isGoForward = false;
    _isNavigate = false;
  }

  static openAppByUrl(url) async {
    debugPrint("openAppByUrl: $url");
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
