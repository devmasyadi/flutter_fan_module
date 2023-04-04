import 'package:flutter/material.dart';
import 'package:flutter_core_ads_manager/callback_ads.dart';
import 'package:flutter_core_ads_manager/iadsmanager/i_initialize.dart';
import 'package:flutter_core_ads_manager/iadsmanager/i_rewards.dart';
import 'package:flutter_core_ads_manager/size_ads.dart';

import 'flutter_fan_module_platform_interface.dart';

class FlutterFanModule {
  Future<String?> getPlatformVersion() {
    return FlutterFanModulePlatform.instance.getPlatformVersion();
  }

  void initialize(
      BuildContext context, String? appId, IInitialize? iInitialize) {
    return FlutterFanModulePlatform.instance
        .initialize(context, appId, iInitialize);
  }

  void loadGdpr(BuildContext context, bool childDirected) {}

  void loadInterstitial(BuildContext context, String adUnitId) {
    FlutterFanModulePlatform.instance.loadInterstitial(context, adUnitId);
  }

  void loadRewards(BuildContext context, String adUnitId) {
    FlutterFanModulePlatform.instance.loadRewards(context, adUnitId);
  }

  Future<void> setTestDevices(BuildContext context, List<String> testDevices) {
    return FlutterFanModulePlatform.instance
        .setTestDevices(context, testDevices);
  }

  Widget showBanner(BuildContext context, SizeBanner sizeBanner,
      String adUnitId, CallbackAds? callbackAds) {
    return FlutterFanModulePlatform.instance
        .showBanner(context, sizeBanner, adUnitId, callbackAds);
  }

  void showInterstitial(
      BuildContext context, String adUnitId, CallbackAds? callbackAds) {
    FlutterFanModulePlatform.instance
        .showInterstitial(context, adUnitId, callbackAds);
  }

  Widget showNativeAds(BuildContext context, SizeNative sizeNative,
      String adUnitId, CallbackAds? callbackAds) {
    return FlutterFanModulePlatform.instance
        .showNativeAds(context, sizeNative, adUnitId, callbackAds);
  }

  void showRewards(BuildContext context, String adUnitId,
      CallbackAds? callbackAds, IRewards? iRewards) {
    FlutterFanModulePlatform.instance
        .showRewards(context, adUnitId, callbackAds, iRewards);
  }
}
