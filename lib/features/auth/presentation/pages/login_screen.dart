import 'dart:typed_data'; // Uint8List için eklendi
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogu_not_sistemi/core/theme/app_colors.dart';
import '../widgets/login_form_card.dart';
import '../widgets/captcha_card.dart';
import '../bloc/auth_bloc.dart'; // AuthBloc import edildi
import 'package:ogu_not_sistemi/features/grades/presentation/pages/grades_screen.dart'; // GradesScreen import edildi
import 'package:ogu_not_sistemi/features/grades/presentation/bloc/grades_bloc.dart'; // GradesBloc import edildi (event göndermek için)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    // Sayfa ilk yüklendiğinde CAPTCHA ve sayfa verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(LoadCaptchaAndPageData());
    });
  }

  @override
  void dispose() {
    _studentNumberController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void _onLoginButtonPressed() {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(
      LoginButtonPressed(
        studentNumber: _studentNumberController.text.trim(),
        password: _passwordController.text, // Şifrede boşluk olabilir
        captcha: _captchaController.text.trim(),
        rememberMe: _rememberMe,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600; // Basit bir tablet tespiti

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthCredentialsLoaded) {
          _studentNumberController.text = state.studentNumber;
          _passwordController.text = state.password;
          setState(() {
            _rememberMe =
                true; // Kayıtlı bilgi varsa "Beni Hatırla" seçili gelsin
          });
          // CAPTCHA yüklemesi AuthBloc içinde AuthCredentialsLoaded sonrası tetikleniyor.
        } else if (state is AuthLoginSuccess) {
          // Başarılı giriş sonrası GradesBloc'a notları çekme event'i gönder
          context.read<GradesBloc>().add(LoadInitialGrades());
          // GradesScreen'e yönlendir ve geri dönüş yolunu kapat
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GradesScreen()),
          );
        } else if (state is AuthFailure) {
          // Hata mesajını SnackBar ile göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.gradeRed,
              duration: const Duration(
                seconds: 3,
              ), // Mesajın görünür kalma süresi
            ),
          );
          // statusLabel zaten BlocBuilder içinde güncelleniyor,
          // ama SnackBar daha dikkat çekici olabilir.
        }
      },
      child: Scaffold(
        // appBar: AppBar(title: const Text('Öğrenci Girişi')), // Kivy tasarımında appbar yok
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            // SingleChildScrollView yerine CustomScrollView daha esnek
            slivers: [
              SliverToBoxAdapter(child: _buildTopHeader(context)),
              SliverToBoxAdapter(
                // SliverFillRemaining yerine SliverToBoxAdapter
                child: SingleChildScrollView(
                  // İçeriği kaydırılabilir yapmak için
                  child: Center(
                    // İçeriği yatayda ve dikeyde ortalamak için
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet
                            ? screenSize.width * 0.15
                            : 25.0, // Tablette daha fazla yan boşluk
                        vertical: 20.0,
                      ),
                      child: ConstrainedBox(
                        // İçeriğin maksimum genişliğini sınırlar
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 500 : double.infinity,
                          // minHeight:
                          //     screenSize.height -
                          //     // kToolbarHeight - // AppBar olmadığından bu sorun yaratabilir
                          //     MediaQuery.of(context).padding.top - // SafeArea zaten bunu hesaba katıyor olabilir
                          //     MediaQuery.of(context).padding.bottom -
                          //     (25+30+20+5) - // _buildTopHeader yaklaşık yüksekliği
                          //     (5+5+10), // _buildAuthorBar yaklaşık yüksekliği
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Dikeyde ortala
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // TODO: LoginForm widget'ı buraya gelecek
                            LoginFormCard(
                              studentNumberController: _studentNumberController,
                              passwordController: _passwordController,
                              initialRememberMe: _rememberMe,
                              onRememberMeChanged: (value) {
                                setState(() {
                                  _rememberMe = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                // CaptchaCard'a state'ten gelen verileri ve durumu aktar
                                Uint8List? captchaBytes;
                                bool isLoading =
                                    state is AuthPageDataLoading ||
                                    state is AuthLoginInProgress;
                                String? errorMessage;

                                if (state is AuthPageDataLoaded) {
                                  captchaBytes =
                                      state.loginPageData.captchaImageBytes;
                                } else if (state is AuthFailure) {
                                  errorMessage = state.message;
                                  // Hata durumunda bile eski CAPTCHA'yı göstermek için
                                  // (eğer _lastLoadedPageData'da varsa)
                                  captchaBytes =
                                      state.loginPageData?.captchaImageBytes;
                                }

                                return CaptchaCard(
                                  captchaController: _captchaController,
                                  captchaImageBytes: captchaBytes,
                                  isLoading: isLoading,
                                  errorMessage: errorMessage,
                                );
                              },
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: _onLoginButtonPressed,
                              child: const Text('Giriş Yap'),
                            ),
                            const SizedBox(height: 15),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                String statusMessage =
                                    "Giriş için bilgilerinizi ve CAPTCHA'yı girin.";
                                Color statusColor = AppColors.textHint;

                                if (state is AuthPageDataLoading) {
                                  statusMessage =
                                      "CAPTCHA ve sayfa bilgileri yükleniyor...";
                                } else if (state is AuthPageDataLoaded) {
                                  statusMessage =
                                      "CAPTCHA yüklendi. Kodu girin.";
                                } else if (state is AuthLoginInProgress) {
                                  statusMessage = "Giriş deneniyor...";
                                } else if (state is AuthFailure) {
                                  statusMessage = state.message;
                                  statusColor = AppColors.gradeRed;
                                } else if (state is AuthLoginSuccess) {
                                  statusMessage =
                                      "Giriş Başarılı! Veriler alınıyor...";
                                  statusColor = AppColors.gradeGreen;
                                }
                                // Diğer durumlar için mesajlar eklenebilir

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusLabelBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    statusMessage,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: statusColor),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20), // Alt boşluk
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildAuthorBar(context)),
            ],
          ), // CustomScrollView için kapanış parantezi
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
      color: AppColors.appBarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_logo.png', // Doğru logo dosyası
                height: 50, // Boyut küçültüldü
                width: 50,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Öğrenci Not Sistemi',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'ESOGÜ Notlarınızı Görüntüleyin',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textLight.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      alignment: Alignment.centerRight,
      child: Text(
        'Hazırlayan : Efe YAZGI',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
      ),
    );
  }
}
