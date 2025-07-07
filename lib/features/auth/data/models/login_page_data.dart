import 'dart:typed_data';

class LoginPageData {
  final String viewState;
  final String viewStateGenerator;
  final String eventValidation;
  final String captchaRelativeUrl; // CAPTCHA resminin göreceli URL'si
  final Uint8List? captchaImageBytes; // İndirilen CAPTCHA resmi byte dizisi

  LoginPageData({
    required this.viewState,
    required this.viewStateGenerator,
    required this.eventValidation,
    required this.captchaRelativeUrl,
    this.captchaImageBytes,
  });

  // Gerekirse kopyalama veya güncelleme için bir copyWith metodu eklenebilir
  LoginPageData copyWith({
    String? viewState,
    String? viewStateGenerator,
    String? eventValidation,
    String? captchaRelativeUrl,
    Uint8List? captchaImageBytes,
    bool setCaptchaBytesToNull = false, // captchaImageBytes'ı null yapmak için
  }) {
    return LoginPageData(
      viewState: viewState ?? this.viewState,
      viewStateGenerator: viewStateGenerator ?? this.viewStateGenerator,
      eventValidation: eventValidation ?? this.eventValidation,
      captchaRelativeUrl: captchaRelativeUrl ?? this.captchaRelativeUrl,
      captchaImageBytes: setCaptchaBytesToNull
          ? null
          : captchaImageBytes ?? this.captchaImageBytes,
    );
  }

  @override
  String toString() {
    return 'LoginPageData(viewState: $viewState, viewStateGenerator: $viewStateGenerator, eventValidation: $eventValidation, captchaRelativeUrl: $captchaRelativeUrl, captchaImageBytes: ${captchaImageBytes != null ? "Present" : "Absent"})';
  }
}
