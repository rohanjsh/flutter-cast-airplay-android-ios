// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cast_state.dart';

class CastErrorMapper extends ClassMapperBase<CastError> {
  CastErrorMapper._();

  static CastErrorMapper? _instance;
  static CastErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CastErrorMapper._());
      DiscoveryErrorMapper.ensureInitialized();
      ConnectionErrorMapper.ensureInitialized();
      MediaErrorMapper.ensureInitialized();
      DisposedErrorMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CastError';

  static String _$message(CastError v) => v.message;
  static const Field<CastError, String> _f$message = Field(
    'message',
    _$message,
  );
  static Object? _$cause(CastError v) => v.cause;
  static const Field<CastError, Object> _f$cause = Field(
    'cause',
    _$cause,
    opt: true,
  );

  @override
  final MappableFields<CastError> fields = const {
    #message: _f$message,
    #cause: _f$cause,
  };

  static CastError _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('CastError');
  }

  @override
  final Function instantiate = _instantiate;

  static CastError fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CastError>(map);
  }

  static CastError fromJson(String json) {
    return ensureInitialized().decodeJson<CastError>(json);
  }
}

mixin CastErrorMappable {
  String toJson();
  Map<String, dynamic> toMap();
  CastErrorCopyWith<CastError, CastError, CastError> get copyWith;
}

abstract class CastErrorCopyWith<$R, $In extends CastError, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  CastErrorCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class DiscoveryErrorMapper extends ClassMapperBase<DiscoveryError> {
  DiscoveryErrorMapper._();

