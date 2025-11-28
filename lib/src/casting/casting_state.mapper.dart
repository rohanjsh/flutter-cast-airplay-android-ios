// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'casting_state.dart';

class CastingErrorMapper extends ClassMapperBase<CastingError> {
  CastingErrorMapper._();

  static CastingErrorMapper? _instance;
  static CastingErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CastingErrorMapper._());
      DiscoveryErrorMapper.ensureInitialized();
      ConnectionErrorMapper.ensureInitialized();
      MediaErrorMapper.ensureInitialized();
      DisposedErrorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CastingError';

  static String _$message(CastingError v) => v.message;
  static const Field<CastingError, String> _f$message = Field(
    'message',
    _$message,
  );
  static Object? _$cause(CastingError v) => v.cause;
  static const Field<CastingError, Object> _f$cause = Field(
    'cause',
    _$cause,
    opt: true,
  );

  @override
  final MappableFields<CastingError> fields = const {
    #message: _f$message,
    #cause: _f$cause,
  };

  static CastingError _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('CastingError');
  }

  @override
  final Function instantiate = _instantiate;

  static CastingError fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CastingError>(map);
  }

  static CastingError fromJson(String json) {
    return ensureInitialized().decodeJson<CastingError>(json);
  }
}

mixin CastingErrorMappable {
  String toJson();
  Map<String, dynamic> toMap();
  CastingErrorCopyWith<CastingError, CastingError, CastingError> get copyWith;
}

abstract class CastingErrorCopyWith<$R, $In extends CastingError, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  CastingErrorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class DiscoveryErrorMapper extends ClassMapperBase<DiscoveryError> {
  DiscoveryErrorMapper._();

  static DiscoveryErrorMapper? _instance;
  static DiscoveryErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscoveryErrorMapper._());
      CastingErrorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DiscoveryError';

  static String _$message(DiscoveryError v) => v.message;
  static const Field<DiscoveryError, String> _f$message = Field(
    'message',
    _$message,
  );
  static Object? _$cause(DiscoveryError v) => v.cause;
  static const Field<DiscoveryError, Object> _f$cause = Field(
    'cause',
    _$cause,
    opt: true,
  );

  @override
  final MappableFields<DiscoveryError> fields = const {
    #message: _f$message,
    #cause: _f$cause,
  };

  static DiscoveryError _instantiate(DecodingData data) {
    return DiscoveryError(data.dec(_f$message), data.dec(_f$cause));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscoveryError fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscoveryError>(map);
  }

  static DiscoveryError fromJson(String json) {
    return ensureInitialized().decodeJson<DiscoveryError>(json);
  }
}

mixin DiscoveryErrorMappable {
  String toJson() {
    return DiscoveryErrorMapper.ensureInitialized().encodeJson<DiscoveryError>(
      this as DiscoveryError,
    );
  }

  Map<String, dynamic> toMap() {
    return DiscoveryErrorMapper.ensureInitialized().encodeMap<DiscoveryError>(
      this as DiscoveryError,
    );
  }

  DiscoveryErrorCopyWith<DiscoveryError, DiscoveryError, DiscoveryError>
  get copyWith => _DiscoveryErrorCopyWithImpl<DiscoveryError, DiscoveryError>(
    this as DiscoveryError,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return DiscoveryErrorMapper.ensureInitialized().stringifyValue(
      this as DiscoveryError,
    );
  }

  @override
  bool operator ==(Object other) {
    return DiscoveryErrorMapper.ensureInitialized().equalsValue(
      this as DiscoveryError,
      other,
    );
  }

  @override
  int get hashCode {
    return DiscoveryErrorMapper.ensureInitialized().hashValue(
      this as DiscoveryError,
    );
  }
}

