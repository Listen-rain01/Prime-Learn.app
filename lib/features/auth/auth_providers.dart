import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/features/auth/application/login_usecase.dart';
import 'package:primelearn/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:primelearn/features/auth/data/services/auth_api.dart';
import 'package:primelearn/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// 认证 API 实例。
@Riverpod(keepAlive: true)
AuthApi authApi(Ref ref) => AuthApi(ref.watch(apiClientProvider));

/// 认证仓储实例（依赖倒置：用例只看到接口）。
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(authApiProvider));

/// 登录用例实例。
@Riverpod(keepAlive: true)
LoginUseCase loginUseCase(Ref ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));
