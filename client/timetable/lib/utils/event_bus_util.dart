import 'dart:async';

import 'package:event_bus/event_bus.dart';

class EventBusUtil {
  static EventBus? _eventBus;
  static final Map<String, List<StreamSubscription>?> _map = Map();

  static EventBus getInstance() {
    if (_eventBus == null) {
      _eventBus = new EventBus();
    }
    return _eventBus!;
  }

  static StreamSubscription<T> listen<T>(String key, void onData(T event)?,
      {Function? onError = _onError}) {
    if (_map[key] == null) {
      _map[key] = [];
    }
    final subscription = getInstance().on<T>().listen(onData, onError: onError);
    _map[key]!.add(subscription);

    return subscription;
  }

  static void cancelAllByKey(String key) {
    if (_map[key] != null) {
      for (var item in _map[key]!) {
        item.cancel();
      }
      _map.remove(key);
    }
  }

  static void cancelAll() {
    _map.forEach((key, value) {
      if (value != null) {
        for (var item in value) {
          item.cancel();
        }
      }
    });
    _map.clear();
  }
}

void _onError(dynamic error) {
  print(error);
}