  static DiscoveryErrorMapper? _instance;
  static DiscoveryErrorMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DiscoveryErrorMapper._());
      CastErrorMapper.ensureInitialized();
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
    implements CastErrorCopyWith<$R, $In, $Out> {
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
      CastErrorMapper.ensureInitialized();
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
    implements CastErrorCopyWith<$R, $In, $Out> {
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
      CastErrorMapper.ensureInitialized();
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
    implements CastErrorCopyWith<$R, $In, $Out> {
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
      CastErrorMapper.ensureInitialized();
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
    implements CastErrorCopyWith<$R, $In, $Out> {
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

class CastStateMapper extends ClassMapperBase<CastState> {
  CastStateMapper._();

  static CastStateMapper? _instance;
  static CastStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CastStateMapper._());
      DisconnectedStateMapper.ensureInitialized();
      ConnectingStateMapper.ensureInitialized();
      ConnectedStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CastState';

  static List<CastDevice> _$devices(CastState v) => v.devices;
  static const Field<CastState, List<CastDevice>> _f$devices = Field(
    'devices',
    _$devices,
  );

  @override
  final MappableFields<CastState> fields = const {#devices: _f$devices};

  static CastState _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('CastState');
  }

  @override
  final Function instantiate = _instantiate;

  static CastState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CastState>(map);
  }

  static CastState fromJson(String json) {
    return ensureInitialized().decodeJson<CastState>(json);
  }
}

mixin CastStateMappable {
  String toJson();
  Map<String, dynamic> toMap();
  CastStateCopyWith<CastState, CastState, CastState> get copyWith;
}

abstract class CastStateCopyWith<$R, $In extends CastState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>?>
  get devices;
  $R call({List<CastDevice>? devices});
  CastStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class DisconnectedStateMapper extends ClassMapperBase<DisconnectedState> {
  DisconnectedStateMapper._();

  static DisconnectedStateMapper? _instance;
  static DisconnectedStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DisconnectedStateMapper._());
      CastStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DisconnectedState';

  static List<CastDevice> _$devices(DisconnectedState v) => v.devices;
  static const Field<DisconnectedState, List<CastDevice>> _f$devices = Field(
    'devices',
    _$devices,
  );

  @override
  final MappableFields<DisconnectedState> fields = const {#devices: _f$devices};

  static DisconnectedState _instantiate(DecodingData data) {
    return DisconnectedState(devices: data.dec(_f$devices));
  }

  @override
  final Function instantiate = _instantiate;

  static DisconnectedState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DisconnectedState>(map);
  }

  static DisconnectedState fromJson(String json) {
    return ensureInitialized().decodeJson<DisconnectedState>(json);
  }
}

mixin DisconnectedStateMappable {
  String toJson() {
    return DisconnectedStateMapper.ensureInitialized()
        .encodeJson<DisconnectedState>(this as DisconnectedState);
  }

  Map<String, dynamic> toMap() {
    return DisconnectedStateMapper.ensureInitialized()
        .encodeMap<DisconnectedState>(this as DisconnectedState);
  }

  DisconnectedStateCopyWith<
    DisconnectedState,
    DisconnectedState,
    DisconnectedState
  >
  get copyWith =>
      _DisconnectedStateCopyWithImpl<DisconnectedState, DisconnectedState>(
        this as DisconnectedState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DisconnectedStateMapper.ensureInitialized().stringifyValue(
      this as DisconnectedState,
    );
  }

  @override
  bool operator ==(Object other) {
    return DisconnectedStateMapper.ensureInitialized().equalsValue(
      this as DisconnectedState,
      other,
    );
  }

  @override
  int get hashCode {
    return DisconnectedStateMapper.ensureInitialized().hashValue(
      this as DisconnectedState,
    );
  }
}

extension DisconnectedStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DisconnectedState, $Out> {
  DisconnectedStateCopyWith<$R, DisconnectedState, $Out>
  get $asDisconnectedState => $base.as(
    (v, t, t2) => _DisconnectedStateCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class DisconnectedStateCopyWith<
  $R,
  $In extends DisconnectedState,
  $Out
>
    implements CastStateCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>>
  get devices;
  @override
  $R call({List<CastDevice>? devices});
  DisconnectedStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DisconnectedStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DisconnectedState, $Out>
    implements DisconnectedStateCopyWith<$R, DisconnectedState, $Out> {
  _DisconnectedStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DisconnectedState> $mapper =
      DisconnectedStateMapper.ensureInitialized();
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
  DisconnectedState $make(CopyWithData data) =>
      DisconnectedState(devices: data.get(#devices, or: $value.devices));

  @override
  DisconnectedStateCopyWith<$R2, DisconnectedState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DisconnectedStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ConnectingStateMapper extends ClassMapperBase<ConnectingState> {
  ConnectingStateMapper._();

  static ConnectingStateMapper? _instance;
  static ConnectingStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConnectingStateMapper._());
      CastStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ConnectingState';

  static List<CastDevice> _$devices(ConnectingState v) => v.devices;
  static const Field<ConnectingState, List<CastDevice>> _f$devices = Field(
    'devices',
    _$devices,
  );
  static CastDevice _$device(ConnectingState v) => v.device;
  static const Field<ConnectingState, CastDevice> _f$device = Field(
    'device',
    _$device,
  );

  @override
  final MappableFields<ConnectingState> fields = const {
    #devices: _f$devices,
    #device: _f$device,
  };

  static ConnectingState _instantiate(DecodingData data) {
    return ConnectingState(
      devices: data.dec(_f$devices),
      device: data.dec(_f$device),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ConnectingState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ConnectingState>(map);
  }

  static ConnectingState fromJson(String json) {
    return ensureInitialized().decodeJson<ConnectingState>(json);
  }
}

mixin ConnectingStateMappable {
  String toJson() {
    return ConnectingStateMapper.ensureInitialized()
        .encodeJson<ConnectingState>(this as ConnectingState);
  }

  Map<String, dynamic> toMap() {
    return ConnectingStateMapper.ensureInitialized().encodeMap<ConnectingState>(
      this as ConnectingState,
    );
  }

  ConnectingStateCopyWith<ConnectingState, ConnectingState, ConnectingState>
  get copyWith =>
      _ConnectingStateCopyWithImpl<ConnectingState, ConnectingState>(
        this as ConnectingState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ConnectingStateMapper.ensureInitialized().stringifyValue(
      this as ConnectingState,
    );
  }

  @override
  bool operator ==(Object other) {
    return ConnectingStateMapper.ensureInitialized().equalsValue(
      this as ConnectingState,
      other,
    );
  }

  @override
  int get hashCode {
    return ConnectingStateMapper.ensureInitialized().hashValue(
      this as ConnectingState,
    );
  }
}

extension ConnectingStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ConnectingState, $Out> {
  ConnectingStateCopyWith<$R, ConnectingState, $Out> get $asConnectingState =>
      $base.as((v, t, t2) => _ConnectingStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ConnectingStateCopyWith<$R, $In extends ConnectingState, $Out>
    implements CastStateCopyWith<$R, $In, $Out> {
  @override
  ListCopyWith<$R, CastDevice, ObjectCopyWith<$R, CastDevice, CastDevice>>
  get devices;
  @override
  $R call({List<CastDevice>? devices, CastDevice? device});
  ConnectingStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ConnectingStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ConnectingState, $Out>
    implements ConnectingStateCopyWith<$R, ConnectingState, $Out> {
  _ConnectingStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ConnectingState> $mapper =
      ConnectingStateMapper.ensureInitialized();
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
  ConnectingState $make(CopyWithData data) => ConnectingState(
    devices: data.get(#devices, or: $value.devices),
    device: data.get(#device, or: $value.device),
  );

  @override
  ConnectingStateCopyWith<$R2, ConnectingState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ConnectingStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ConnectedStateMapper extends ClassMapperBase<ConnectedState> {
  ConnectedStateMapper._();

  static ConnectedStateMapper? _instance;
  static ConnectedStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConnectedStateMapper._());
      CastStateMapper.ensureInitialized();
      PlaybackInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ConnectedState';

  static List<CastDevice> _$devices(ConnectedState v) => v.devices;
  static const Field<ConnectedState, List<CastDevice>> _f$devices = Field(
    'devices',
    _$devices,
  );
  static CastDevice _$device(ConnectedState v) => v.device;
  static const Field<ConnectedState, CastDevice> _f$device = Field(
    'device',
    _$device,
  );
  static PlaybackInfo _$playback(ConnectedState v) => v.playback;
  static const Field<ConnectedState, PlaybackInfo> _f$playback = Field(
    'playback',
    _$playback,
  );

  @override
  final MappableFields<ConnectedState> fields = const {
    #devices: _f$devices,
    #device: _f$device,
    #playback: _f$playback,
  };

  static ConnectedState _instantiate(DecodingData data) {
    return ConnectedState(
      devices: data.dec(_f$devices),
      device: data.dec(_f$device),
      playback: data.dec(_f$playback),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ConnectedState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ConnectedState>(map);
  }

  static ConnectedState fromJson(String json) {
    return ensureInitialized().decodeJson<ConnectedState>(json);
  }
}

mixin ConnectedStateMappable {
  String toJson() {
    return ConnectedStateMapper.ensureInitialized().encodeJson<ConnectedState>(
      this as ConnectedState,
    );
  }

  Map<String, dynamic> toMap() {
    return ConnectedStateMapper.ensureInitialized().encodeMap<ConnectedState>(
      this as ConnectedState,
    );
  }

  ConnectedStateCopyWith<ConnectedState, ConnectedState, ConnectedState>
  get copyWith => _ConnectedStateCopyWithImpl<ConnectedState, ConnectedState>(
    this as ConnectedState,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ConnectedStateMapper.ensureInitialized().stringifyValue(
      this as ConnectedState,
    );
  }

  @override
  bool operator ==(Object other) {
    return ConnectedStateMapper.ensureInitialized().equalsValue(
      this as ConnectedState,
      other,
    );
  }

  @override
  int get hashCode {
    return ConnectedStateMapper.ensureInitialized().hashValue(
      this as ConnectedState,
    );
  }
}

extension ConnectedStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ConnectedState, $Out> {
  ConnectedStateCopyWith<$R, ConnectedState, $Out> get $asConnectedState =>
      $base.as((v, t, t2) => _ConnectedStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ConnectedStateCopyWith<$R, $In extends ConnectedState, $Out>
    implements CastStateCopyWith<$R, $In, $Out> {
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
  ConnectedStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ConnectedStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ConnectedState, $Out>
    implements ConnectedStateCopyWith<$R, ConnectedState, $Out> {
  _ConnectedStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ConnectedState> $mapper =
      ConnectedStateMapper.ensureInitialized();
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
  ConnectedState $make(CopyWithData data) => ConnectedState(
    devices: data.get(#devices, or: $value.devices),
    device: data.get(#device, or: $value.device),
    playback: data.get(#playback, or: $value.playback),
  );

  @override
  ConnectedStateCopyWith<$R2, ConnectedState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ConnectedStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PlaybackInfoMapper extends ClassMapperBase<PlaybackInfo> {
  PlaybackInfoMapper._();

  static PlaybackInfoMapper? _instance;
  static PlaybackInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PlaybackInfoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PlaybackInfo';

  static PlaybackStatus _$status(PlaybackInfo v) => v.status;
  static const Field<PlaybackInfo, PlaybackStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: PlaybackStatus.idle,
  );
  static MediaInfo? _$media(PlaybackInfo v) => v.media;
  static const Field<PlaybackInfo, MediaInfo> _f$media = Field(
    'media',
    _$media,
    opt: true,
  );
  static Duration _$position(PlaybackInfo v) => v.position;
  static const Field<PlaybackInfo, Duration> _f$position = Field(
    'position',
    _$position,
    opt: true,
    def: Duration.zero,
  );
  static Duration _$duration(PlaybackInfo v) => v.duration;
  static const Field<PlaybackInfo, Duration> _f$duration = Field(
    'duration',
    _$duration,
    opt: true,
    def: Duration.zero,
  );
  static String? _$errorMessage(PlaybackInfo v) => v.errorMessage;
  static const Field<PlaybackInfo, String> _f$errorMessage = Field(
    'errorMessage',
    _$errorMessage,
    opt: true,
  );

  @override
  final MappableFields<PlaybackInfo> fields = const {
    #status: _f$status,
    #media: _f$media,
    #position: _f$position,
    #duration: _f$duration,
    #errorMessage: _f$errorMessage,
  };

  static PlaybackInfo _instantiate(DecodingData data) {
    return PlaybackInfo(
      status: data.dec(_f$status),
      media: data.dec(_f$media),
      position: data.dec(_f$position),
      duration: data.dec(_f$duration),
      errorMessage: data.dec(_f$errorMessage),
    );
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
  String toJson() {
    return PlaybackInfoMapper.ensureInitialized().encodeJson<PlaybackInfo>(
      this as PlaybackInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return PlaybackInfoMapper.ensureInitialized().encodeMap<PlaybackInfo>(
      this as PlaybackInfo,
    );
  }

  PlaybackInfoCopyWith<PlaybackInfo, PlaybackInfo, PlaybackInfo> get copyWith =>
      _PlaybackInfoCopyWithImpl<PlaybackInfo, PlaybackInfo>(
        this as PlaybackInfo,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PlaybackInfoMapper.ensureInitialized().stringifyValue(
      this as PlaybackInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    return PlaybackInfoMapper.ensureInitialized().equalsValue(
      this as PlaybackInfo,
      other,
    );
  }

  @override
  int get hashCode {
    return PlaybackInfoMapper.ensureInitialized().hashValue(
      this as PlaybackInfo,
    );
  }
}

extension PlaybackInfoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PlaybackInfo, $Out> {
  PlaybackInfoCopyWith<$R, PlaybackInfo, $Out> get $asPlaybackInfo =>
      $base.as((v, t, t2) => _PlaybackInfoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PlaybackInfoCopyWith<$R, $In extends PlaybackInfo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    PlaybackStatus? status,
    MediaInfo? media,
    Duration? position,
    Duration? duration,
    String? errorMessage,
  });
  PlaybackInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PlaybackInfoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PlaybackInfo, $Out>
    implements PlaybackInfoCopyWith<$R, PlaybackInfo, $Out> {
  _PlaybackInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PlaybackInfo> $mapper =
      PlaybackInfoMapper.ensureInitialized();
  @override
  $R call({
    PlaybackStatus? status,
    Object? media = $none,
    Duration? position,
    Duration? duration,
    Object? errorMessage = $none,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (media != $none) #media: media,
      if (position != null) #position: position,
      if (duration != null) #duration: duration,
      if (errorMessage != $none) #errorMessage: errorMessage,
    }),
  );
  @override
  PlaybackInfo $make(CopyWithData data) => PlaybackInfo(
    status: data.get(#status, or: $value.status),
    media: data.get(#media, or: $value.media),
    position: data.get(#position, or: $value.position),
    duration: data.get(#duration, or: $value.duration),
    errorMessage: data.get(#errorMessage, or: $value.errorMessage),
  );

  @override
  PlaybackInfoCopyWith<$R2, PlaybackInfo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PlaybackInfoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

