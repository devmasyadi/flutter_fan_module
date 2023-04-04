import 'package:flutter_core_ads_manager/iadsmanager/i_ads.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_fan_module_method_channel.dart';

abstract class FlutterFanModulePlatform extends PlatformInterface
    implements IAds {
  /// Constructs a FlutterFanModulePlatform.
  FlutterFanModulePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterFanModulePlatform _instance = MethodChannelFlutterFanModule();

  /// The default instance of [FlutterFanModulePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterFanModule].
  static FlutterFanModulePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterFanModulePlatform] when
  /// they register themselves.
  static set instance(FlutterFanModulePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
