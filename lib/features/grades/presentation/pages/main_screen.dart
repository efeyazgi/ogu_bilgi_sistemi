import 'package:flutter/material.dart';
import 'grades_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../schedule/presentation/pages/schedule_page.dart';
import '../../../gpa/presentation/pages/gpa_page.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const GradesScreen(),
    const SchedulePage(),
    const GpaPage(),
    const AttendancePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'settings_fab',
        tooltip: 'Ayarlar',
        onPressed: _showDeveloperInfo,
        child: const Icon(Icons.settings),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.appBarColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(color: Colors.black),
        unselectedLabelStyle: const TextStyle(color: Colors.black),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Text('📘', style: TextStyle(fontSize: 22)),
            label: 'Notlar',
          ),
          BottomNavigationBarItem(
            icon: Text('📅', style: TextStyle(fontSize: 22)),
            label: 'Ders Programı',
          ),
          BottomNavigationBarItem(
            icon: Text('📊', style: TextStyle(fontSize: 22)),
            label: 'GPA',
          ),
          BottomNavigationBarItem(
            icon: Text('⏰', style: TextStyle(fontSize: 22)),
            label: 'Devamsızlık',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _showDeveloperInfo() {
    final controller = TextEditingController();
    bool initialized = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 16,
          ),
          child: FutureBuilder<int>(
            future: context.read<StorageService>().loadGraduationCredits(),
            builder: (ctx2, snap) {
              if (!initialized && snap.hasData) {
                controller.text = (snap.data ?? 160).toString();
                initialized = true;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Geliştirici', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 8),
                  const Text('Efe YAZGI', style: TextStyle(fontSize: 16, color: Colors.green)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Mezuniyet Kredisi',
                            hintText: 'Örn: 160',
                          ),
                          onSubmitted: (v) async {
                            final n = int.tryParse(v.trim());
                            if (n != null && n > 0) {
                              await context.read<StorageService>().saveGraduationCredits(n);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mezuniyet kredisi kaydedildi')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(110, 56),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final n = int.tryParse(controller.text.trim());
                            if (n != null && n > 0) {
                              await context.read<StorageService>().saveGraduationCredits(n);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mezuniyet kredisi kaydedildi')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Kaydet'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => _launchUrl('https://www.linkedin.com/in/efeyazgi'),
                        icon: const Icon(Icons.link),
                        label: const Text('LinkedIn'),
                      ),
                      TextButton.icon(
                        onPressed: () => _launchUrl('https://github.com/efeyazgi'),
                        icon: const Icon(Icons.code),
                        label: const Text('GitHub'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Önce external application olarak dene
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
          ),
        );
      } else {
        // Eğer external application çalışmazsa platform default dene
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link açılamıyor: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
