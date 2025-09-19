import 'dart:typed_data'; // Uint8List için
import 'package:flutter/material.dart';
import 'package:ogu_not_sistemi_v2/core/theme/app_colors.dart';
// import '../bloc/auth_bloc.dart'; // AuthBloc ve AuthState eklendiğinde

class CaptchaCard extends StatelessWidget {
  final TextEditingController captchaController;
  final Uint8List? captchaImageBytes;
  final bool isLoading;
  final String? errorMessage;

  const CaptchaCard({
    super.key,
    required this.captchaController,
    this.captchaImageBytes,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Parametreler artık doğrudan widget'a geliyor.
    // const bool isLoading =
    //     false;
    // final Uint8List? captchaImageBytes =
    //     null;
    // final String? errorMessage =
    //     null;

    return Card(
      color: AppColors.cardLilacBg, // Kivy'deki gibi farklı arka plan
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Güvenlik Doğrulaması',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 15),
            Container(
              height: 70,
              width: double.infinity, // Genişliği doldurması için
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: _buildCaptchaContent(
                isLoading, // widget'tan gelen isLoading
                captchaImageBytes, // widget'tan gelen captchaImageBytes
                errorMessage, // widget'tan gelen errorMessage
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: captchaController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: 'Yukarıdaki kodu girin',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptchaContent(
    bool isLoading,
    Uint8List? imageBytes,
    String? errorMsg,
  ) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.appBarColor),
          ),
        ),
      );
    } else if (errorMsg != null && errorMsg.contains("CAPTCHA")) {
      // Veya daha spesifik bir hata kontrolü
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          errorMsg,
          style: const TextStyle(color: AppColors.gradeRed, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    } else if (imageBytes != null) {
      return Image.memory(imageBytes, fit: BoxFit.contain);
    }
    return const Text(
      'CAPTCHA resmi bekleniyor...',
    ); // Başlangıç durumu veya yüklenemedi durumu
  }
}
