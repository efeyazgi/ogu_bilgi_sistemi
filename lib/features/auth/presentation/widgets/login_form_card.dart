import 'package:flutter/material.dart';

class LoginFormCard extends StatefulWidget {
  final TextEditingController studentNumberController;
  final TextEditingController passwordController;
  final bool initialRememberMe;
  final ValueChanged<bool> onRememberMeChanged;

  const LoginFormCard({
    super.key,
    required this.studentNumberController,
    required this.passwordController,
    required this.initialRememberMe,
    required this.onRememberMeChanged,
  });

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  late bool _rememberMe;
  bool _obscurePassword = true; // Şifre görünürlüğü kontrolü

  @override
  void initState() {
    super.initState();
    _rememberMe = widget.initialRememberMe;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // CardTheme'den stil alacak
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Giriş Bilgileri',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 5),
            Text(
              'Öğrenci numaranız ve şifrenizle giriş yapın',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Öğrenci No',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.studentNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Öğrenci numaranızı girin',
              ),
            ),
            const SizedBox(height: 15),
            Text('Şifre', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            TextField(
              controller: widget.passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Şifrenizi girin',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                    widget.onRememberMeChanged(_rememberMe);
                  },
                ),
                const Text('Beni Hatırla'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
