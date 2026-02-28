import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:gamedistribution/gamedistribution/game_distribution_logic.dart';

class GameWebViewScreen extends StatefulWidget {
  final String gameId;
  final String mobileMode; // Landscape or Portrait

  const GameWebViewScreen({
    super.key,
    required this.gameId,
    required this.mobileMode,
  });

  @override
  State<GameWebViewScreen> createState() => _GameWebViewScreenState();
}

class _GameWebViewScreenState extends State<GameWebViewScreen> {
  GameDistributionLogic gameDistributionLogic =
      Get.find<GameDistributionLogic>();
  InAppWebViewController? webViewController;
  bool isLandscape = false;

  // 1. إعداد قائمة حظر روابط الإعلانات المعروفة
  final List<ContentBlocker> contentBlockers = [
    ContentBlocker(
      trigger: ContentBlockerTrigger(urlFilter: ".*imasdk.googleapis.com.*"),
      action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
    ),
    ContentBlocker(
      trigger: ContentBlockerTrigger(urlFilter: ".*googlesyndication.com.*"),
      action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
    ),
    ContentBlocker(
      trigger: ContentBlockerTrigger(urlFilter: ".*doubleclick.net.*"),
      action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
    ),
  ];

  // 2. حقن كود جافاسكربت لخداع SDK اللعبة وتخطي الإعلان برمجياً
  final UserScript adSkipScript = UserScript(
    source: """
      // إعادة تعريف كائن الإعلانات الخاص بـ GameDistribution
      window.gdsdk = {
        showAd: function(adType) {
          console.log("Ad Skipped via Injector");
          return new Promise(function(resolve, reject) {
            resolve(); // إخبار اللعبة أن الإعلان انتهى فوراً
          });
        },
        preloadAd: function(adType) {
          return new Promise(function(resolve, reject) {
            resolve();
          });
        },
        cancelAd: function() {},
      };
      Object.freeze(window.gdsdk); // منع اللعبة من تعديل الكود الخاص بنا
    """,
    // التشغيل فور بدء تحميل الصفحة قبل أن تطلبه اللعبة
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
  );

  // دالة التدوير اليدوي
  void toggleOrientation() {
    setState(() {
      isLandscape = !isLandscape;
    });

    if (isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  void simulateKeyEvent(
    String key,
    String code,
    int keyCode,
    String eventType,
  ) {
    webViewController?.evaluateJavascript(
      source:
          """
  (function() {

    // 1. الحصول على iframe الخاص باللعبة
    var iframe = document.querySelector('iframe');

    if (!iframe || !iframe.contentWindow) {
      console.log("Game iframe not found");
      return;
    }

    var gameWindow = iframe.contentWindow;
    var gameDocument = gameWindow.document;

    // 2. إنشاء حدث كيبورد
    var event = new KeyboardEvent('$eventType', {
      key: '$key',
      code: '$code',
      keyCode: $keyCode,
      which: $keyCode,
      bubbles: true,
      cancelable: true
    });

    // 3. إرسال الحدث داخل iframe
    gameWindow.dispatchEvent(event);
    gameDocument.dispatchEvent(event);

  })();
  """,
    );

    webViewController?.evaluateJavascript(
      source:
          """
  (function() {
    var iframe = document.querySelector('iframe');
    if (!iframe || !iframe.contentWindow) return;

    var win = iframe.contentWindow;

    var event = new Event('$eventType');
    event.keyCode = $keyCode;
    event.which = $keyCode;

    win.dispatchEvent(event);
  })();
  """,
    );
  }

  Widget buildGameButton(
    IconData icon,
    String keyString,
    String codeString,
    int keyCode,
  ) {
    return GestureDetector(
      onTapDown: (_) =>
          simulateKeyEvent(keyString, codeString, keyCode, 'keydown'),
      onTapUp: (_) => simulateKeyEvent(keyString, codeString, keyCode, 'keyup'),
      onTapCancel: () =>
          simulateKeyEvent(keyString, codeString, keyCode, 'keyup'),
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(16), // زيادة الحجم قليلاً لسهولة اللمس
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 36), // تكبير الأيقونة
      ),
    );
  }

