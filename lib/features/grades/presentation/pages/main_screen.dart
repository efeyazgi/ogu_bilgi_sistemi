import 'package:flutter/material.dart';
import 'grades_screen.dart';
import '../../../schedule/presentation/pages/schedule_page.dart';
import '../../../gpa/presentation/pages/gpa_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Clipboard için

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
        tooltip: 'Geliştirici',
        onPressed: _showDeveloperInfo,
        child: const Icon(Icons.info_outline),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Text('🏫', style: TextStyle(fontSize: 22)),
            label: 'Notlar',
          ),
          BottomNavigationBarItem(
            icon: Text('📅', style: TextStyle(fontSize: 22)),
            label: 'Ders Programı',
          ),
          BottomNavigationBarItem(
            icon: Text('🧮', style: TextStyle(fontSize: 22)),
            label: 'GPA',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _showDeveloperInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Geliştirici', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Efe YAZGI', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
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
