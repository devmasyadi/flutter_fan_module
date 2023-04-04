import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fan_module/flutter_fan_module.dart';
import 'package:flutter_fan_module/flutter_fan_module_platform_interface.dart';
import 'package:flutter_fan_module/flutter_fan_module_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterFanModulePlatform
    with MockPlatformInterfaceMixin
    implements FlutterFanModulePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterFanModulePlatform initialPlatform = FlutterFanModulePlatform.instance;

  test('$MethodChannelFlutterFanModule is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterFanModule>());
  });

  test('getPlatformVersion', () async {
    FlutterFanModule flutterFanModulePlugin = FlutterFanModule();
    MockFlutterFanModulePlatform fakePlatform = MockFlutterFanModulePlatform();
    FlutterFanModulePlatform.instance = fakePlatform;

    expect(await flutterFanModulePlugin.getPlatformVersion(), '42');
  });
}
