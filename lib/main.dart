import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogu_not_sistemi_v2/core/services/ogubs_service.dart';
import 'package:ogu_not_sistemi_v2/core/services/storage_service.dart'; // StorageService import edildi
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/grades/presentation/bloc/grades_bloc.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';
// import 'features/grades/presentation/pages/grades_screen.dart';

void main() {
  // Gerekirse burada BLoC observer, HydratedBloc storage gibi başlangıç ayarları yapılabilir.
  runApp(const OgubsApp());
}

class OgubsApp extends StatelessWidget {
  const OgubsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      // Birden fazla servis için MultiRepositoryProvider
      providers: [
        RepositoryProvider<OgubsService>(create: (context) => OgubsService()),
        RepositoryProvider<StorageService>(
          create: (context) => StorageService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(
                  ogubsService: context.read<OgubsService>(),
                  storageService: context
                      .read<StorageService>(), // StorageService eklendi
                )..add(
                  LoadSavedCredentials(),
                ), // Başlangıçta kaydedilmiş bilgileri yükle
            // .add(LoadCaptchaAndPageData()), // Bu LoginScreen initState'te kalabilir veya buraya da eklenebilir
          ),
          BlocProvider<GradesBloc>(
            create: (context) =>
                GradesBloc(ogubsService: context.read<OgubsService>()),
          ),
          BlocProvider<ScheduleBloc>(
            create: (context) =>
                ScheduleBloc(ogubsService: context.read<OgubsService>()),
          ),
        ],
        child: MaterialApp(
          title: 'OGU Bilgi Sistemi',
          theme: AppTheme.theme,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}

// PlaceholderScreen artık kullanılmadığı için kaldırılabilir veya yorum satırı yapılabilir.
// class PlaceholderScreen extends StatelessWidget {
//   const PlaceholderScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('OGÜ Not Sistemi')),
//       body: const Center(
//         child: Text(
//           'Uygulama Geliştiriliyor...',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }
