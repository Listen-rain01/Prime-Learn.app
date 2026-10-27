import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/router.dart';
import 'package:primelearn/app/theme.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/auth/presentation/providers/login_controller.dart';
import 'package:primelearn/features/auth/presentation/providers/login_state.dart';
import 'package:primelearn/features/auth/presentation/widgets/brand_logo.dart';
import 'package:primelearn/features/auth/presentation/widgets/login_text_field.dart';
import 'package:primelearn/features/auth/presentation/widgets/primary_button.dart';

/// 登录页：身份证号 + 密码，对齐 docs/01-login.png。
class LoginPage extends ConsumerStatefulWidget {
  /// 创建登录页。
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberAccount = false;

  @override
  void initState() {
    super.initState();
    unawaited(_prefillRememberedAccount());
  }

  @override
  void dispose() {
    _idCardController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prefillRememberedAccount() async {
    final saved = await ref.read(accountMemoryProvider).read();
    if (!mounted || saved == null || saved.isEmpty) return;
    setState(() {
      _idCardController.text = saved;
      _rememberAccount = true;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(loginControllerProvider.notifier)
        .submit(
          idCard: _idCardController.text,
          password: _passwordController.text,
          remember: _rememberAccount,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final submitting = state is LoginSubmitting;
    final failure = state is LoginFailed ? state : null;

    ref.listen<LoginState>(loginControllerProvider, (_, next) {
      if (next is LoginSucceeded) {
        const HomeRoute().go(context);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    const Center(child: BrandLogo()),
                    const SizedBox(height: 24),
                    const Text(
                      'Prime Learn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '欢迎回来，请登录你的账号',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 52),
                    LoginTextField(
                      controller: _idCardController,
                      hintText: '身份证号',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onChanged: _onEdited,
                    ),
                    const SizedBox(height: 16),
                    LoginTextField(
                      controller: _passwordController,
                      hintText: '密码',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: _onEdited,
                      onSubmitted: (_) => unawaited(_submit()),
                      suffix: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: _obscurePassword ? '显示密码' : '隐藏密码',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberAccount,
                            onChanged: submitting
                                ? null
                                : (value) => setState(
                                    () => _rememberAccount = value ?? false,
                                  ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(
                              color: AppColors.textSecondary,
                              width: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '记住账号',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (failure != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              failure.message,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    PrimaryButton(
                      label: '登 录',
                      loading: submitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 44),
                    const _SecurityFooter(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onEdited(String _) {
    if (ref.read(loginControllerProvider) is LoginFailed) {
      ref.read(loginControllerProvider.notifier).reset();
    }
  }
}

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 15,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 6),
            Text(
              '安全登录 · 仅限授权账号',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '© 2026 Prime Learn · 保留所有权利',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
