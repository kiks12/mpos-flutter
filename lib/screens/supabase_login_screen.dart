
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLoginScreen extends StatefulWidget {
  const SupabaseLoginScreen({Key? key}) : super(key: key);

  @override
  State<SupabaseLoginScreen> createState() => _SupabaseLoginScreenState();
}

class _SupabaseLoginScreenState extends State<SupabaseLoginScreen> {
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> setPreferencesValues(AuthResponse res) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', res.user!.id);
    await prefs.setString('access_token', res.session!.accessToken);
    await prefs.setString('access_token_expiry', res.session!.expiresAt.toString());
    await prefs.setString('refresh_token', res.session!.refreshToken.toString());
  }

  Future<void> signInWithEmail(BuildContext context) async {
    final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
      email: emailController.text,
      password: passwordController.text
    );

    if (res.user != null && res.session != null) {
      await setPreferencesValues(res);

      Future.delayed(Duration.zero, () {
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login successful')),
            );
        }
      });

      setState(() {
        _isLoading = true;
      });

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_isLoading) ? 
        Center(
          child: CircularProgressIndicator(),
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Supabase Login'),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => signInWithEmail(context),
              child: Text('Login'),
            ),
          ],
        ),
    );
  }
}