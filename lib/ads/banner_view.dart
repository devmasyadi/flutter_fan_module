import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core_ads_manager/callback_ads.dart';
import 'package:flutter_core_ads_manager/size_ads.dart';

class BannerView extends StatefulWidget {
  final String? adUnitId;
  final SizeBanner? sizeBanner;
  final CallbackAds? callbackAds;
  const BannerView(
      {super.key, this.adUnitId, this.callbackAds, this.sizeBanner});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  void _configureCallbackChannel() {
    const callbackChannel = BasicMessageChannel<String>(
        'flutter_fan_module_callback', StringCodec());

    callbackChannel.setMessageHandler((String? message) {
      try {
        final parts = message!.split('|');
        final event = parts[0];
        final data = parts[1];
        switch (event) {
          case 'BannerAdLoaded':
            widget.callbackAds?.onAdLoaded?.call(event);
            break;
          case "BannerAdFailedToLoad":
            widget.callbackAds?.onAdFailedToLoad?.call(data);
            break;
        }
        return Future.value(event);
      } catch (err) {
        debugPrint(err.toString());
        return Future.value(err.toString());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.adUnitId != null && widget.adUnitId?.isNotEmpty == true) {
      _configureCallbackChannel();
    } else {
      widget.callbackAds?.onAdFailedToLoad?.call("adUnit Empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    var sizeString = "Small";
    if (widget.sizeBanner == SizeBanner.MEDIUM) {
      sizeString = "Medium";
    }
    if (widget.adUnitId != null && widget.adUnitId?.isNotEmpty == true) {
      return SizedBox(
        height: 60,
        width: double.infinity,
        child: AndroidView(
          viewType: 'bannerFan',
          creationParams: {
            'adUnitId': widget.adUnitId,
            'sizeBanner': sizeString,
            'onAdLoaded': widget.callbackAds?.onAdLoaded != null,
            'onAdFailedToLoad': widget.callbackAds?.onAdFailedToLoad != null,
          },
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    }
    return Container();
  }
}
