import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/models/login_model.dart';
import 'package:grass/app/data/utils/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/utils/prefs_constant.dart';
import '../routes/app_pages.dart';

class WebViewWidget extends StatefulWidget {
  const WebViewWidget({super.key});

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (webViewController != null && await webViewController!.canGoBack()) {
          return await webViewController!.goBack();
        }
      },
      child: InAppWebView(
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          sharedCookiesEnabled: true,
          thirdPartyCookiesEnabled: true,
          cacheEnabled: true,
          domStorageEnabled: true,
          databaseEnabled: true,
        ),
        initialUrlRequest: URLRequest(url: WebUri(Url.webUrl)),
        onWebViewCreated: (controller) {
          // Assign the created controller to the local state variable
          setState(() {
            webViewController = controller;
          });
        },
        onLoadStop: (controller, url) {
          log("Page loaded: $url");
          // Inject JavaScript to capture fetch responses
          controller.evaluateJavascript(source: """
          (function() {
            var originalFetch = window.fetch;
            window.fetch = function() {
              return originalFetch.apply(this, arguments)
                .then(async function(response) {
                  var requestUrl = response.url;
                  var clonedResponse = response.clone();
      
                  var headersObj = {};
                  response.headers.forEach(function(value, key) {
                    headersObj[key] = value;
                  });
      
                  var responseBody;
                  try {
                    responseBody = await clonedResponse.json();
                  } catch (e) {
                    responseBody = await clonedResponse.text();
                  }
                  if(requestUrl.includes("api")){
                    console.log("FETCH RESPONSE :", JSON.stringify({
                      url: requestUrl,
                      status: response.status,
                      headers: headersObj,
                      data: responseBody
                    }));
                  }
                  return response;
                });
            };
          })();
          """);
        },
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT);
        },
        onConsoleMessage: (controller, consoleMessage) async {
          String message = consoleMessage.message;
          if (message.contains("Extension") ||
              message.contains("not installed")) {
            return;
          }
          if (message.contains("FETCH RESPONSE :")) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String resMsg = message.split(" : ").last.trim();
            log("FETCH RESPONSE : $resMsg");
            Map<String, dynamic> response = jsonDecode(resMsg);
            String url = response['url'];
            Map<String, dynamic> headers = response['headers'];
            Map<String, dynamic> data = response['data'];

            log("""
            FETCH Request URL       : $url
            FETCH Request HEADERS   : $headers
            FETCH Request BODY      : $data
            """);
            if (url.contains("login")) {
              if (response["status"] == 200) {
                LoginModel loginRes = LoginModel.fromJson(data);
                await prefs.setString(
                    PrefsConstant.token, loginRes.result!.data!.accessToken!);
                await prefs.setString(PrefsConstant.refreshToken,
                    loginRes.result!.data!.refreshToken!);
                await prefs.setString(
                    PrefsConstant.userId, loginRes.result!.data!.userId!);
                await prefs.setString(
                    PrefsConstant.userAgent,
                    await controller.evaluateJavascript(
                        source: "navigator.userAgent") as String);
                await prefs.setBool(PrefsConstant.loginStatus, true);
                Get.offAllNamed(Routes.HOME);
              }
            }
            if (url.contains("revokeToken")) {
              if (response["status"] == 200) {
                await prefs.remove(PrefsConstant.userId);
                await prefs.remove(PrefsConstant.token);
                await prefs.remove(PrefsConstant.refreshToken);
                await prefs.setBool(PrefsConstant.loginStatus, false);
                await CookieManager.instance().deleteAllCookies();
                await InAppWebViewController.clearAllCache();
                controller.dispose();
                Get.offAllNamed(Routes.LOGIN);
              }
            }
          }
        },
        shouldInterceptFetchRequest: (controller, fetchRequest) async {
          if (fetchRequest.url!.toString().contains('/dashboard')) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (Get.currentRoute == Routes.LOGIN &&
                prefs.getString(PrefsConstant.token) != null) {
              controller.dispose();
              Get.offAllNamed(Routes.HOME);
            }
          }
          return fetchRequest;
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url.toString();
          if (url.contains("/register") && !url.contains("dVd4bPfawQRfeia")) {
            await controller.loadUrl(
              urlRequest: URLRequest(
                  url: WebUri(
                      "${Url.webUrl}/register?referralCode=dVd4bPfawQRfeia")),
            );
            return NavigationActionPolicy.CANCEL;
          }

          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
