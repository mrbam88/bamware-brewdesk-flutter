import 'package:brewdesk/ui/features/methodology/methodology_screen.dart';
import 'package:brewdesk/ui/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _FakeUrlLauncher extends UrlLauncherPlatform {
  final List<String> launched = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    launched.add(url);
    return true;
  }
}

void main() {
  late _FakeUrlLauncher fakeLauncher;

  setUp(() {
    fakeLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeLauncher;
    PackageInfo.setMockInitialValues(
      appName: 'BrewDesk',
      packageName: 'io.bamware.brewdesk',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  // The You tab is one long scroll of cards; give the test surface enough
  // height that every row is built (ListView virtualizes off-screen
  // children) instead of scrolling to each row individually.
  Future<void> pumpProfileScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
  }

  testWidgets('How scoring works row navigates to the methodology screen', (
    tester,
  ) async {
    await pumpProfileScreen(tester);

    await tester.tap(find.text('How scoring works'));
    await tester.pumpAndSettle();

    expect(find.byType(MethodologyScreen), findsOneWidget);
    expect(find.text('How Work Fit works'), findsOneWidget);
  });

  testWidgets('version row shows the real package version', (tester) async {
    await pumpProfileScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('1.2.3 (45)'), findsOneWidget);
  });

  testWidgets(
    'Support, Privacy Policy, and Terms of Use rows launch their URLs',
    (tester) async {
      await pumpProfileScreen(tester);

      await tester.tap(find.text('Support'));
      await tester.tap(find.text('Privacy Policy'));
      await tester.tap(find.text('Terms of Use'));
      await tester.pump();

      expect(
        fakeLauncher.launched,
        containsAll(<String>[
          'https://bamware.io/brewdesk/support',
          'https://bamware.io/brewdesk/privacy',
          'https://bamware.io/brewdesk/terms',
        ]),
      );
    },
  );

  testWidgets('open-source licenses row opens the Flutter license page', (
    tester,
  ) async {
    await pumpProfileScreen(tester);

    await tester.tap(find.text('Open-source licenses'));
    await tester.pumpAndSettle();

    expect(find.text('BrewDesk'), findsWidgets);
  });
}
