// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ProjectState> _$projectStateSerializer =
    new _$ProjectStateSerializer();
Serializer<ProjectUIState> _$projectUIStateSerializer =
    new _$ProjectUIStateSerializer();

class _$ProjectStateSerializer implements StructuredSerializer<ProjectState> {
  @override
  final Iterable<Type> types = const [ProjectState, _$ProjectState];
  @override
  final String wireName = 'ProjectState';

  @override
  Iterable<Object> serialize(Serializers serializers, ProjectState object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'map',
      serializers.serialize(object.map,
          specifiedType: const FullType(BuiltMap,
              const [const FullType(String), const FullType(ProjectEntity)])),
      'list',
      serializers.serialize(object.list,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
    ];

    return result;
  }

  @override
  ProjectState deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ProjectStateBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object value = iterator.current;
      switch (key) {
        case 'map':
          result.map.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap, const [
                const FullType(String),
                const FullType(ProjectEntity)
              ])));
          break;
        case 'list':
          result.list.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(String)]))
              as BuiltList<Object>);
          break;
      }
    }

    return result.build();
  }
}

class _$ProjectUIStateSerializer
    implements StructuredSerializer<ProjectUIState> {
  @override
  final Iterable<Type> types = const [ProjectUIState, _$ProjectUIState];
  @override
  final String wireName = 'ProjectUIState';

  @override
  Iterable<Object> serialize(Serializers serializers, ProjectUIState object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'listUIState',
      serializers.serialize(object.listUIState,
          specifiedType: const FullType(ListUIState)),
      'tabIndex',
      serializers.serialize(object.tabIndex,
          specifiedType: const FullType(int)),
    ];
    Object value;
    value = object.editing;
    if (value != null) {
      result
        ..add('editing')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(ProjectEntity)));
    }
    value = object.selectedId;
    if (value != null) {
      result
        ..add('selectedId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.forceSelected;
    if (value != null) {
      result
        ..add('forceSelected')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    return result;
  }

  @override
  ProjectUIState deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ProjectUIStateBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object value = iterator.current;
      switch (key) {
        case 'editing':
          result.editing.replace(serializers.deserialize(value,
              specifiedType: const FullType(ProjectEntity)) as ProjectEntity);
          break;
        case 'listUIState':
          result.listUIState.replace(serializers.deserialize(value,
              specifiedType: const FullType(ListUIState)) as ListUIState);
          break;
        case 'selectedId':
          result.selectedId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'forceSelected':
          result.forceSelected = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
        case 'tabIndex':
          result.tabIndex = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
      }
    }

    return result.build();
  }
}

class _$ProjectState extends ProjectState {
  @override
  final BuiltMap<String, ProjectEntity> map;
  @override
  final BuiltList<String> list;

  factory _$ProjectState([void Function(ProjectStateBuilder) updates]) =>
      (new ProjectStateBuilder()..update(updates)).build();

  _$ProjectState._({this.map, this.list}) : super._() {
    BuiltValueNullFieldError.checkNotNull(map, 'ProjectState', 'map');
    BuiltValueNullFieldError.checkNotNull(list, 'ProjectState', 'list');
  }

