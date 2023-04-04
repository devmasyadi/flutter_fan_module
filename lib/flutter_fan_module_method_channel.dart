import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core_ads_manager/rewards/rewards_item.dart';
import 'package:flutter_core_ads_manager/size_ads.dart';
import 'package:flutter_core_ads_manager/iadsmanager/i_rewards.dart';
import 'package:flutter_core_ads_manager/iadsmanager/i_initialize.dart';
import 'package:flutter_core_ads_manager/callback_ads.dart';
import 'package:flutter_fan_module/ads/banner_view.dart';
import 'package:flutter_fan_module/ads/native_view.dart';

import 'flutter_fan_module_platform_interface.dart';

/// An implementation of [FlutterFanModulePlatform] that uses method channels.
class MethodChannelFlutterFanModule extends FlutterFanModulePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_fan_module');
  static const BasicMessageChannel<String> _callbackChannel =
      BasicMessageChannel<String>('flutter_fan_module_callback', StringCodec());

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void initialize(
      BuildContext context, String? appId, IInitialize? iInitialize) async {
    _callbackChannel.setMessageHandler((message) {
      try {
        final parts = message!.split('|');
        final event = parts[0];
        switch (event) {
          case 'onInitializationComplete':
            iInitialize?.onInitializationComplete!();
            break;
        }
        return Future.value(event);
      } catch (err) {
        debugPrint(err.toString());
        return Future.value(err.toString());
      }
    });

    await methodChannel.invokeMethod('initialize', {"appId": appId});
  }

  @override
  Future<void> loadGdpr(BuildContext context, bool childDirected) async {
    await methodChannel
        .invokeMethod("loadGdpr", {"childDirected": childDirected});
  }

  @override
  void loadInterstitial(BuildContext context, String adUnitId) {
    methodChannel.invokeMethod("loadInterstitial", {"adUnitId": adUnitId});
  }

  @override
  void loadRewards(BuildContext context, String adUnitId) {
    methodChannel.invokeMethod("loadRewards", {"adUnitId": adUnitId});
  }

  @override
  Future<void> setTestDevices(
      BuildContext context, List<String> testDevices) async {
    await methodChannel
        .invokeMethod("setTestDevices", {"testDevices": testDevices});
    return Future.value();
  }

  @override
  Widget showBanner(BuildContext context, SizeBanner sizeBanner,
      String adUnitId, CallbackAds? callbackAds) {
    return BannerView(
      adUnitId: adUnitId,
      callbackAds: callbackAds,
      sizeBanner: sizeBanner,
    );
  }

  @override
  void showInterstitial(
      BuildContext context, String adUnitId, CallbackAds? callbackAds) {
    _callbackChannel.setMessageHandler((message) {
      try {
        final parts = message!.split('|');
        final event = parts[0];
        final data = parts[1];

        switch (event) {
          case 'InterstitialAdLoaded':
            callbackAds?.onAdLoaded?.call(data);
            break;
          case 'InterstitialAdFailedToLoad':
            callbackAds?.onAdFailedToLoad?.call(data);
            break;
        }
        return Future.value(event);
      } catch (err) {
        callbackAds?.onAdFailedToLoad?.call(err.toString());
        return Future.value(err.toString());
      }
    });

    methodChannel.invokeMethod('showInterstitial', {"adUnitId": adUnitId});
  }

  @override
  Widget showNativeAds(BuildContext context, SizeNative sizeNative,
      String adUnitId, CallbackAds? callbackAds) {
    return NativeView(
      adUnitId: adUnitId,
      callbackAds: callbackAds,
      sizeNative: sizeNative,
    );
  }

  @override
  void showRewards(BuildContext context, String adUnitId,
      CallbackAds? callbackAds, IRewards? iRewards) {
    _callbackChannel.setMessageHandler((message) {
      try {
        final parts = message!.split('|');
        final event = parts[0];
        final data = parts[1];

        switch (event) {
          case 'RewardsAdLoaded':
            callbackAds?.onAdLoaded?.call(data);
            break;
          case 'RewardsAdFailedToLoad':
            callbackAds?.onAdFailedToLoad?.call(data);
            break;
          case 'RewardsUserEarnedReward':
            iRewards?.onUserEarnedReward
                ?.call(RewardsItem(amount: 10, type: "coin"));
            break;
        }
        debugPrint("parts $parts");
        return Future.value(event);
      } catch (err) {
        callbackAds?.onAdFailedToLoad?.call(err.toString());
        return Future.value(err.toString());
      }
    });

    methodChannel.invokeMethod('showRewards', {"adUnitId": adUnitId});
  }
}
