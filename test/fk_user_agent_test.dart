import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('fk_user_agent');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    FkUserAgent.release();
  });

  test('reads properties from the native channel when available', () async {
    messenger.setMockMethodCallHandler(
        channel, (MethodCall methodCall) async => <String, dynamic>{
              'userAgent': 'Native/1.0',
            });

    await FkUserAgent.init(force: true);

    expect(FkUserAgent.userAgent, 'Native/1.0');
  });

  test('generates a desktop user agent when no native implementation exists',
      () async {
    messenger.setMockMethodCallHandler(
        channel, (MethodCall methodCall) async {
      throw MissingPluginException('fk_user_agent');
    });

    await FkUserAgent.init(force: true);

    expect(FkUserAgent.userAgent, contains('Mozilla/5.0'));
    expect(FkUserAgent.webViewUserAgent, isNotNull);
    expect(FkUserAgent.getProperty('systemName'), isNotEmpty);
    expect(FkUserAgent.getProperty('systemVersion'), isNotEmpty);
  });
}
