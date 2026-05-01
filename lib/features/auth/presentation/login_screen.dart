import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app_routes.dart';
import '../../../core/config/auth_config.dart';
import '../data/auth_service.dart';

enum _AuthMode { signIn, createAccount }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreateAccount = _mode == _AuthMode.createAccount;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 48),
            const _AppMark(),
            const SizedBox(height: 28),
            Text(
              isCreateAccount ? 'Create your account' : 'Welcome back',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              isCreateAccount
                  ? 'Start with email/password or continue with Google. We will create your AI productivity profile next.'
                  : 'Log in to automate your goals, alarms, task check-ins, and productivity reports.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF627270)),
            ),
            const SizedBox(height: 24),
            SegmentedButton<_AuthMode>(
              segments: const [
                ButtonSegment(value: _AuthMode.signIn, label: Text('Login')),
                ButtonSegment(
                  value: _AuthMode.createAccount,
                  label: Text('Create'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _mode = value.first;
                        _message = null;
                      });
                    },
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _emailController,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              autofillHints: const [AutofillHints.password],
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitEmailPassword(),
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'At least 6 characters',
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitEmailPassword,
              child: _ButtonChild(
                isLoading: _isLoading,
                label: isCreateAccount ? 'Create account' : 'Login',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 30),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _mode = isCreateAccount
                            ? _AuthMode.signIn
                            : _AuthMode.createAccount;
                        _message = null;
                      });
                    },
              child: Text(
                isCreateAccount
                    ? 'Already have an account? Login'
                    : 'First time here? Create an account',
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              _AuthMessage(message: _message!),
            ],
            if (!AuthConfig.hasSupabaseConfig) ...[
              const SizedBox(height: 16),
              const _SetupNotice(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitEmailPassword() async {
    await _runAuthAction(() async {
      if (_mode == _AuthMode.createAccount) {
        final session = await _authService.createAccount(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (session != null) {
          _openOnboarding();
        } else if (mounted) {
          setState(() {
            _message =
                'Account created. If email confirmation is enabled, verify your email before logging in.';
          });
        }
      } else {
        await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        _openDashboard();
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    await _runAuthAction(() async {
      await _authService.signInWithGoogle();
      _openOnboarding();
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await action();
    } on AuthException catch (error) {
      _setMessage(error.message);
    } on AuthSetupException catch (error) {
      _setMessage(error.message);
    } on GoogleSignInException catch (error) {
      _setMessage(error.description ?? error.code.toString());
    } catch (error) {
      _setMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setMessage(String message) {
    if (!mounted) return;
    setState(() => _message = message);
  }

  void _openOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  void _openDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }
}

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({required this.isLoading, required this.label});

  final bool isLoading;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return Text(label);
    }

    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _AuthMessage extends StatelessWidget {
  const _AuthMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2D3A2)),
      ),
      child: Text(message, style: const TextStyle(height: 1.35)),
    );
  }
}

class _SetupNotice extends StatelessWidget {
  const _SetupNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Auth setup needed: add SUPABASE_URL, SUPABASE_ANON_KEY, and GOOGLE_WEB_CLIENT_ID to .env.',
        style: TextStyle(height: 1.35),
      ),
    );
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF0E7C78), Color(0xFF2F80ED)],
          ),
        ),
        child: const Center(
          child: Text(
            'AI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
