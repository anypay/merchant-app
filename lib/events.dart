import 'package:event_bus/event_bus.dart';
import 'dart:async';


class Events {
  static EventBus eventBus = EventBus();

  static void trigger(event, payload) {
    eventBus.fire(ServerMessageEvent(event, payload));
  }

  static StreamSubscription on(event, callback) {
    return eventBus.on<ServerMessageEvent>().listen((serverEvent) {
      if (serverEvent.event == event) callback(serverEvent.payload);
    });
  }
}

class ServerMessageEvent {
  Map<String, dynamic> payload;
  String event;

  ServerMessageEvent(this.event, this.payload);
}

