import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_core_ads_manager/callback_ads.dart';
import 'package:flutter_core_ads_manager/iadsmanager/i_initialize.dart';
import 'package:flutter_core_ads_manager/iadsmanager/i_rewards.dart';
import 'package:flutter_core_ads_manager/size_ads.dart';
import 'package:flutter_fan_module/flutter_fan_module.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool _isShowBanner = false;
  bool _isShowNative = false;
  final _flutterFanModulePlugin = FlutterFanModule();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _flutterFanModulePlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                onPressed: () {
                  _flutterFanModulePlugin.initialize(
                    context,
                    "",
                    IInitialize(
                      onInitializationComplete: () async {
                        debugPrint('Initialization complete!');
                        _flutterFanModulePlugin.setTestDevices(
                            context, ["f6d5e07a-cb29-4880-8b2a-04a686b91bc1"]);
                        _flutterFanModulePlugin.loadInterstitial(
                            context, "1363711600744576_1508878896227845");
                        _flutterFanModulePlugin.loadRewards(
                            context, "1363711600744576_1508879032894498");
                      },
                    ),
                  );
                },
                child: const Text("Initialize"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isShowBanner = !_isShowBanner;
                  });
                },
                child: const Text("Show Banner"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isShowNative = !_isShowNative;
                  });
                },
                child: const Text("Show Native"),
              ),
              ElevatedButton(
                onPressed: () {
                  _flutterFanModulePlugin.showInterstitial(
                    context,
                    "1363711600744576_1508878896227845",
                    CallbackAds(
                      onAdLoaded: (message) {
                        debugPrint('HALLO: onAdLoaded');
                      },
                      onAdFailedToLoad: (error) {
                        debugPrint('HALLO: onAdFailedToLoad $error');
                      },
                    ),
                  );
                },
                child: const Text("Show Intersitial"),
              ),
              ElevatedButton(
                onPressed: () {
                  _flutterFanModulePlugin.showRewards(
                      context,
                      "1363711600744576_1508879032894498",
                      CallbackAds(
                        onAdLoaded: (message) {
                          debugPrint('HALLO rewards: onAdLoaded');
                        },
                        onAdFailedToLoad: (error) {
                          debugPrint('HALLO rewards: onAdFailedToLoad $error');
                        },
                      ), IRewards(
                    onUserEarnedReward: (rewardsItem) {
                      debugPrint(
                          'HALLO rewards: onUserEarnedReward $rewardsItem');
                    },
                  ));
                },
                child: const Text("Show Rewards"),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isShowBanner)
                    _flutterFanModulePlugin.showBanner(
                      context,
                      SizeBanner.SMALL,
                      "1363711600744576_1363713000744436",
                      CallbackAds(
                        onAdLoaded: (message) {
                          debugPrint('Banner bro: onAdLoaded $message');
                        },
                        onAdFailedToLoad: (error) {
                          debugPrint('onAdFailedToLoad $error');
                        },
                      ),
                    ),
                  if (_isShowNative)
                    _flutterFanModulePlugin.showNativeAds(
                      context,
                      SizeNative.SMALL_RECTANGLE,
                      "1363711600744576_1508905206225214",
                      CallbackAds(
                        onAdLoaded: (message) {
                          debugPrint('Native bro: onAdLoaded $message');
                        },
                        onAdFailedToLoad: (error) {
                          debugPrint('Native onAdFailedToLoad $error');
                        },
                      ),
                    ),
                  const Text("Test"),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