extension DiscoveryErrorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscoveryError, $Out> {
  DiscoveryErrorCopyWith<$R, DiscoveryError, $Out> get $asDiscoveryError =>
      $base.as((v, t, t2) => _DiscoveryErrorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscoveryErrorCopyWith<$R, $In extends DiscoveryError, $Out>
    implements CastingErrorCopyWith<$R, $In, $Out> {
  @override
  $R call({String? message, Object? cause});
  DiscoveryErrorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DiscoveryErrorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscoveryError, $Out>
    implements DiscoveryErrorCopyWith<$R, DiscoveryError, $Out> {
  _DiscoveryErrorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscoveryError> $mapper =
      DiscoveryErrorMapper.ensureInitialized();
  @override
  $R call({String? message, Object? cause = $none}) => $apply(
    FieldCopyWithData({
      if (message != null) #message: message,
      if (cause != $none) #cause: cause,
    }),
  );
  @override
  DiscoveryError $make(CopyWithData data) => DiscoveryError(
    data.get(#message, or: $value.message),
    data.get(#cause, or: $value.cause),
  );

  @override
  DiscoveryErrorCopyWith<$R2, DiscoveryError, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DiscoveryErrorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ConnectionErrorMapper extends ClassMapperBase<ConnectionError> {
  ConnectionErrorMapper._();

  static ConnectionErrorMapper? _instance;
  static ConnectionErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConnectionErrorMapper._());
      CastingErrorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ConnectionError';

  static String _$message(ConnectionError v) => v.message;
  static const Field<ConnectionError, String> _f$message = Field(
    'message',
    _$message,
  );
  static Object? _$cause(ConnectionError v) => v.cause;
  static const Field<ConnectionError, Object> _f$cause = Field(
    'cause',
    _$cause,
    opt: true,
  );

  @override
  final MappableFields<ConnectionError> fields = const {
    #message: _f$message,
    #cause: _f$cause,
  };

  static ConnectionError _instantiate(DecodingData data) {
    return ConnectionError(data.dec(_f$message), data.dec(_f$cause));
  }

  @override
  final Function instantiate = _instantiate;

  static ConnectionError fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ConnectionError>(map);
  }

  static ConnectionError fromJson(String json) {
    return ensureInitialized().decodeJson<ConnectionError>(json);
  }
}

mixin ConnectionErrorMappable {
  String toJson() {
    return ConnectionErrorMapper.ensureInitialized()
        .encodeJson<ConnectionError>(this as ConnectionError);
  }

  Map<String, dynamic> toMap() {
    return ConnectionErrorMapper.ensureInitialized().encodeMap<ConnectionError>(
      this as ConnectionError,
    );
  }

  ConnectionErrorCopyWith<ConnectionError, ConnectionError, ConnectionError>
  get copyWith =>
      _ConnectionErrorCopyWithImpl<ConnectionError, ConnectionError>(
        this as ConnectionError,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ConnectionErrorMapper.ensureInitialized().stringifyValue(
      this as ConnectionError,
    );
  }

  @override
  bool operator ==(Object other) {
    return ConnectionErrorMapper.ensureInitialized().equalsValue(
      this as ConnectionError,
      other,
    );
  }

  @override
  int get hashCode {
    return ConnectionErrorMapper.ensureInitialized().hashValue(
      this as ConnectionError,
    );
  }
}

extension ConnectionErrorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ConnectionError, $Out> {
  ConnectionErrorCopyWith<$R, ConnectionError, $Out> get $asConnectionError =>
      $base.as((v, t, t2) => _ConnectionErrorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ConnectionErrorCopyWith<$R, $In extends ConnectionError, $Out>
    implements CastingErrorCopyWith<$R, $In, $Out> {
  @override
  $R call({String? message, Object? cause});
  ConnectionErrorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ConnectionErrorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ConnectionError, $Out>
    implements ConnectionErrorCopyWith<$R, ConnectionError, $Out> {
  _ConnectionErrorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ConnectionError> $mapper =
      ConnectionErrorMapper.ensureInitialized();
  @override
  $R call({String? message, Object? cause = $none}) => $apply(
    FieldCopyWithData({
      if (message != null) #message: message,
      if (cause != $none) #cause: cause,
    }),
  );
  @override
  ConnectionError $make(CopyWithData data) => ConnectionError(
    data.get(#message, or: $value.message),
    data.get(#cause, or: $value.cause),
  );

  @override
  ConnectionErrorCopyWith<$R2, ConnectionError, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ConnectionErrorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MediaErrorMapper extends ClassMapperBase<MediaError> {
  MediaErrorMapper._();

  static MediaErrorMapper? _instance;
  static MediaErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MediaErrorMapper._());
      CastingErrorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MediaError';

  static String _$message(MediaError v) => v.message;
  static const Field<MediaError, String> _f$message = Field(
    'message',
    _$message,
  );
  static Object? _$cause(MediaError v) => v.cause;
  static const Field<MediaError, Object> _f$cause = Field(
    'cause',
    _$cause,
    opt: true,
  );

  @override
  final MappableFields<MediaError> fields = const {
    #message: _f$message,
    #cause: _f$cause,
  };

  static MediaError _instantiate(DecodingData data) {
    return MediaError(data.dec(_f$message), data.dec(_f$cause));
  }

  @override
  final Function instantiate = _instantiate;

  static MediaError fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MediaError>(map);
  }

  static MediaError fromJson(String json) {
    return ensureInitialized().decodeJson<MediaError>(json);
  }
}

mixin MediaErrorMappable {
  String toJson() {
    return MediaErrorMapper.ensureInitialized().encodeJson<MediaError>(
      this as MediaError,
    );
  }

  Map<String, dynamic> toMap() {
    return MediaErrorMapper.ensureInitialized().encodeMap<MediaError>(
      this as MediaError,
    );
  }

  MediaErrorCopyWith<MediaError, MediaError, MediaError> get copyWith =>
      _MediaErrorCopyWithImpl<MediaError, MediaError>(
        this as MediaError,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MediaErrorMapper.ensureInitialized().stringifyValue(
      this as MediaError,
    );
  }

  @override
  bool operator ==(Object other) {
    return MediaErrorMapper.ensureInitialized().equalsValue(
      this as MediaError,
      other,
    );
  }

  @override
  int get hashCode {
    return MediaErrorMapper.ensureInitialized().hashValue(this as MediaError);
  }
}

extension MediaErrorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MediaError, $Out> {
  MediaErrorCopyWith<$R, MediaError, $Out> get $asMediaError =>
      $base.as((v, t, t2) => _MediaErrorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MediaErrorCopyWith<$R, $In extends MediaError, $Out>
    implements CastingErrorCopyWith<$R, $In, $Out> {
  @override
  $R call({String? message, Object? cause});
  MediaErrorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MediaErrorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MediaError, $Out>
    implements MediaErrorCopyWith<$R, MediaError, $Out> {
  _MediaErrorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MediaError> $mapper =
      MediaErrorMapper.ensureInitialized();
  @override
  $R call({String? message, Object? cause = $none}) => $apply(
    FieldCopyWithData({
      if (message != null) #message: message,
      if (cause != $none) #cause: cause,
    }),
  );
  @override
  MediaError $make(CopyWithData data) => MediaError(
    data.get(#message, or: $value.message),
    data.get(#cause, or: $value.cause),
  );

  @override
  MediaErrorCopyWith<$R2, MediaError, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MediaErrorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DisposedErrorMapper extends ClassMapperBase<DisposedError> {
  DisposedErrorMapper._();

  static DisposedErrorMapper? _instance;
  static DisposedErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DisposedErrorMapper._());
      CastingErrorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DisposedError';

  static String _$message(DisposedError v) => v.message;
  static const Field<DisposedError, String> _f$message = Field(
    'message',
    _$message,
    mode: FieldMode.member,
  );
  static Object? _$cause(DisposedError v) => v.cause;
  static const Field<DisposedError, Object> _f$cause = Field(
    'cause',
    _$cause,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<DisposedError> fields = const {
    #message: _f$message,
    #cause: _f$cause,
  };

  static DisposedError _instantiate(DecodingData data) {
    return DisposedError();
  }

  @override
  final Function instantiate = _instantiate;

  static DisposedError fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DisposedError>(map);
  }

  static DisposedError fromJson(String json) {
    return ensureInitialized().decodeJson<DisposedError>(json);
  }
}

mixin DisposedErrorMappable {
  String toJson() {
    return DisposedErrorMapper.ensureInitialized().encodeJson<DisposedError>(
      this as DisposedError,
    );
  }

  Map<String, dynamic> toMap() {
    return DisposedErrorMapper.ensureInitialized().encodeMap<DisposedError>(
      this as DisposedError,
    );
  }

  DisposedErrorCopyWith<DisposedError, DisposedError, DisposedError>
  get copyWith => _DisposedErrorCopyWithImpl<DisposedError, DisposedError>(
    this as DisposedError,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return DisposedErrorMapper.ensureInitialized().stringifyValue(
      this as DisposedError,
    );
  }

  @override
  bool operator ==(Object other) {
    return DisposedErrorMapper.ensureInitialized().equalsValue(
      this as DisposedError,
      other,
    );
  }

  @override
  int get hashCode {
    return DisposedErrorMapper.ensureInitialized().hashValue(
      this as DisposedError,
    );
  }
}

extension DisposedErrorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DisposedError, $Out> {
  DisposedErrorCopyWith<$R, DisposedError, $Out> get $asDisposedError =>
      $base.as((v, t, t2) => _DisposedErrorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DisposedErrorCopyWith<$R, $In extends DisposedError, $Out>
    implements CastingErrorCopyWith<$R, $In, $Out> {
  @override
  $R call();
  DisposedErrorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DisposedErrorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DisposedError, $Out>
    implements DisposedErrorCopyWith<$R, DisposedError, $Out> {
  _DisposedErrorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DisposedError> $mapper =
      DisposedErrorMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  DisposedError $make(CopyWithData data) => DisposedError();

  @override
  DisposedErrorCopyWith<$R2, DisposedError, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DisposedErrorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class UnifiedCastingStateMapper extends ClassMapperBase<UnifiedCastingState> {
  UnifiedCastingStateMapper._();

  static UnifiedCastingStateMapper? _instance;
  static UnifiedCastingStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UnifiedCastingStateMapper._());
      CastingDisconnectedMapper.ensureInitialized();
      CastingConnectingMapper.ensureInitialized();
      CastingConnectedMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UnifiedCastingState';

  static List<CastDevice> _$devices(UnifiedCastingState v) => v.devices;
  static const Field<UnifiedCastingState, List<CastDevice>> _f$devices = Field(
    'devices',
    _$devices,
  );

  @override
  final MappableFields<UnifiedCastingState> fields = const {
    #devices: _f$devices,
  };

  static UnifiedCastingState _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('UnifiedCastingState');
  }

  @override
  final Function instantiate = _instantiate;

  static UnifiedCastingState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UnifiedCastingState>(map);
  }

  static UnifiedCastingState fromJson(String json) {
    return ensureInitialized().decodeJson<UnifiedCastingState>(json);
  }
}

mixin UnifiedCastingStateMappable {
  String toJson();
  Map<String, dynamic> toMap();
  UnifiedCastingStateCopyWith<
    UnifiedCastingState,
    UnifiedCastingState,
    UnifiedCastingState
  >
  get copyWith;
}

abstract class UnifiedCastingStateCopyWith<
  $R,
  $In extends UnifiedCastingState,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>?>
  get devices;
  $R call({List<CastDevice>? devices});
  UnifiedCastingStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class CastingDisconnectedMapper extends ClassMapperBase<CastingDisconnected> {
  CastingDisconnectedMapper._();

  static CastingDisconnectedMapper? _instance;
  static CastingDisconnectedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CastingDisconnectedMapper._());
      UnifiedCastingStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CastingDisconnected';

  static List<CastDevice> _$devices(CastingDisconnected v) => v.devices;
  static const Field<CastingDisconnected, List<CastDevice>> _f$devices = Field(
    'devices',
    _$devices,
  );

  @override
  final MappableFields<CastingDisconnected> fields = const {
    #devices: _f$devices,
  };

  static CastingDisconnected _instantiate(DecodingData data) {
    return CastingDisconnected(devices: data.dec(_f$devices));
  }

  @override
  final Function instantiate = _instantiate;

  static CastingDisconnected fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CastingDisconnected>(map);
  }

  static CastingDisconnected fromJson(String json) {
    return ensureInitialized().decodeJson<CastingDisconnected>(json);
  }
}

mixin CastingDisconnectedMappable {
  String toJson() {
    return CastingDisconnectedMapper.ensureInitialized()
        .encodeJson<CastingDisconnected>(this as CastingDisconnected);
  }

  Map<String, dynamic> toMap() {
    return CastingDisconnectedMapper.ensureInitialized()
        .encodeMap<CastingDisconnected>(this as CastingDisconnected);
  }

  CastingDisconnectedCopyWith<
    CastingDisconnected,
    CastingDisconnected,
    CastingDisconnected
  >
  get copyWith =>
      _CastingDisconnectedCopyWithImpl<
        CastingDisconnected,
        CastingDisconnected
      >(this as CastingDisconnected, $identity, $identity);
  @override
  String toString() {
    return CastingDisconnectedMapper.ensureInitialized().stringifyValue(
      this as CastingDisconnected,
    );
  }

  @override
  bool operator ==(Object other) {
    return CastingDisconnectedMapper.ensureInitialized().equalsValue(
      this as CastingDisconnected,
      other,
    );
  }

  @override
  int get hashCode {
    return CastingDisconnectedMapper.ensureInitialized().hashValue(
      this as CastingDisconnected,
    );
  }
}

extension CastingDisconnectedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CastingDisconnected, $Out> {
  CastingDisconnectedCopyWith<$R, CastingDisconnected, $Out>
  get $asCastingDisconnected => $base.as(
    (v, t, t2) => _CastingDisconnectedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CastingDisconnectedCopyWith<
  $R,
  $In extends CastingDisconnected,
  $Out
>
    implements UnifiedCastingStateCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>>
  get devices;
  @override
  $R call({List<CastDevice>? devices});
  CastingDisconnectedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CastingDisconnectedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CastingDisconnected, $Out>
    implements CastingDisconnectedCopyWith<$R, CastingDisconnected, $Out> {
  _CastingDisconnectedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CastingDisconnected> $mapper =
      CastingDisconnectedMapper.ensureInitialized();
  @override
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>>
  get devices => ListCopyWith(
    $value.devices,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(devices: v),
  );
  @override
  $R call({List<CastDevice>? devices}) =>
      $apply(FieldCopyWithData({if (devices != null) #devices: devices}));
  @override
  CastingDisconnected $make(CopyWithData data) =>
      CastingDisconnected(devices: data.get(#devices, or: $value.devices));

  @override
  CastingDisconnectedCopyWith<$R2, CastingDisconnected, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CastingDisconnectedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CastingConnectingMapper extends ClassMapperBase<CastingConnecting> {
  CastingConnectingMapper._();

  static CastingConnectingMapper? _instance;
  static CastingConnectingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CastingConnectingMapper._());
      UnifiedCastingStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CastingConnecting';

  static List<CastDevice> _$devices(CastingConnecting v) => v.devices;
  static const Field<CastingConnecting, List<CastDevice>> _f$devices = Field(
    'devices',
    _$devices,
  );
  static CastDevice _$device(CastingConnecting v) => v.device;
  static const Field<CastingConnecting, CastDevice> _f$device = Field(
    'device',
    _$device,
  );

  @override
  final MappableFields<CastingConnecting> fields = const {
    #devices: _f$devices,
    #device: _f$device,
  };

  static CastingConnecting _instantiate(DecodingData data) {
    return CastingConnecting(
      devices: data.dec(_f$devices),
      device: data.dec(_f$device),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CastingConnecting fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CastingConnecting>(map);
  }

  static CastingConnecting fromJson(String json) {
    return ensureInitialized().decodeJson<CastingConnecting>(json);
  }
}

mixin CastingConnectingMappable {
  String toJson() {
    return CastingConnectingMapper.ensureInitialized()
        .encodeJson<CastingConnecting>(this as CastingConnecting);
  }

  Map<String, dynamic> toMap() {
    return CastingConnectingMapper.ensureInitialized()
        .encodeMap<CastingConnecting>(this as CastingConnecting);
  }

  CastingConnectingCopyWith<
    CastingConnecting,
    CastingConnecting,
    CastingConnecting
  >
  get copyWith =>
      _CastingConnectingCopyWithImpl<CastingConnecting, CastingConnecting>(
        this as CastingConnecting,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CastingConnectingMapper.ensureInitialized().stringifyValue(
      this as CastingConnecting,
    );
  }

  @override
  bool operator ==(Object other) {
    return CastingConnectingMapper.ensureInitialized().equalsValue(
      this as CastingConnecting,
      other,
    );
  }

  @override
  int get hashCode {
    return CastingConnectingMapper.ensureInitialized().hashValue(
      this as CastingConnecting,
    );
  }
}

extension CastingConnectingValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CastingConnecting, $Out> {
  CastingConnectingCopyWith<$R, CastingConnecting, $Out>
  get $asCastingConnecting => $base.as(
    (v, t, t2) => _CastingConnectingCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CastingConnectingCopyWith<
  $R,
  $In extends CastingConnecting,
  $Out
>
    implements UnifiedCastingStateCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>>
  get devices;
  @override
  $R call({List<CastDevice>? devices, CastDevice? device});
  CastingConnectingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CastingConnectingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CastingConnecting, $Out>
    implements CastingConnectingCopyWith<$R, CastingConnecting, $Out> {
  _CastingConnectingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CastingConnecting> $mapper =
      CastingConnectingMapper.ensureInitialized();
  @override
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>>
  get devices => ListCopyWith(
    $value.devices,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(devices: v),
  );
  @override
  $R call({List<CastDevice>? devices, CastDevice? device}) => $apply(
    FieldCopyWithData({
      if (devices != null) #devices: devices,
      if (device != null) #device: device,
    }),
  );
  @override
  CastingConnecting $make(CopyWithData data) => CastingConnecting(
    devices: data.get(#devices, or: $value.devices),
    device: data.get(#device, or: $value.device),
  );

  @override
  CastingConnectingCopyWith<$R2, CastingConnecting, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CastingConnectingCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CastingConnectedMapper extends ClassMapperBase<CastingConnected> {
  CastingConnectedMapper._();

  static CastingConnectedMapper? _instance;
  static CastingConnectedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CastingConnectedMapper._());
      UnifiedCastingStateMapper.ensureInitialized();
      PlaybackInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CastingConnected';

  static List<CastDevice> _$devices(CastingConnected v) => v.devices;
  static const Field<CastingConnected, List<CastDevice>> _f$devices = Field(
    'devices',
    _$devices,
  );
  static CastDevice _$device(CastingConnected v) => v.device;
  static const Field<CastingConnected, CastDevice> _f$device = Field(
    'device',
    _$device,
  );
  static PlaybackInfo _$playback(CastingConnected v) => v.playback;
  static const Field<CastingConnected, PlaybackInfo> _f$playback = Field(
    'playback',
    _$playback,
  );

  @override
  final MappableFields<CastingConnected> fields = const {
    #devices: _f$devices,
    #device: _f$device,
    #playback: _f$playback,
  };

  static CastingConnected _instantiate(DecodingData data) {
    return CastingConnected(
      devices: data.dec(_f$devices),
      device: data.dec(_f$device),
      playback: data.dec(_f$playback),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CastingConnected fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CastingConnected>(map);
  }

  static CastingConnected fromJson(String json) {
    return ensureInitialized().decodeJson<CastingConnected>(json);
  }
}

mixin CastingConnectedMappable {
  String toJson() {
    return CastingConnectedMapper.ensureInitialized()
        .encodeJson<CastingConnected>(this as CastingConnected);
  }

  Map<String, dynamic> toMap() {
    return CastingConnectedMapper.ensureInitialized()
        .encodeMap<CastingConnected>(this as CastingConnected);
  }

  CastingConnectedCopyWith<CastingConnected, CastingConnected, CastingConnected>
  get copyWith =>
      _CastingConnectedCopyWithImpl<CastingConnected, CastingConnected>(
        this as CastingConnected,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CastingConnectedMapper.ensureInitialized().stringifyValue(
      this as CastingConnected,
    );
  }

  @override
  bool operator ==(Object other) {
    return CastingConnectedMapper.ensureInitialized().equalsValue(
      this as CastingConnected,
      other,
    );
  }

  @override
  int get hashCode {
    return CastingConnectedMapper.ensureInitialized().hashValue(
      this as CastingConnected,
    );
  }
}

extension CastingConnectedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CastingConnected, $Out> {
  CastingConnectedCopyWith<$R, CastingConnected, $Out>
  get $asCastingConnected =>
      $base.as((v, t, t2) => _CastingConnectedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CastingConnectedCopyWith<$R, $In extends CastingConnected, $Out>
    implements UnifiedCastingStateCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>>
  get devices;
  PlaybackInfoCopyWith<$R, PlaybackInfo, PlaybackInfo> get playback;
  @override
  $R call({
    List<CastDevice>? devices,
    CastDevice? device,
    PlaybackInfo? playback,
  });
  CastingConnectedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CastingConnectedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CastingConnected, $Out>
    implements CastingConnectedCopyWith<$R, CastingConnected, $Out> {
  _CastingConnectedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CastingConnected> $mapper =
      CastingConnectedMapper.ensureInitialized();
  @override
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>>
  get devices => ListCopyWith(
    $value.devices,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(devices: v),
  );
  @override
  PlaybackInfoCopyWith<$R, PlaybackInfo, PlaybackInfo> get playback =>
      $value.playback.copyWith.$chain((v) => call(playback: v));
  @override
  $R call({
    List<CastDevice>? devices,
    CastDevice? device,
    PlaybackInfo? playback,
  }) => $apply(
    FieldCopyWithData({
      if (devices != null) #devices: devices,
      if (device != null) #device: device,
      if (playback != null) #playback: playback,
    }),
  );
  @override
  CastingConnected $make(CopyWithData data) => CastingConnected(
    devices: data.get(#devices, or: $value.devices),
    device: data.get(#device, or: $value.device),
    playback: data.get(#playback, or: $value.playback),
  );

  @override
  CastingConnectedCopyWith<$R2, CastingConnected, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CastingConnectedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PlaybackInfoMapper extends ClassMapperBase<PlaybackInfo> {
  PlaybackInfoMapper._();

  static PlaybackInfoMapper? _instance;
  static PlaybackInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlaybackInfoMapper._());
      PlaybackIdleMapper.ensureInitialized();
      PlaybackLoadingMapper.ensureInitialized();
      PlaybackPlayingMapper.ensureInitialized();
      PlaybackPausedMapper.ensureInitialized();
      PlaybackEndedMapper.ensureInitialized();
      PlaybackErrorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PlaybackInfo';

  @override
  final MappableFields<PlaybackInfo> fields = const {};

  static PlaybackInfo _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('PlaybackInfo');
  }

  @override
  final Function instantiate = _instantiate;

  static PlaybackInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlaybackInfo>(map);
  }

  static PlaybackInfo fromJson(String json) {
    return ensureInitialized().decodeJson<PlaybackInfo>(json);
  }
}

mixin PlaybackInfoMappable {
  String toJson();
  Map<String, dynamic> toMap();
  PlaybackInfoCopyWith<PlaybackInfo, PlaybackInfo, PlaybackInfo> get copyWith;
}

abstract class PlaybackInfoCopyWith<$R, $In extends PlaybackInfo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  PlaybackInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class PlaybackIdleMapper extends ClassMapperBase<PlaybackIdle> {
  PlaybackIdleMapper._();

  static PlaybackIdleMapper? _instance;
  static PlaybackIdleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlaybackIdleMapper._());
      PlaybackInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PlaybackIdle';

  @override
  final MappableFields<PlaybackIdle> fields = const {};

  static PlaybackIdle _instantiate(DecodingData data) {
    return PlaybackIdle();
  }

  @override
  final Function instantiate = _instantiate;

  static PlaybackIdle fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlaybackIdle>(map);
  }

  static PlaybackIdle fromJson(String json) {
    return ensureInitialized().decodeJson<PlaybackIdle>(json);
  }
}

mixin PlaybackIdleMappable {
  String toJson() {
    return PlaybackIdleMapper.ensureInitialized().encodeJson<PlaybackIdle>(
      this as PlaybackIdle,
    );
  }

  Map<String, dynamic> toMap() {
    return PlaybackIdleMapper.ensureInitialized().encodeMap<PlaybackIdle>(
      this as PlaybackIdle,
    );
  }

  PlaybackIdleCopyWith<PlaybackIdle, PlaybackIdle, PlaybackIdle> get copyWith =>
      _PlaybackIdleCopyWithImpl<PlaybackIdle, PlaybackIdle>(
        this as PlaybackIdle,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PlaybackIdleMapper.ensureInitialized().stringifyValue(
      this as PlaybackIdle,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlaybackIdleMapper.ensureInitialized().equalsValue(
      this as PlaybackIdle,
      other,
    );
  }

  @override
  int get hashCode {
    return PlaybackIdleMapper.ensureInitialized().hashValue(
      this as PlaybackIdle,
    );
  }
}

extension PlaybackIdleValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlaybackIdle, $Out> {
  PlaybackIdleCopyWith<$R, PlaybackIdle, $Out> get $asPlaybackIdle =>
      $base.as((v, t, t2) => _PlaybackIdleCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlaybackIdleCopyWith<$R, $In extends PlaybackIdle, $Out>
    implements PlaybackInfoCopyWith<$R, $In, $Out> {
  @override
  $R call();
  PlaybackIdleCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PlaybackIdleCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlaybackIdle, $Out>
    implements PlaybackIdleCopyWith<$R, PlaybackIdle, $Out> {
  _PlaybackIdleCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlaybackIdle> $mapper =
      PlaybackIdleMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  PlaybackIdle $make(CopyWithData data) => PlaybackIdle();

  @override
  PlaybackIdleCopyWith<$R2, PlaybackIdle, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PlaybackIdleCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PlaybackLoadingMapper extends ClassMapperBase<PlaybackLoading> {
  PlaybackLoadingMapper._();

  static PlaybackLoadingMapper? _instance;
  static PlaybackLoadingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlaybackLoadingMapper._());
      PlaybackInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PlaybackLoading';

  static MediaInfo _$media(PlaybackLoading v) => v.media;
  static const Field<PlaybackLoading, MediaInfo> _f$media = Field(
    'media',
    _$media,
  );

  @override
  final MappableFields<PlaybackLoading> fields = const {#media: _f$media};

  static PlaybackLoading _instantiate(DecodingData data) {
    return PlaybackLoading(media: data.dec(_f$media));
  }

  @override
  final Function instantiate = _instantiate;

  static PlaybackLoading fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlaybackLoading>(map);
  }

  static PlaybackLoading fromJson(String json) {
    return ensureInitialized().decodeJson<PlaybackLoading>(json);
  }
}

mixin PlaybackLoadingMappable {
  String toJson() {
    return PlaybackLoadingMapper.ensureInitialized()
        .encodeJson<PlaybackLoading>(this as PlaybackLoading);
  }

  Map<String, dynamic> toMap() {
    return PlaybackLoadingMapper.ensureInitialized().encodeMap<PlaybackLoading>(
      this as PlaybackLoading,
    );
  }

  PlaybackLoadingCopyWith<PlaybackLoading, PlaybackLoading, PlaybackLoading>
  get copyWith =>
      _PlaybackLoadingCopyWithImpl<PlaybackLoading, PlaybackLoading>(
        this as PlaybackLoading,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PlaybackLoadingMapper.ensureInitialized().stringifyValue(
      this as PlaybackLoading,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlaybackLoadingMapper.ensureInitialized().equalsValue(
      this as PlaybackLoading,
      other,
    );
  }

  @override
  int get hashCode {
    return PlaybackLoadingMapper.ensureInitialized().hashValue(
      this as PlaybackLoading,
    );
  }
}

extension PlaybackLoadingValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlaybackLoading, $Out> {
  PlaybackLoadingCopyWith<$R, PlaybackLoading, $Out> get $asPlaybackLoading =>
      $base.as((v, t, t2) => _PlaybackLoadingCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlaybackLoadingCopyWith<$R, $In extends PlaybackLoading, $Out>
    implements PlaybackInfoCopyWith<$R, $In, $Out> {
  @override
  $R call({MediaInfo? media});
  PlaybackLoadingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PlaybackLoadingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlaybackLoading, $Out>
    implements PlaybackLoadingCopyWith<$R, PlaybackLoading, $Out> {
  _PlaybackLoadingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlaybackLoading> $mapper =
      PlaybackLoadingMapper.ensureInitialized();
  @override
  $R call({MediaInfo? media}) =>
      $apply(FieldCopyWithData({if (media != null) #media: media}));
  @override
  PlaybackLoading $make(CopyWithData data) =>
      PlaybackLoading(media: data.get(#media, or: $value.media));

  @override
  PlaybackLoadingCopyWith<$R2, PlaybackLoading, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PlaybackLoadingCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PlaybackPlayingMapper extends ClassMapperBase<PlaybackPlaying> {
  PlaybackPlayingMapper._();

  static PlaybackPlayingMapper? _instance;
  static PlaybackPlayingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlaybackPlayingMapper._());
      PlaybackInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PlaybackPlaying';

  static MediaInfo _$media(PlaybackPlaying v) => v.media;
  static const Field<PlaybackPlaying, MediaInfo> _f$media = Field(
    'media',
    _$media,
  );
  static Duration _$position(PlaybackPlaying v) => v.position;
  static const Field<PlaybackPlaying, Duration> _f$position = Field(
    'position',
    _$position,
  );
  static Duration _$duration(PlaybackPlaying v) => v.duration;
  static const Field<PlaybackPlaying, Duration> _f$duration = Field(
    'duration',
    _$duration,
  );

  @override
  final MappableFields<PlaybackPlaying> fields = const {
    #media: _f$media,
    #position: _f$position,
    #duration: _f$duration,
  };

  static PlaybackPlaying _instantiate(DecodingData data) {
    return PlaybackPlaying(
      media: data.dec(_f$media),
      position: data.dec(_f$position),
      duration: data.dec(_f$duration),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PlaybackPlaying fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlaybackPlaying>(map);
  }

  static PlaybackPlaying fromJson(String json) {
    return ensureInitialized().decodeJson<PlaybackPlaying>(json);
  }
}

mixin PlaybackPlayingMappable {
  String toJson() {
    return PlaybackPlayingMapper.ensureInitialized()
        .encodeJson<PlaybackPlaying>(this as PlaybackPlaying);
  }

  Map<String, dynamic> toMap() {
    return PlaybackPlayingMapper.ensureInitialized().encodeMap<PlaybackPlaying>(
      this as PlaybackPlaying,
    );
  }

  PlaybackPlayingCopyWith<PlaybackPlaying, PlaybackPlaying, PlaybackPlaying>
  get copyWith =>
      _PlaybackPlayingCopyWithImpl<PlaybackPlaying, PlaybackPlaying>(
        this as PlaybackPlaying,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PlaybackPlayingMapper.ensureInitialized().stringifyValue(
      this as PlaybackPlaying,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlaybackPlayingMapper.ensureInitialized().equalsValue(
      this as PlaybackPlaying,
      other,
    );
  }

  @override
  int get hashCode {
    return PlaybackPlayingMapper.ensureInitialized().hashValue(
      this as PlaybackPlaying,
    );
  }
}

extension PlaybackPlayingValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlaybackPlaying, $Out> {
  PlaybackPlayingCopyWith<$R, PlaybackPlaying, $Out> get $asPlaybackPlaying =>
      $base.as((v, t, t2) => _PlaybackPlayingCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlaybackPlayingCopyWith<$R, $In extends PlaybackPlaying, $Out>
    implements PlaybackInfoCopyWith<$R, $In, $Out> {
  @override
  $R call({MediaInfo? media, Duration? position, Duration? duration});
  PlaybackPlayingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PlaybackPlayingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlaybackPlaying, $Out>
    implements PlaybackPlayingCopyWith<$R, PlaybackPlaying, $Out> {
  _PlaybackPlayingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlaybackPlaying> $mapper =
      PlaybackPlayingMapper.ensureInitialized();
  @override
  $R call({MediaInfo? media, Duration? position, Duration? duration}) => $apply(
    FieldCopyWithData({
      if (media != null) #media: media,
      if (position != null) #position: position,
      if (duration != null) #duration: duration,
    }),
  );
  @override
  PlaybackPlaying $make(CopyWithData data) => PlaybackPlaying(
    media: data.get(#media, or: $value.media),
    position: data.get(#position, or: $value.position),
    duration: data.get(#duration, or: $value.duration),
  );

  @override
  PlaybackPlayingCopyWith<$R2, PlaybackPlaying, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PlaybackPlayingCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PlaybackPausedMapper extends ClassMapperBase<PlaybackPaused> {
  PlaybackPausedMapper._();

  static PlaybackPausedMapper? _instance;
  static PlaybackPausedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlaybackPausedMapper._());
      PlaybackInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PlaybackPaused';

  static MediaInfo _$media(PlaybackPaused v) => v.media;
  static const Field<PlaybackPaused, MediaInfo> _f$media = Field(
    'media',
    _$media,
  );
  static Duration _$position(PlaybackPaused v) => v.position;
  static const Field<PlaybackPaused, Duration> _f$position = Field(
    'position',
    _$position,
  );
  static Duration _$duration(PlaybackPaused v) => v.duration;
  static const Field<PlaybackPaused, Duration> _f$duration = Field(
    'duration',
    _$duration,
  );

  @override
  final MappableFields<PlaybackPaused> fields = const {
    #media: _f$media,
    #position: _f$position,
    #duration: _f$duration,
  };

  static PlaybackPaused _instantiate(DecodingData data) {
    return PlaybackPaused(
      media: data.dec(_f$media),
      position: data.dec(_f$position),
      duration: data.dec(_f$duration),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PlaybackPaused fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlaybackPaused>(map);
  }

  static PlaybackPaused fromJson(String json) {
    return ensureInitialized().decodeJson<PlaybackPaused>(json);
  }
}

mixin PlaybackPausedMappable {
  String toJson() {
    return PlaybackPausedMapper.ensureInitialized().encodeJson<PlaybackPaused>(
      this as PlaybackPaused,
    );
  }

  Map<String, dynamic> toMap() {
    return PlaybackPausedMapper.ensureInitialized().encodeMap<PlaybackPaused>(
      this as PlaybackPaused,
    );
  }

  PlaybackPausedCopyWith<PlaybackPaused, PlaybackPaused, PlaybackPaused>
  get copyWith => _PlaybackPausedCopyWithImpl<PlaybackPaused, PlaybackPaused>(
    this as PlaybackPaused,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return PlaybackPausedMapper.ensureInitialized().stringifyValue(
      this as PlaybackPaused,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlaybackPausedMapper.ensureInitialized().equalsValue(
      this as PlaybackPaused,
      other,
    );
  }

  @override
  int get hashCode {
    return PlaybackPausedMapper.ensureInitialized().hashValue(
      this as PlaybackPaused,
    );
  }
}

extension PlaybackPausedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlaybackPaused, $Out> {
  PlaybackPausedCopyWith<$R, PlaybackPaused, $Out> get $asPlaybackPaused =>
      $base.as((v, t, t2) => _PlaybackPausedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlaybackPausedCopyWith<$R, $In extends PlaybackPaused, $Out>
    implements PlaybackInfoCopyWith<$R, $In, $Out> {
  @override
  $R call({MediaInfo? media, Duration? position, Duration? duration});
  PlaybackPausedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _PlaybackPausedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlaybackPaused, $Out>
    implements PlaybackPausedCopyWith<$R, PlaybackPaused, $Out> {
  _PlaybackPausedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlaybackPaused> $mapper =
      PlaybackPausedMapper.ensureInitialized();
  @override
  $R call({MediaInfo? media, Duration? position, Duration? duration}) => $apply(
    FieldCopyWithData({
      if (media != null) #media: media,
      if (position != null) #position: position,
      if (duration != null) #duration: duration,
    }),
  );
  @override
  PlaybackPaused $make(CopyWithData data) => PlaybackPaused(
    media: data.get(#media, or: $value.media),
    position: data.get(#position, or: $value.position),
    duration: data.get(#duration, or: $value.duration),
  );

  @override
  PlaybackPausedCopyWith<$R2, PlaybackPaused, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PlaybackPausedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PlaybackEndedMapper extends ClassMapperBase<PlaybackEnded> {
  PlaybackEndedMapper._();

  static PlaybackEndedMapper? _instance;
  static PlaybackEndedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlaybackEndedMapper._());
      PlaybackInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PlaybackEnded';

  static MediaInfo _$media(PlaybackEnded v) => v.media;
  static const Field<PlaybackEnded, MediaInfo> _f$media = Field(
    'media',
    _$media,
  );

  @override
  final MappableFields<PlaybackEnded> fields = const {#media: _f$media};

  static PlaybackEnded _instantiate(DecodingData data) {
    return PlaybackEnded(media: data.dec(_f$media));
  }

  @override
  final Function instantiate = _instantiate;

  static PlaybackEnded fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlaybackEnded>(map);
  }

  static PlaybackEnded fromJson(String json) {
    return ensureInitialized().decodeJson<PlaybackEnded>(json);
  }
}

mixin PlaybackEndedMappable {
  String toJson() {
    return PlaybackEndedMapper.ensureInitialized().encodeJson<PlaybackEnded>(
      this as PlaybackEnded,
    );
  }

  Map<String, dynamic> toMap() {
    return PlaybackEndedMapper.ensureInitialized().encodeMap<PlaybackEnded>(
      this as PlaybackEnded,
    );
  }

  PlaybackEndedCopyWith<PlaybackEnded, PlaybackEnded, PlaybackEnded>
  get copyWith => _PlaybackEndedCopyWithImpl<PlaybackEnded, PlaybackEnded>(
    this as PlaybackEnded,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return PlaybackEndedMapper.ensureInitialized().stringifyValue(
      this as PlaybackEnded,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlaybackEndedMapper.ensureInitialized().equalsValue(
      this as PlaybackEnded,
      other,
    );
  }

  @override
  int get hashCode {
    return PlaybackEndedMapper.ensureInitialized().hashValue(
      this as PlaybackEnded,
    );
  }
}

extension PlaybackEndedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlaybackEnded, $Out> {
  PlaybackEndedCopyWith<$R, PlaybackEnded, $Out> get $asPlaybackEnded =>
      $base.as((v, t, t2) => _PlaybackEndedCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlaybackEndedCopyWith<$R, $In extends PlaybackEnded, $Out>
    implements PlaybackInfoCopyWith<$R, $In, $Out> {
  @override
  $R call({MediaInfo? media});
  PlaybackEndedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PlaybackEndedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlaybackEnded, $Out>
    implements PlaybackEndedCopyWith<$R, PlaybackEnded, $Out> {
  _PlaybackEndedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlaybackEnded> $mapper =
      PlaybackEndedMapper.ensureInitialized();
  @override
  $R call({MediaInfo? media}) =>
      $apply(FieldCopyWithData({if (media != null) #media: media}));
  @override
  PlaybackEnded $make(CopyWithData data) =>
      PlaybackEnded(media: data.get(#media, or: $value.media));

  @override
  PlaybackEndedCopyWith<$R2, PlaybackEnded, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PlaybackEndedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PlaybackErrorMapper extends ClassMapperBase<PlaybackError> {
  PlaybackErrorMapper._();

  static PlaybackErrorMapper? _instance;
  static PlaybackErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlaybackErrorMapper._());
      PlaybackInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PlaybackError';

  static String _$message(PlaybackError v) => v.message;
  static const Field<PlaybackError, String> _f$message = Field(
    'message',
    _$message,
  );
  static MediaInfo? _$media(PlaybackError v) => v.media;
  static const Field<PlaybackError, MediaInfo> _f$media = Field(
    'media',
    _$media,
    opt: true,
  );

  @override
  final MappableFields<PlaybackError> fields = const {
    #message: _f$message,
    #media: _f$media,
  };

  static PlaybackError _instantiate(DecodingData data) {
    return PlaybackError(
      message: data.dec(_f$message),
      media: data.dec(_f$media),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PlaybackError fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PlaybackError>(map);
  }

  static PlaybackError fromJson(String json) {
    return ensureInitialized().decodeJson<PlaybackError>(json);
  }
}

mixin PlaybackErrorMappable {
  String toJson() {
    return PlaybackErrorMapper.ensureInitialized().encodeJson<PlaybackError>(
      this as PlaybackError,
    );
  }

  Map<String, dynamic> toMap() {
    return PlaybackErrorMapper.ensureInitialized().encodeMap<PlaybackError>(
      this as PlaybackError,
    );
  }

  PlaybackErrorCopyWith<PlaybackError, PlaybackError, PlaybackError>
  get copyWith => _PlaybackErrorCopyWithImpl<PlaybackError, PlaybackError>(
    this as PlaybackError,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return PlaybackErrorMapper.ensureInitialized().stringifyValue(
      this as PlaybackError,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlaybackErrorMapper.ensureInitialized().equalsValue(
      this as PlaybackError,
      other,
    );
  }

  @override
  int get hashCode {
    return PlaybackErrorMapper.ensureInitialized().hashValue(
      this as PlaybackError,
    );
  }
}

extension PlaybackErrorValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlaybackError, $Out> {
  PlaybackErrorCopyWith<$R, PlaybackError, $Out> get $asPlaybackError =>
      $base.as((v, t, t2) => _PlaybackErrorCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlaybackErrorCopyWith<$R, $In extends PlaybackError, $Out>
    implements PlaybackInfoCopyWith<$R, $In, $Out> {
  @override
  $R call({String? message, MediaInfo? media});
  PlaybackErrorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PlaybackErrorCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlaybackError, $Out>
    implements PlaybackErrorCopyWith<$R, PlaybackError, $Out> {
  _PlaybackErrorCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlaybackError> $mapper =
      PlaybackErrorMapper.ensureInitialized();
  @override
  $R call({String? message, Object? media = $none}) => $apply(
    FieldCopyWithData({
      if (message != null) #message: message,
      if (media != $none) #media: media,
    }),
  );
  @override
  PlaybackError $make(CopyWithData data) => PlaybackError(
    message: data.get(#message, or: $value.message),
    media: data.get(#media, or: $value.media),
  );

  @override
  PlaybackErrorCopyWith<$R2, PlaybackError, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PlaybackErrorCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