  @override
  ProjectState rebuild(void Function(ProjectStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectStateBuilder toBuilder() => new ProjectStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectState && map == other.map && list == other.list;
  }

  int __hashCode;
  @override
  int get hashCode {
    return __hashCode ??= $jf($jc($jc(0, map.hashCode), list.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ProjectState')
          ..add('map', map)
          ..add('list', list))
        .toString();
  }
}

class ProjectStateBuilder
    implements Builder<ProjectState, ProjectStateBuilder> {
  _$ProjectState _$v;

  MapBuilder<String, ProjectEntity> _map;
  MapBuilder<String, ProjectEntity> get map =>
      _$this._map ??= new MapBuilder<String, ProjectEntity>();
  set map(MapBuilder<String, ProjectEntity> map) => _$this._map = map;

  ListBuilder<String> _list;
  ListBuilder<String> get list => _$this._list ??= new ListBuilder<String>();
  set list(ListBuilder<String> list) => _$this._list = list;

  ProjectStateBuilder();

  ProjectStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _map = $v.map.toBuilder();
      _list = $v.list.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProjectState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ProjectState;
  }

  @override
  void update(void Function(ProjectStateBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ProjectState build() {
    _$ProjectState _$result;
    try {
      _$result =
          _$v ?? new _$ProjectState._(map: map.build(), list: list.build());
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'map';
        map.build();
        _$failedField = 'list';
        list.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'ProjectState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$ProjectUIState extends ProjectUIState {
  @override
  final ProjectEntity editing;
  @override
  final ListUIState listUIState;
  @override
  final String selectedId;
  @override
  final bool forceSelected;
  @override
  final int tabIndex;
  @override
  final Completer<SelectableEntity> saveCompleter;
  @override
  final Completer<Null> cancelCompleter;

  factory _$ProjectUIState([void Function(ProjectUIStateBuilder) updates]) =>
      (new ProjectUIStateBuilder()..update(updates)).build();

  _$ProjectUIState._(
      {this.editing,
      this.listUIState,
      this.selectedId,
      this.forceSelected,
      this.tabIndex,
      this.saveCompleter,
      this.cancelCompleter})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        listUIState, 'ProjectUIState', 'listUIState');
    BuiltValueNullFieldError.checkNotNull(
        tabIndex, 'ProjectUIState', 'tabIndex');
  }

  @override
  ProjectUIState rebuild(void Function(ProjectUIStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectUIStateBuilder toBuilder() =>
      new ProjectUIStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectUIState &&
        editing == other.editing &&
        listUIState == other.listUIState &&
        selectedId == other.selectedId &&
        forceSelected == other.forceSelected &&
        tabIndex == other.tabIndex &&
        saveCompleter == other.saveCompleter &&
        cancelCompleter == other.cancelCompleter;
  }

  int __hashCode;
  @override
  int get hashCode {
    return __hashCode ??= $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc($jc($jc(0, editing.hashCode), listUIState.hashCode),
                        selectedId.hashCode),
                    forceSelected.hashCode),
                tabIndex.hashCode),
            saveCompleter.hashCode),
        cancelCompleter.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('ProjectUIState')
          ..add('editing', editing)
          ..add('listUIState', listUIState)
          ..add('selectedId', selectedId)
          ..add('forceSelected', forceSelected)
          ..add('tabIndex', tabIndex)
          ..add('saveCompleter', saveCompleter)
          ..add('cancelCompleter', cancelCompleter))
        .toString();
  }
}

class ProjectUIStateBuilder
    implements Builder<ProjectUIState, ProjectUIStateBuilder> {
  _$ProjectUIState _$v;

  ProjectEntityBuilder _editing;
  ProjectEntityBuilder get editing =>
      _$this._editing ??= new ProjectEntityBuilder();
  set editing(ProjectEntityBuilder editing) => _$this._editing = editing;

  ListUIStateBuilder _listUIState;
  ListUIStateBuilder get listUIState =>
      _$this._listUIState ??= new ListUIStateBuilder();
  set listUIState(ListUIStateBuilder listUIState) =>
      _$this._listUIState = listUIState;

  String _selectedId;
  String get selectedId => _$this._selectedId;
  set selectedId(String selectedId) => _$this._selectedId = selectedId;

  bool _forceSelected;
  bool get forceSelected => _$this._forceSelected;
  set forceSelected(bool forceSelected) =>
      _$this._forceSelected = forceSelected;

  int _tabIndex;
  int get tabIndex => _$this._tabIndex;
  set tabIndex(int tabIndex) => _$this._tabIndex = tabIndex;

  Completer<SelectableEntity> _saveCompleter;
  Completer<SelectableEntity> get saveCompleter => _$this._saveCompleter;
  set saveCompleter(Completer<SelectableEntity> saveCompleter) =>
      _$this._saveCompleter = saveCompleter;

  Completer<Null> _cancelCompleter;
  Completer<Null> get cancelCompleter => _$this._cancelCompleter;
  set cancelCompleter(Completer<Null> cancelCompleter) =>
      _$this._cancelCompleter = cancelCompleter;

  ProjectUIStateBuilder();

  ProjectUIStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _editing = $v.editing?.toBuilder();
      _listUIState = $v.listUIState.toBuilder();
      _selectedId = $v.selectedId;
      _forceSelected = $v.forceSelected;
      _tabIndex = $v.tabIndex;
      _saveCompleter = $v.saveCompleter;
      _cancelCompleter = $v.cancelCompleter;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProjectUIState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ProjectUIState;
  }

  @override
  void update(void Function(ProjectUIStateBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$ProjectUIState build() {
    _$ProjectUIState _$result;
    try {
      _$result = _$v ??
          new _$ProjectUIState._(
              editing: _editing?.build(),
              listUIState: listUIState.build(),
              selectedId: selectedId,
              forceSelected: forceSelected,
              tabIndex: BuiltValueNullFieldError.checkNotNull(
                  tabIndex, 'ProjectUIState', 'tabIndex'),
              saveCompleter: saveCompleter,
              cancelCompleter: cancelCompleter);
    } catch (_) {
      String _$failedField;
      try {
        _$failedField = 'editing';
        _editing?.build();
        _$failedField = 'listUIState';
        listUIState.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'ProjectUIState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
