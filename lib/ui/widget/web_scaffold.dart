import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanandroid_client_flutter/common/common.dart';
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

class _WebScaffoldState extends State<WebScaffold>
    with SingleTickerProviderStateMixin {
  WebViewController _webViewController;
  AnimationController _animationController;
  Animation<double> _animation;
  int _loadState = LoadState.loading;
  ValueNotifier<bool> _canGoForwardNotifier = ValueNotifier(false);
  ValueNotifier<bool> _canGoBackNotifier = ValueNotifier(false);
  bool _isReload = false;
  bool _isGoBack = false;
  bool _isGoForward = false;
  bool _isNavigate = false;
  bool _isOnWebResourceError = false;
  String _title;

  void _updateLoadState(int value) {
    setState(() {
      _loadState = value;
    });
  }

  void _updateTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  @override
  void initState() {
    _title = widget.title;
    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.repeat();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title ?? ''),
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
              String currentUrl = await _webViewController?.currentUrl();
              await Share.share("${_title ?? widget.title} ${ currentUrl ?? widget.url}");
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
                    if (_isOnWebResourceError && _doNotUseLoadState()) {
                      _updateLoadState(LoadState.fail);
                    } else {
                      _updateLoadState(LoadState.success);
                    }
                    _isOnWebResourceError = false;
                    _refreshGoBackAndGoForward();
                    _webViewController
                        ?.getTitle()
                        ?.then((value) => _updateTitle(value));
                    _animationController.stop();
                  },
                  onPageStarted: (String url) {
                    debugPrint('加载开始：$url');
                    if (!_doNotUseLoadState()) {
                      _updateLoadState(LoadState.loading);
                    }
                    _resetFlags();
                  },
                  onWebResourceError: (WebResourceError error) {
                    debugPrint('加载出错：$error');
                    _isOnWebResourceError = true;
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
                    // 旋转动画参考：https://kinsomyjs.github.io/2019/01/08/Flutter%E4%BB%BF%E7%BD%91%E6%98%93%E4%BA%91%E9%9F%B3%E4%B9%90-%E4%B8%80/
                    AnimatedBuilder(
                      animation: _animation,
                      child: IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          _isReload = true;
                          _animationController.forward();
                          _webViewController?.reload();
                        },
                      ),
                      builder: (BuildContext context, Widget child) {
                        return RotationTransition(
                          turns: _animation,
                          child: child,
                        );
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

  bool _doNotUseLoadState() {
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
