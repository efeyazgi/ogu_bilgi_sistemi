import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ogu_not_sistemi_v2/core/services/ogubs_service.dart';
import 'package:ogu_not_sistemi_v2/core/services/storage_service.dart'; // StorageService import edildi
import 'package:ogu_not_sistemi_v2/features/auth/data/models/login_page_data.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final OgubsService _ogubsService;
  final StorageService _storageService; // StorageService eklendi

  // Geçici olarak LoginPageData'yı saklamak için
  LoginPageData? _lastLoadedPageData;

  AuthBloc({
    required OgubsService ogubsService,
    required StorageService storageService, // Parametre olarak eklendi
  }) : _ogubsService = ogubsService,
       _storageService = storageService, // Atama yapıldı
       super(AuthInitial()) {
    on<LoadCaptchaAndPageData>(_onLoadCaptchaAndPageData);
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<LoadSavedCredentials>(_onLoadSavedCredentials);
    on<LogoutButtonPressed>(_onLogoutButtonPressed);
  }

  Future<void> _onLoadCaptchaAndPageData(
    LoadCaptchaAndPageData event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPageDataLoading());
    try {
      final loginPageData = await _ogubsService.fetchLoginPageData();
      _lastLoadedPageData = loginPageData; // Son yüklenen veriyi sakla
      if (loginPageData.captchaImageBytes != null) {
        emit(AuthPageDataLoaded(loginPageData: loginPageData));
      } else {
        // CAPTCHA resmi null ise, bu genellikle bir indirme hatasıdır.
        // Kullanıcıya CAPTCHA'nın yüklenemediğini bildirebiliriz.
        emit(
          AuthFailure(
            message: 'CAPTCHA resmi yüklenemedi. Lütfen tekrar deneyin.',
            loginPageData: loginPageData.copyWith(
              setCaptchaBytesToNull: true,
            ), // CAPTCHA'sız veriyi gönder
          ),
        );
      }
    } catch (e) {
      emit(AuthFailure(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoginInProgress());

    if (_lastLoadedPageData == null) {
      emit(
        const AuthFailure(
          message: 'Sayfa bilgileri yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
      add(
        LoadCaptchaAndPageData(),
      ); // Sayfa bilgilerini ve CAPTCHA'yı yeniden yükle
      return;
    }

    try {
      final Map<String, String>? userInfo = await _ogubsService.login(
        studentNumber: event.studentNumber,
        password: event.password,
        captcha: event.captcha,
        loginPageData: _lastLoadedPageData!,
      );

      if (userInfo != null) {
        if (event.rememberMe) {
          await _storageService.saveCredentials(
            event.studentNumber,
            event.password,
          );
        } else {
          // "Beni Hatırla" seçili değilse, sadece mevcut kimlik bilgilerini sil.
          // Bu, başka bir kullanıcının kayıtlı bilgilerini etkilemez.
          await _storageService.deleteCredentials();
        }

        final studentName = userInfo['studentName'];
        final studentNumber = userInfo['studentNumber'];

        if (studentName != null && studentNumber != null) {
          emit(
            AuthLoginSuccess(
              username: studentName,
              studentNumber: studentNumber,
            ),
          );
        } else {
          // Bu durum, servisin null map veya eksik anahtar döndürmesi gibi
          // beklenmedik bir senaryoda oluşabilir.
          emit(
            const AuthFailure(
              message: 'Öğrenci bilgileri alınamadı. Lütfen tekrar deneyin.',
            ),
          );
          add(LoadCaptchaAndPageData());
        }
      } else {
        emit(
          AuthFailure(
            message:
                'Giriş başarısız! Bilgileri kontrol edin veya CAPTCHA yanlış.',
            // Başarısız giriş sonrası VIEWSTATE vb. değişmiş olabilir, bu yüzden
            // _lastLoadedPageData'yı doğrudan kullanmak yerine CAPTCHA'yı yeniden yüklüyoruz.
            // Eğer VIEWSTATE değişmiyorsa, _lastLoadedPageData?.copyWith(setCaptchaBytesToNull: true) kullanılabilir.
          ),
        );
        add(
          LoadCaptchaAndPageData(),
        ); // Başarısız giriş sonrası CAPTCHA'yı yeniden yükle
      }
    } catch (e) {
      emit(
        AuthFailure(
          message: 'Giriş sırasında bir hata oluştu: ${e.toString()}',
        ),
      );
      add(
        LoadCaptchaAndPageData(),
      ); // Hata durumunda da CAPTCHA'yı yeniden yükle
    }
  }

  Future<void> _onLoadSavedCredentials(
    LoadSavedCredentials event,
    Emitter<AuthState> emit,
  ) async {
    final credentials = await _storageService.loadCredentials();
    if (credentials != null &&
        credentials['studentNumber'] != null &&
        credentials['password'] != null) {
      emit(
        AuthCredentialsLoaded(
          studentNumber: credentials['studentNumber']!,
          password: credentials['password']!,
        ),
      );
      // AuthCredentialsLoaded state'i sonrası LoginScreen UI'da inputları dolduracak.
      // Ardından CAPTCHA yüklemesi için LoadCaptchaAndPageData event'i LoginScreen'in initState'inde
      // veya AuthCredentialsLoaded state'ini dinleyen bir BlocListener içinde tetiklenebilir.
      // Şimdilik burada bırakalım, LoginScreen'in bu state'i nasıl ele alacağına bakalım.
      // Eğer LoginScreen'de AuthCredentialsLoaded sonrası otomatik CAPTCHA yüklemesi isteniyorsa,
      // LoginScreen'deki BlocListener'a bu mantık eklenebilir veya buradan doğrudan add(LoadCaptchaAndPageData()) çağrılabilir.
      // Mevcut durumda main.dart'ta LoadSavedCredentials sonrası LoadCaptchaAndPageData çağrılmıyor,
      // bu yüzden burada çağırmak daha mantıklı.
      add(LoadCaptchaAndPageData());
    } else {
      // Kayıtlı bilgi yoksa direkt CAPTCHA yükle
      add(LoadCaptchaAndPageData());
    }
  }

  Future<void> _onLogoutButtonPressed(
    LogoutButtonPressed event,
    Emitter<AuthState> emit,
  ) async {
    // await _storageService.deleteCredentials(); // Kullanıcı isteği üzerine bu satır kaldırıldı.
    _ogubsService.clearSessionCookies(); // Session cookielerini temizle
    _lastLoadedPageData = null; // Saklanan sayfa verilerini temizle
    emit(
      AuthLoggedOut(),
    ); // Bu state GradesScreen tarafından dinlenip LoginScreen'e yönlendirecek.
    // LoginScreen initState'de LoadCaptchaAndPageData çağıracak.
  }
}
