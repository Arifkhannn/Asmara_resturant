import 'dart:convert';

import 'package:asmara_dine/features/tables/logic/table_event.dart';
import 'package:asmara_dine/features/tables/logic/table_state.dart';
import 'package:asmara_dine/features/tables/models/table_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter();
  TableBloc()
    : super(
        TableState(
          tables: List.generate(
            17,
            (i) =>
                TableModel(id: i + 1, name: "Table ${i + 1}", status: "free"),
          ),
          isLoading: false,
        ),
      ) {
    on<TableStatusUpdated>(_onTableStatusUpdated);

    _initPusher(); // start listening
  }

  void _onTableStatusUpdated(
    TableStatusUpdated event,
    Emitter<TableState> emit,
  ) {
    // purane tables ko map karo aur jis table ka id match kare uska status badal do
    final updated = state.tables.map((t) {
      if (t.id == event.tableId) {
        return TableModel(id: t.id, name: t.name, status: event.status);
      }
      return t; // baaki tables same rahenge
    }).toList();

    // naya state bhej do
    emit(state.copyWith(tables: updated));
  }

  Future<void> _initPusher() async {
    await pusher.init(
      apiKey: "212af9d41c92442f4b94",
      cluster: "ap2",
      onEvent: (event) {
        print("Event received:");
        print("Channel: ${event.channelName}");
        print("Event: ${event.eventName}");
        print("Data: ${event.data}");

        if (event.channelName == "Order" && event.eventName == "order.booked") {
          final data = jsonDecode(event.data);

          if (data['tables'] != null) {
            final tables = data['tables'];

            // case 1: agar ek hi object aya (Map)
            if (tables is Map<String, dynamic>) {
              add(
                TableStatusUpdated(
                  tableId: tables['table_id'],
                  status: tables['status'],
                ),
              );
            }
            // case 2: agar list of tables aya
            else if (tables is List) {
              for (var t in tables) {
                add(
                  TableStatusUpdated(
                    tableId: t['table_id'],
                    status: t['status'],
                  ),
                );
              }
            }
          }
        }
      },
    );

    // channel subscribe karo
    await pusher.subscribe(channelName: "Order");

    // connection establish karo
    await pusher.connect();
  }
}
