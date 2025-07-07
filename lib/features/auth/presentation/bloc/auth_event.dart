part of 'auth_bloc.dart';

// import 'package:equatable/equatable.dart'; // Bu satır kaldırılacak, auth_bloc.dart'a taşınacak

abstract class AuthEvent extends Equatable {
  // 'with' yerine 'extends' kullanılacak
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Sayfa ilk yüklendiğinde veya CAPTCHA yenilenmek istendiğinde tetiklenir
class LoadCaptchaAndPageData extends AuthEvent {}

// Kullanıcı giriş butonuna bastığında tetiklenir
class LoginButtonPressed extends AuthEvent {
  final String studentNumber;
  final String password;
  final String captcha;
  final bool rememberMe;

  const LoginButtonPressed({
    required this.studentNumber,
    required this.password,
    required this.captcha,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [studentNumber, password, captcha, rememberMe];
}

// Kaydedilmiş kullanıcı bilgilerini yüklemek için (opsiyonel)
class LoadSavedCredentials extends AuthEvent {}

// Kullanıcı çıkış yaptığında (ileride eklenecek özellik)
class LogoutButtonPressed extends AuthEvent {}
