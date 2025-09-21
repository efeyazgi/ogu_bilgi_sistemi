import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogu_not_sistemi_v2/core/theme/app_colors.dart';
import 'package:ogu_not_sistemi_v2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ogu_not_sistemi_v2/features/grades/presentation/bloc/grades_bloc.dart';
import 'package:ogu_not_sistemi_v2/features/grades/presentation/widgets/course_info_card.dart';
import 'package:ogu_not_sistemi_v2/features/auth/presentation/pages/login_screen.dart';
import 'package:ogu_not_sistemi_v2/features/grades/data/models/academic_summary_model.dart';
import 'package:ogu_not_sistemi_v2/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:ogu_not_sistemi_v2/core/services/storage_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String? _username;
  String? _studentNumber;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoginSuccess) {
      _username = authState.username;
      _studentNumber = authState.studentNumber;
    }
    context.read<GradesBloc>().add(LoadInitialGrades());
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
        if (authState is AuthLoginSuccess) {
          setState(() {
            _username = authState.username;
            _studentNumber = authState.studentNumber;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 40,
              height: 40,
            ),
          ),
          title: const Text(
            "Ders Notları",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: AppColors.appBarColor,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Çıkış Yap',
              onPressed: () {
                context.read<AuthBloc>().add(LogoutButtonPressed());
                context.read<GradesBloc>().add(ClearGrades());
                context.read<ScheduleBloc>().add(const ClearSchedule());
              },
            ),
          ],
        ),
        body: BlocBuilder<GradesBloc, GradesState>(
          builder: (context, state) {
            if (state is GradesFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Hata:\n${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.gradeRed),
                  ),
                ),
              );
            }

            if (state is GradesInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _buildYearAndTermSelectors(context, state),
                if (state is GradesLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is GradesLoaded)
                  Expanded(child: _buildGradesList(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildYearAndTermSelectors(BuildContext context, GradesState state) {
    if (state.yearOptions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: state.selectedYear,
                  hint: const Text("Yıl Seçin"),
                  items: state.yearOptions
                      .map(
                        (opt) => DropdownMenuItem(
                          value: opt.value,
                          child: Text(opt.text),
                        ),
                      )
                      .toList(),
                  onChanged: (year) {
                    if (year != null && state.selectedTerm != null) {
                      context.read<GradesBloc>().add(
                        FetchGrades(year: year, term: state.selectedTerm!),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: state.selectedTerm,
                  hint: const Text("Dönem Seçin"),
                  items: state.termOptions
                      .map(
                        (opt) => DropdownMenuItem(
                          value: opt.value,
                          child: Text(opt.text),
                        ),
                      )
                      .toList(),
                  onChanged: (term) {
                    if (term != null && state.selectedYear != null) {
                      context.read<GradesBloc>().add(
                        FetchGrades(year: state.selectedYear!, term: term),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesList(BuildContext context, GradesLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildSummaryHeader(
            context,
            state.summary,
            username: _username,
            studentNumber: _studentNumber,
          ),
        ),
        if (state.courses.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.appBarColor.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.warning_amber_rounded, size: 56, color: AppColors.appBarColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu dönem için ders notu bulunmamaktadır.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return CourseInfoCard(
                  course: state.courses[index],
                  gpa: state.summary.gpa,
                );
              }, childCount: state.courses.length),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    AcademicSummaryModel summary, {
    String? username,
    String? studentNumber,
  }) {
    final hasUserData = username != null && studentNumber != null;
    if (summary.isEmpty && !hasUserData) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
if (hasUserData) ...[
                  Builder(builder: (context) {
final name = username as String;
                    return Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
                  }),
                  const SizedBox(height: 2),
                  Builder(builder: (context) {
final no = studentNumber as String;
                    return Text('Öğrenci No: $no', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary));
                  }),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (summary.gpa != null)
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'GNO: '),
                      TextSpan(text: '${summary.gpa}', style: const TextStyle(color: AppColors.appBarColor, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              FutureBuilder<int>(
                future: context.read<StorageService>().loadGraduationCredits(),
                builder: (ctx, snap) {
                  final grad = snap.data ?? 160;
                  final earned = summary.credits ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          children: [
                            const TextSpan(text: 'Kredi: '),
                            TextSpan(text: '$earned/$grad', style: const TextStyle(color: AppColors.appBarColor, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
