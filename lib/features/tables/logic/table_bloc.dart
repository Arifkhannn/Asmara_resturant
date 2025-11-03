import 'dart:convert';
import 'package:asmara_dine/features/tables/logic/table_event.dart';
import 'package:asmara_dine/features/tables/logic/table_state.dart';
import 'package:asmara_dine/features/tables/models/table_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter();

  TableBloc() : super(TableState.initial()) {
    on<LoadTables>(_onLoadTables);
    on<MergeTables>(_onMergeTables);
    on<TableStatusUpdated>(_onTableStatusUpdated);
    on<UnmergeTables>(_onUnmergeTables);
    on<ClearMergedTables>(_onClearMergedTables);

    _initPusher(); // ✅ Realtime listener ON
  }

  // ------------------ Pusher Init ------------------
  Future<void> _initPusher() async {
    try {
      await pusher.init(
        apiKey: "212af9d41c92442f4b94",
        cluster: "ap2",
        onEvent: (event) {
          print("🔥 Pusher event received: ${event.data}");

          final data = jsonDecode(event.data);

          if (data['tables'] != null) {
            final tables = data['tables'];

            // Single table
            if (tables is Map<String, dynamic>) {
              add(TableStatusUpdated(
                tableId: tables['table_id'],
                status: tables['status'],
              ));
            }

            // Multiple tables
            else if (tables is List) {
              for (var t in tables) {
                add(TableStatusUpdated(
                  tableId: t['table_id'],
                  status: t['status'],
                ));
              }
            }
          }
        },
      );

      await pusher.subscribe(channelName: "Order");
      await pusher.connect();
      print("✅ Pusher Connected!");
    } catch (e) {
      print("❌ Pusher Error: $e");
    }
  }

  @override
  Future<void> close() {
    pusher.disconnect();
    return super.close();
  }

  // ----------------- Load Tables -----------------
  void _onLoadTables(LoadTables event, Emitter<TableState> emit) {
    final tables = List.generate(
      17,
      (i) => TableModel(id: i + 1, name: "Table ${i + 1}", status: "free"),
    );

    emit(state.copyWith(tables: tables, isLoading: false));
  }

  // ----------------- Merge Tables -----------------
  void _onMergeTables(MergeTables event, Emitter<TableState> emit) {
    final ids = event.tableIds;
    if (ids.isEmpty) return;

    final updatedTables = state.tables.map((t) {
      if (ids.contains(t.id)) {
        return TableModel(
          id: t.id,
          name: t.name,
          status: 'occupied',
          mergedWith: ids,
        );
      }
      return t;
    }).toList();

    emit(state.copyWith(tables: updatedTables));
  }

  // ✅ Pusher triggers THIS
  void _onTableStatusUpdated(TableStatusUpdated event, Emitter<TableState> emit) {
    final updated = state.tables.map((t) {
      if (t.id == event.tableId) {
        return TableModel(
          id: t.id,
          name: t.name,
          status: event.status,
          mergedWith: t.mergedWith,
        );
      }
      return t;
    }).toList();

    emit(state.copyWith(tables: updated));
  }

  // ----------------- Unmerge Tables -----------------
  void _onUnmergeTables(UnmergeTables event, Emitter<TableState> emit) {
    final updated = state.tables.map((t) {
      if (event.tableIds.contains(t.id)) {
        return TableModel(
          id: t.id,
          name: "Table ${t.id}",
          status: "free",
          mergedWith: [],
        );
      }
      return t;
    }).toList();

    emit(state.copyWith(tables: updated));
  }

  // ----------------- Clear merged -----------------
  void _onClearMergedTables(
    ClearMergedTables event, Emitter<TableState> emit) {

  final updatedTables = state.tables.map((table) {
    if (event.tableIds.contains(table.id)) {
      return table.copyWith(
        status: "free",
        mergedWith: null,
      );
    }
    return table;
  }).toList();

  emit(state.copyWith(tables: updatedTables));
}

}
