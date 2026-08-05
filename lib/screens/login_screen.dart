import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../core/tokens.dart';
import '../data/menu_data.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'root_shell.dart';
import 'splash_screen.dart';

final RegExp _emailPattern = RegExp(
  r'^[\w.+-]+@[\w-]+\.[\w.-]{2,}$',
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscure = true;
  bool _submitting = false;
  bool _createAccount = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!_emailPattern.hasMatch(email)) {
      return 'That does not look like an email. Try name@example.com';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter your password.';
    if (password.length < 6) {
      return 'Use at least 6 characters — yours has ${password.length}.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      return 'Mix letters and numbers so it is harder to guess.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);

    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      if (_validateEmail(_emailController.text) != null) {
        _emailFocus.requestFocus();
      } else {
        _passwordFocus.requestFocus();
      }
      return;
    }

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    AppScope.read(context).signIn(_emailController.text.trim());
    HapticFeedback.mediumImpact();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  void _continueAsGuest() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Gap.xl,
              Gap.xl,
              Gap.xl,
              Gap.xl + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FadeSlideIn(child: BrandMark(size: 72)),
                      Gap.h24,
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        child: Text(
                          _createAccount
                              ? 'Create your\n${MenuData.restaurantName} account'
                              : 'Welcome back to\n${MenuData.restaurantName}',
                          style: context.text.displaySmall,
                        ),
                      ),
                      Gap.h8,
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          _createAccount
                              ? 'A few details and the kitchen is yours.'
                              : 'Sign in to reorder your usual in two taps.',
                          style: context.text.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Gap.h32,
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 140),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autovalidate,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                enabled: !_submitting,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                autocorrect: false,
                                validator: _validateEmail,
                                onFieldSubmitted: (_) =>
                                    _passwordFocus.requestFocus(),
                                decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  hintText: 'name@example.com',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              Gap.h20,
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                enabled: !_submitting,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                autofillHints: [
                                  _createAccount
                                      ? AutofillHints.newPassword
                                      : AutofillHints.password,
                                ],
                                validator: _validatePassword,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  helperText:
                                      'At least 6 characters, with a number.',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    tooltip: _obscure
                                        ? 'Show password'
                                        : 'Hide password',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!_createAccount) ...[
                        Gap.h8,
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _submitting
                                ? null
                                : () => showAppSnack('A reset link is on its way to your inbox.',
                                      icon: Icons.mark_email_read_rounded,
                                    ),
                            child: const Text('Forgot password?'),
                          ),
                        ),
                      ],
                      Gap.h24,
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 180),
                        child: AppButton(
                          label: _createAccount ? 'Create account' : 'Sign in',
                          icon: Icons.arrow_forward_rounded,
                          loading: _submitting,
                          onPressed: _submit,
                        ),
                      ),
                      Gap.h16,
                      OutlinedButton.icon(
                        onPressed: _submitting ? null : _continueAsGuest,
                        icon: const Icon(Icons.explore_outlined),
                        label: const Text('Browse the menu as a guest'),
                      ),
                      Gap.h32,
                      Row(
                        children: [
                          Expanded(child: HairLine()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Gap.sm,
                            ),
                            child: Text(
                              'or continue with',
                              style: context.text.labelMedium,
                            ),
                          ),
                          Expanded(child: HairLine()),
                        ],
                      ),
                      Gap.h20,
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.apple_rounded,
                              label: 'Apple',
                              enabled: !_submitting,
                            ),
                          ),
                          Gap.w12,
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              label: 'Google',
                              enabled: !_submitting,
                            ),
                          ),
                        ],
                      ),
                      Gap.h32,
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            _createAccount
                                ? 'Already ordering with us?'
                                : 'New to Savora?',
                            style: context.text.bodyMedium,
                          ),
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () => setState(() {
                                      _createAccount = !_createAccount;
                                      _autovalidate =
                                          AutovalidateMode.disabled;
                                      _formKey.currentState?.reset();
                                    }),
                            child: Text(
                              _createAccount ? 'Sign in' : 'Create an account',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled
          ? () => showAppSnack('$label sign-in is not wired up in this build.',
                icon: Icons.info_outline_rounded,
              )
          : null,
      icon: Icon(icon, size: IconSize.lg),
      label: Text(label),
    );
  }
}
