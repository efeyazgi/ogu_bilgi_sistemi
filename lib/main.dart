import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogu_not_sistemi_v2/core/services/ogubs_service.dart';
import 'package:ogu_not_sistemi_v2/core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/grades/presentation/bloc/grades_bloc.dart';
import 'features/schedule/presentation/bloc/schedule_bloc.dart';
import 'features/grades/presentation/bloc/grade_details_cubit.dart';
import 'features/grades/presentation/pages/main_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr');
  runApp(const OgubsApp());
}

class OgubsApp extends StatelessWidget {
  const OgubsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<OgubsService>(create: (context) => OgubsService()),
        RepositoryProvider<StorageService>(create: (context) => StorageService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              ogubsService: context.read<OgubsService>(),
              storageService: context.read<StorageService>(),
            )..add(LoadSavedCredentials()),
          ),
          BlocProvider<GradesBloc>(
            create: (context) => GradesBloc(
              ogubsService: context.read<OgubsService>(),
            ),
          ),
          BlocProvider<ScheduleBloc>(
            create: (context) => ScheduleBloc(
              ogubsService: context.read<OgubsService>(),
            ),
          ),
          BlocProvider<GradeDetailsCubit>(
            create: (context) => GradeDetailsCubit(
              context.read<OgubsService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'OGUBS Not Sistemi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoginSuccess) {
                return const MainScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
