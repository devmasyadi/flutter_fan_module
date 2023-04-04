import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core_ads_manager/callback_ads.dart';
import 'package:flutter_core_ads_manager/size_ads.dart';

class NativeView extends StatefulWidget {
  final String? adUnitId;
  final SizeNative? sizeNative;
  final CallbackAds? callbackAds;
  const NativeView(
      {super.key, this.adUnitId, this.callbackAds, this.sizeNative});

  @override
  State<NativeView> createState() => _NativeViewState();
}

class _NativeViewState extends State<NativeView> {
  void _configureCallbackChannel() {
    const callbackChannel = BasicMessageChannel<String>(
        'flutter_fan_module_callback', StringCodec());

    callbackChannel.setMessageHandler((String? message) {
      try {
        final parts = message!.split('|');
        final event = parts[0];
        final data = parts[1];
        switch (event) {
          case 'NativeAdLoaded':
            widget.callbackAds?.onAdLoaded?.call(event);
            break;
          case "NativeAdFailedToLoad":
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
    double heighNative = 80;
    if (widget.sizeNative == SizeNative.MEDIUM) {
      sizeString = "Medium";
      heighNative = 300;
    } else if (widget.sizeNative == SizeNative.SMALL_RECTANGLE) {
      sizeString = "Small_Rectangle";
      heighNative = 300;
    }
    if (widget.adUnitId != null && widget.adUnitId?.isNotEmpty == true) {
      return SizedBox(
        height: heighNative,
        width: double.infinity,
        child: AndroidView(
          viewType: 'nativeFan',
          creationParams: {
            'adUnitId': widget.adUnitId,
            'sizeNative': sizeString,
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
