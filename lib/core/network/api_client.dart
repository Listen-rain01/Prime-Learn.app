import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:primelearn/core/network/api_config.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/session/session_detector.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

/// 统一 HTTP 客户端。
///
/// 全流程复用同一 Cookie 容器（`ASP.NET_SessionId`），
/// 并把 Dio 异常映射为 [ApiException]，UI 不再接触原始异常。
class ApiClient {
  /// 创建客户端，可注入 Dio / CookieJar 便于测试。
  ApiClient({Dio? dio, CookieJar? cookieJar})
    : _cookieJar = cookieJar ?? CookieJar(),
      _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {'X-Requested-With': 'XMLHttpRequest'},
      responseType: ResponseType.plain,
    );
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.interceptors.add(
      InterceptorsWrapper(onResponse: _inspectSession, onError: _mapError),
    );
  }

  final Dio _dio;
  final CookieJar _cookieJar;

  /// 预建会话：获取验证码图片，目的只是让服务端下发 Cookie。
  Future<void> getValidateCode() async {
    try {
      await _dio.get<List<int>>(
        '/Home/GetValidateCode',
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  /// 提交表单；返回原始响应体。
  Future<String> postForm(String path, Map<String, String> data) async {
    try {
      final response = await _dio.post<String>(
        path,
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return response.data ?? '';
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  /// 清空 Cookie（退出登录或会话失效时调用）。
  Future<void> clearCookies() => _cookieJar.deleteAll();

  void _inspectSession(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final contentType = response.headers.value(Headers.contentTypeHeader);
    final body = response.data is String ? response.data as String : null;
    if (!SessionDetector.looksLikeLoginPage(contentType, body)) {
      handler.next(response);
      return;
    }
    handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: ApiException(
          kind: ApiErrorKind.sessionExpired,
          message: '会话已失效，请重新登录',
          endpoint: response.requestOptions.path,
          statusCode: response.statusCode,
        ),
      ),
    );
  }

  void _mapError(DioException error, ErrorInterceptorHandler handler) {
    final mapped = _toApiException(error);
    handler.reject(
      DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: mapped,
      ),
    );
  }

  ApiException _toApiException(DioException error) {
    final existing = error.error;
    if (existing is ApiException) return existing;
    final endpoint = error.requestOptions.path;
    final status = error.response?.statusCode;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          kind: ApiErrorKind.timeout,
          message: '网络超时，请检查网络后重试',
          endpoint: endpoint,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          kind: ApiErrorKind.network,
          message: '无法连接服务器，请检查网络',
          endpoint: endpoint,
        );
      case DioExceptionType.badResponse:
        if (status == 401 || status == 302) {
          return ApiException(
            kind: ApiErrorKind.sessionExpired,
            message: '会话已失效，请重新登录',
            endpoint: endpoint,
            statusCode: status,
          );
        }
        return ApiException(
          kind: ApiErrorKind.server,
          message: '服务异常（HTTP $status），请稍后重试',
          endpoint: endpoint,
          statusCode: status,
        );
      case DioExceptionType.cancel:
        return ApiException(
          kind: ApiErrorKind.cancelled,
          message: '请求已取消',
          endpoint: endpoint,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          kind: ApiErrorKind.network,
          message: '安全连接校验失败',
          endpoint: endpoint,
        );
      case DioExceptionType.unknown:
        return ApiException(
          kind: ApiErrorKind.unknown,
          message: '请求失败，请稍后重试',
          endpoint: endpoint,
        );
    }
  }
}

/// 全局单例客户端，保证 Cookie 容器唯一。
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient();
