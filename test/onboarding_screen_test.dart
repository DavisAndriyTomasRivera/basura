import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basura/app/app.dart';
import 'package:basura/app/theme/app_theme.dart';
import 'package:basura/core/constants/app_constants.dart';
import 'package:basura/features/onboarding/screens/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows all onboarding pages and completes from the final page', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: OnboardingScreen(onComplete: () async => completed = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tecnología para un futuro más limpio'), findsOneWidget);
    expect(find.text('PASO 1 DE 3'), findsOneWidget);
    expect(find.byType(Lottie), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(
      find.text('Un proyecto con identidad universitaria'),
      findsOneWidget,
    );
    expect(find.text('PASO 2 DE 3'), findsOneWidget);
    expect(find.text('Ingeniería del Conocimiento'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Detrás de Basura'), findsOneWidget);
    expect(find.text('PASO 3 DE 3'), findsOneWidget);
    expect(find.text('Andriy Tomas Rivera'), findsOneWidget);
    expect(find.text('Echegoyen Rojas Anahi'), findsOneWidget);
    expect(find.text('Espinoza Inga Deysi'), findsOneWidget);
    expect(find.text('Paucar Ramirez Carolina'), findsOneWidget);

    await tester.tap(find.text('Comenzar a explorar'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });

  testWidgets('fits a compact phone viewport without layout exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: OnboardingScreen(onComplete: () async {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(
      find.text('Un proyecto con identidad universitaria'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Comenzar a explorar'), findsOneWidget);
    final exception = tester.takeException();
    expect(exception, isNull, reason: 'Final onboarding page: $exception');
  });

  testWidgets('stores completion so the welcome is not shown on next launch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BasuraApp(initialOnboardingComplete: false));
    await tester.pumpAndSettle();

    for (var page = 0; page < 2; page++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Comenzar a explorar'));
    await tester.pumpAndSettle();
    expect(
      (await SharedPreferences.getInstance()).getBool(
        AppConstants.onboardingCompletedStorageKey,
      ),
      isTrue,
    );

    await tester.pumpWidget(const BasuraApp(initialOnboardingComplete: true));
    await tester.pump();
    expect(find.text('Tecnología para un futuro más limpio'), findsNothing);
  });
}
