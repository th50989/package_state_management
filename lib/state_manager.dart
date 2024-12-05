library state_manager;

import 'package:flutter/widgets.dart';

/// Class StateManager handle lưu trữ các state
class StateManager {
  static final Map<String, dynamic> _states = {};
  static final Map<String, List<VoidCallback>> _listeners = {};
  static final Map<String, bool> _loadingStates = {}; // Trạng thái loading
  static final Map<String, Object?> _errorStates = {}; // Trạng thái lỗi

  static void createState<T>(String key, T initialValue) {
    if (_states.containsKey(key)) {
      throw Exception("State '$key' đã tồn tại.");
    }
    _states[key] = initialValue;
    _listeners[key] = [];
    _loadingStates[key] = false;
    _errorStates[key] = null;
  }

  static T getState<T>(String key) {
    if (!_states.containsKey(key)) {
      throw Exception("State '$key' không tồn tại.");
    }
    return _states[key] as T;
  }

  // Lấy ra trạng thái loading
  static bool isLoading(String key) {
    return _loadingStates[key] ?? false;
  }

  // Lấy ra trạng thái lỗi
  static Object? getError(String key) {
    return _errorStates[key];
  }

  static void updateState<T>(String key, T Function(T currentValue) update) {
    if (!_states.containsKey(key)) {
      throw Exception("State '$key' không tồn tại.");
    }
    final currentValue = _states[key] as T;
    final newValue = update(currentValue);
    _states[key] = newValue;
    _notifyListeners(key);
  }

  // Cập nhật state bất đồng bộ
  static Future<void> updateStateAsync<T>(
    String key,
    Future<T> Function(T currentValue) asyncUpdate,
  ) async {
    if (!_states.containsKey(key)) {
      throw Exception("State '$key' không tồn tại.");
    }

    _loadingStates[key] = true; // Đặt loading = true
    _notifyListeners(key);

    try {
      final currentValue = _states[key] as T;
      final newValue = await asyncUpdate(currentValue);
      _states[key] = newValue;
      _errorStates[key] = null; // Xóa lỗi nếu thành công
    } catch (e) {
      _errorStates[key] = e; // Lưu lỗi
    } finally {
      _loadingStates[key] = false; // Đặt loading = false
      _notifyListeners(key);
    }
  }

  static void watchState<T>(String key, VoidCallback listener) {
    if (!_listeners.containsKey(key)) {
      throw Exception("State '$key' không tồn tại.");
    }
    _listeners[key]?.add(listener);
  }

  static void resetState(String key) {
    if (_states.containsKey(key)) {
      _states.remove(key);
      _listeners.remove(key);
      _loadingStates.remove(key);
      _errorStates.remove(key);
    }
  }

  static void _notifyListeners(String key) {
    if (_listeners.containsKey(key)) {
      for (final listener in _listeners[key]!) {
        listener();
      }
    }
  }
}

/// Widget StatefulListener, custom widget để hiển thị trên ui
class StatefulListener<T> extends StatefulWidget {
  final String stateKey;
  final Widget Function(BuildContext context, T value) builder;

  const StatefulListener({
    required this.stateKey,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulListener<T>> createState() => _StatefulListenerState<T>();
}

class _StatefulListenerState<T> extends State<StatefulListener<T>> {
  @override
  void initState() {
    super.initState();
    StateManager.watchState<T>(widget.stateKey, _onStateChanged);
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final value = StateManager.getState<T>(widget.stateKey);
    return widget.builder(context, value);
  }
}
