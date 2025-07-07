part of 'auth_bloc.dart';

// import 'package:equatable/equatable.dart'; // Bu satır kaldırılacak, auth_bloc.dart'a taşınacak
// import 'package:ogu_not_sistemi/features/auth/data/models/login_page_data.dart'; // Bu satır kaldırılacak

abstract class AuthState extends Equatable {
  // Equatable importu auth_bloc.dart'ta olacak
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu, henüz hiçbir işlem yapılmadı
class AuthInitial extends AuthState {}

// Kaydedilmiş bilgiler yüklendiğinde (UI'ın inputları doldurması için)
class AuthCredentialsLoaded extends AuthState {
  final String studentNumber;
  final String password;

  const AuthCredentialsLoaded({
    required this.studentNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [studentNumber, password];
}

// CAPTCHA ve sayfa verileri yükleniyor
class AuthPageDataLoading extends AuthState {}

// CAPTCHA ve sayfa verileri başarıyla yüklendi
class AuthPageDataLoaded extends AuthState {
  final LoginPageData loginPageData;

  const AuthPageDataLoaded({required this.loginPageData});

  @override
  List<Object?> get props => [loginPageData];
}

// Giriş işlemi deneniyor
class AuthLoginInProgress extends AuthState {}

// Giriş başarılı, kullanıcı kimliği doğrulandı
class AuthLoginSuccess extends AuthState {
  final String username;
  final String studentNumber;

  const AuthLoginSuccess({required this.username, required this.studentNumber});

  @override
  List<Object> get props => [username, studentNumber];
}

// Herhangi bir işlem sırasında hata oluştu (CAPTCHA yükleme, giriş vb.)
class AuthFailure extends AuthState {
  final String message;
  final LoginPageData?
  loginPageData; // Hata durumunda bile CAPTCHA'yı tekrar göstermek için

  const AuthFailure({required this.message, this.loginPageData});

  @override
  List<Object?> get props => [message, loginPageData];
}

// Kullanıcı çıkış yaptı (ileride eklenecek özellik)
class AuthLoggedOut extends AuthState {}
