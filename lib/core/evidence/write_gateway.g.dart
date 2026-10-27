// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'write_gateway.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 写网关实例。

@ProviderFor(writeGateway)
final writeGatewayProvider = WriteGatewayProvider._();

/// 写网关实例。

final class WriteGatewayProvider
    extends $FunctionalProvider<WriteGateway, WriteGateway, WriteGateway>
    with $Provider<WriteGateway> {
  /// 写网关实例。
  WriteGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writeGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writeGatewayHash();

  @$internal
  @override
  $ProviderElement<WriteGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WriteGateway create(Ref ref) {
    return writeGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WriteGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WriteGateway>(value),
    );
  }
}

String _$writeGatewayHash() => r'417d38360223815077795db92f87d260f3703324';
