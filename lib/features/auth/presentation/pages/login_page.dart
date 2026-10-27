import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/router.dart';
import 'package:primelearn/core/session/account_memory.dart';
import 'package:primelearn/core/utils/id_card_validator.dart';
import 'package:primelearn/core/widgets/app_text_field.dart';
import 'package:primelearn/core/widgets/inline_notice.dart';
import 'package:primelearn/core/widgets/primary_button.dart';
import 'package:primelearn/features/auth/presentation/providers/login_notifier.dart';
import 'package:primelearn/features/auth/presentation/providers/login_state.dart';

/// 登录页。
///
/// 错误提示采用「就近内联」：字段错误显示在对应输入框下方，
/// 提交失败显示在按钮上方，不使用底部 SnackBar。
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
  String? _idCardError;
  String? _passwordError;

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
    final idCard = _idCardController.text.trim();
    final idCardError = IdCardValidator.isValid(idCard)
        ? null
        : '请输入有效的 18 位身份证号';
    final passwordError = _passwordController.text.isEmpty ? '请输入登录密码' : null;

    setState(() {
      _idCardError = idCardError;
      _passwordError = passwordError;
    });
    if (idCardError != null || passwordError != null) return;

    await ref
        .read(loginProvider.notifier)
        .submit(
          idCard: idCard,
          password: _passwordController.text,
          remember: _rememberAccount,
        );
  }

  void _clearFailureOnEdit() {
    if (ref.read(loginProvider) is LoginFailed) {
      ref.read(loginProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(loginProvider);
    final submitting = state is LoginSubmitting;
    final failure = state is LoginFailed ? state : null;

    ref.listen<LoginState>(loginProvider, (_, next) {
      if (next is LoginSucceeded) {
        const TodayRoute().go(context);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // 键盘弹出时允许滚动，拖动时收起键盘。
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: FlutterLogo(
                            size: 100,
                            style: FlutterLogoStyle.markOnly,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Prime Learn',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '欢迎回来，请登录你的账号',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 44),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _idCardController,
                          builder: (context, value, _) {
                            return AppTextField(
                              controller: _idCardController,
                              labelText: '身份证号',
                              hintText: '请输入 18 位身份证号',
                              icon: Icons.badge,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              maxLength: 18,
                              enabled: !submitting,
                              errorText: _idCardError,
                              suffix: value.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: '清空身份证号',
                                      icon: const Icon(Icons.clear, size: 18),
                                      color: scheme.onSurfaceVariant,
                                      onPressed: () {
                                        _idCardController.clear();
                                        setState(() => _idCardError = null);
                                      },
                                    ),
                              onChanged: (_) {
                                if (_idCardError != null) {
                                  setState(() => _idCardError = null);
                                }
                                _clearFailureOnEdit();
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          controller: _passwordController,
                          labelText: '密码',
                          hintText: '请输入登录密码',
                          icon: Icons.lock,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          enabled: !submitting,
                          errorText: _passwordError,
                          onSubmitted: (_) => unawaited(_submit()),
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                            _clearFailureOnEdit();
                          },
                          suffix: IconButton(
                            tooltip: _obscurePassword ? '显示密码' : '隐藏密码',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            color: scheme.onSurfaceVariant,
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: submitting
                                ? null
                                : () => setState(
                                    () => _rememberAccount = !_rememberAccount,
                                  ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberAccount,
                                      onChanged: submitting
                                          ? null
                                          : (value) => setState(
                                              () => _rememberAccount =
                                                  value ?? false,
                                            ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: BorderSide(
                                        color: scheme.outline,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '记住账号',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (failure != null) ...[
                          InlineNotice(message: failure.message),
                          const SizedBox(height: 12),
                        ],
                        PrimaryButton(
                          label: '登 录',
                          loading: submitting,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 36),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '安全登录 · 仅限授权账号',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '© 2026 Prime Learn · 保留所有权利',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