  @override
  void initState() {
    gameDistributionLogic.interstitialAd?.show().then((value) {
      gameDistributionLogic.loadInterstitialAdAd(
        interstitialAdId: 'ca-app-pub-8107574011529731/7525150969',
      );
    });

    if (widget.mobileMode == 'Portrait') {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      setState(() {
        isLandscape = false;
      });
    } else if (widget.mobileMode == 'Landscape') {
      setState(() {
        isLandscape = true;
      });
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }

    super.initState();
  }

  @override
  void dispose() {
    // إرجاع الشاشة للوضع الطولي الافتراضي عند الخروج من اللعبة حتى لا يبقى التطبيق مقلوباً
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // يفضل وضع لون خلفية لتجنب وميض الشاشة
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(
                  "https://html5.gamedistribution.com/${widget.gameId}/",
                ),
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([
                adSkipScript,
              ]),
              initialSettings: InAppWebViewSettings(
                contentBlockers: contentBlockers,
                javaScriptEnabled: true,
                transparentBackground: true,
                mediaPlaybackRequiresUserGesture:
                    false, // مطلوب للسماح بأصوات اللعبة بالعمل فوراً
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;

                // إنشاء قناة اتصال بين الجافاسكربت وفلاتر
                controller.addJavaScriptHandler(
                  handlerName: 'OrientationHandler',
                  callback: (args) {
                    // args[0] ستحتوي على كلمة 'landscape' أو 'portrait'
                    String orientation = args[0];
                    debugPrint("Game Orientation Detected: $orientation");

                    if (orientation == 'landscape') {
                      // قلب الشاشة بالعرض
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft,
                      ]);
                    } else {
                      // ترك الشاشة بالطول
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]);
                    }
                  },
                );
              },
              onLoadStop: (controller, url) async {
                // بعد انتهاء تحميل الصفحة، نحقن كود يفحص أبعاد اللعبة
                // ونرسل النتيجة إلى الـ Handler الذي أنشأناه بالأعلى
                await controller.evaluateJavascript(
                  source: """
              setTimeout(function() {
                function detectGameOrientation() {
                  // محاولة البحث عن إعدادات اللعبة في الـ DOM
                  var meta = document.querySelector('meta[name="screen-orientation"]');
                  if (meta && meta.content) return meta.content;

                  // إذا لم توجد، نفحص أبعاد لوحة الرسم (Canvas) الخاصة باللعبة
                  var canvas = document.querySelector('canvas');
                  if (canvas) {
                    return canvas.width > canvas.height ? 'landscape' : 'portrait';
                  }

                  return 'portrait'; // الوضع الافتراضي
                }
                
                var orientation = detectGameOrientation();
                // إرسال النتيجة إلى فلاتر
                window.flutter_inappwebview.callHandler('OrientationHandler', orientation);
              }, 1500); // ننتظر ثانية ونصف حتى تأخذ اللعبة أبعادها الحقيقية
            """,
                );
              },
              onReceivedError: (controller, request, error) {
                debugPrint("WebView Error: ${error.description}");
              },
            ),
            Positioned(
              bottom: 20,
              right: 20,
              // يمكنك تغييرها إلى left: 20 إذا أردت الزر على اليسار
              child: FloatingActionButton(
                mini: true,
                // يجعله بحجم أصغر ومناسب للألعاب
                backgroundColor: Colors.black.withOpacity(0.5),
                // لون شبه شفاف لعدم حجب اللعبة
                elevation: 0,
                onPressed: toggleOrientation,
                child: Icon(
                  // تغيير الأيقونة بناءً على الوضع الحالي
                  isLandscape
                      ? Icons.screen_lock_portrait
                      : Icons.screen_rotation,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
