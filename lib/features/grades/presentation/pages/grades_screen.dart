import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogu_not_sistemi/core/theme/app_colors.dart';
import 'package:ogu_not_sistemi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ogu_not_sistemi/features/grades/presentation/bloc/grades_bloc.dart';
import 'package:ogu_not_sistemi/features/grades/presentation/widgets/course_info_card.dart';
import 'package:ogu_not_sistemi/features/auth/presentation/pages/login_screen.dart';
import 'package:ogu_not_sistemi/features/grades/data/models/academic_summary_model.dart';
import 'package:ogu_not_sistemi/features/grades/data/models/grades_page_data.dart';

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
    final authState = context.watch<AuthBloc>().state;
    String studentName = '...';
    String studentNumber = '...';
    if (authState is AuthLoginSuccess) {
      studentName = authState.username;
      studentNumber = authState.studentNumber;
    }

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
          const SliverFillRemaining(
            child: Center(
              child: Text('Bu dönem için ders notu bulunmamaktadır.'),
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
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.notesHeaderBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasUserData) ...[
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  const TextSpan(
                    text: 'Öğrenci Adı: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: username),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  const TextSpan(
                    text: 'Öğrenci Numarası: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: studentNumber),
                ],
              ),
            ),
            if (summary.isNotEmpty) const Divider(height: 24),
          ],
          if (summary.gpa != null)
            Text(
              "GNO: ${summary.gpa}",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          if (summary.gpa != null && summary.credits != null)
            const SizedBox(height: 5),
          if (summary.credits != null)
            Text(
              "Başarılan Kredi: ${summary.credits}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
        ],
      ),
    );
  }
}
