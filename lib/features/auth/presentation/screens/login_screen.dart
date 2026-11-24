import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/features/auth/presentation/providers/auth_providers.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    try {
      final repo = ref.read(authRepositoryProvider);
      if (_isSignUp) {
        await repo.signUpWithEmail(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        await repo.signInWithEmail(_emailCtrl.text.trim(), _passwordCtrl.text);
      }
      if (mounted) context.pop();
    } on FirebaseAuthException catch (e) {
      ref.read(authErrorProvider.notifier).state = e.message;
    } finally {
      if (mounted) ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _googleSignIn() async {
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) context.pop();
    } on Exception catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      if (mounted) ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? l10n.createAccount : l10n.signIn)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                // ─── Hero Visual ───────────────────────────
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.clayShadowLight(blur: 24, offset: 8),
                    ),
                    child: Text(
                      '漢',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _isSignUp ? l10n.createAccount : l10n.welcomeBack,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp ? l10n.createAccountSubtitle : l10n.signInSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(error, style: TextStyle(color: theme.colorScheme.error)),
                  ),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.requiredField;
                    if (!v.contains('@')) return l10n.invalidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return l10n.passwordTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isSignUp ? l10n.createAccount : l10n.signIn),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: loading ? null : _googleSignIn,
                  icon: const Icon(Icons.g_mobiledata_rounded),
                  label: Text(l10n.signInWithGoogle),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp ? l10n.alreadyHaveAccount : l10n.noAccountYet),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
