// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// MaterialApp ve diğer widget'lar için
import 'package:ogu_not_sistemi/main.dart'; // OgubsApp
import 'package:ogu_not_sistemi/features/auth/presentation/pages/login_screen.dart'; // LoginScreen

void main() {
  testWidgets('LoginScreen displays correctly and has initial elements', (
    WidgetTester tester,
  ) async {
    // Build our app (OgubsApp) and trigger a frame.
    await tester.pumpWidget(const OgubsApp());

    // Verify that LoginScreen is shown.
    expect(find.byType(LoginScreen), findsOneWidget);

    // Verify that the top header text is present.
    expect(find.text('Öğrenci Not Sistemi'), findsOneWidget);
    expect(
      find.text('Osmangazi Üniversitesi - Öğrenci Bilgi Sistemi'),
      findsOneWidget,
    );

    // Verify that "Giriş Bilgileri" card title is present.
    expect(find.text('Giriş Bilgileri'), findsOneWidget);

    // Verify that "Güvenlik Doğrulaması" card title is present.
    expect(find.text('Güvenlik Doğrulaması'), findsOneWidget);

    // Verify that the "Notları Getir" button is present.
    expect(
      find.widgetWithText(ElevatedButton, 'Notları Getir'),
      findsOneWidget,
    );

    // Verify that the initial status label text is present.
    expect(
      find.text("Giriş için bilgilerinizi ve CAPTCHA'yı girin."),
      findsOneWidget,
    );

    // Verify author bar
    expect(find.text('Hazırlayan : Efe YAZGI'), findsOneWidget);
  });
}
