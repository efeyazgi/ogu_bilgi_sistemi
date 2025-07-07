import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _studentNumberKey = 'student_number';
  static const String _passwordKey =
      'password'; // Dikkat: Şifreleri düz metin olarak saklamak güvenlik açığıdır.
  // Gerçek bir uygulamada flutter_secure_storage gibi bir paket kullanılmalıdır.

  Future<void> saveCredentials(String studentNumber, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentNumberKey, studentNumber);
    await prefs.setString(_passwordKey, password);
    print('Credentials saved.');
  }

  Future<Map<String, String>?> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNumber = prefs.getString(_studentNumberKey);
    final password = prefs.getString(_passwordKey);

    if (studentNumber != null && password != null) {
      print('Credentials loaded: $studentNumber');
      return {'studentNumber': studentNumber, 'password': password};
    }
    print('No credentials found.');
    return null;
  }

  Future<void> deleteCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studentNumberKey);
    await prefs.remove(_passwordKey);
    print('Credentials deleted.');
  }
}
