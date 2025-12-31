import 'dart:convert';
import 'package:asmara_dine/features/tables/data/table_status_api.dart';
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
        apiKey: "25139290d20213d2121a",
        cluster: "ap2",
        onEvent: (event) {
          print("📡 Pusher event: ${event.eventName}");
          print("📡 Raw data: ${event.data}");

          if (event.data == null) {
            print("⚠️ No data in event");
            return;
          }

          Map<String, dynamic> data;
          try {
            data = jsonDecode(event.data!);
          } catch (e) {
            print("⚠️ JSON decode failed: $e");
            return;
          }

          if (data['tables'] == null) {
            print("⚠️ No 'tables' key in Pusher data!");
            return;
          }

          final tables = data['tables'];

          // Single table
          if (tables is Map<String, dynamic>) {
            print(
              "📋 Single table update: ID=${tables['table_id']}, Status=${tables['status']}",
            );
            add(
              TableStatusUpdated(
                tableId: tables['table_id'],
                status: tables['status'],
              ),
            );
          }
          // Multiple tables
          else if (tables is List) {
            print("📋 Multiple tables update: ${tables.length} tables");
            for (final t in tables) {
              if (t is Map<String, dynamic>) {
                print("   → Table ${t['table_id']} to ${t['status']}");
                add(
                  TableStatusUpdated(
                    tableId: t['table_id'],
                    status: t['status'],
                  ),
                );
              }
            }
          } else {
            print("⚠️ 'tables' is not Map or List. Got: ${tables.runtimeType}");
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
  final TableRepository _repository = TableRepository();

  Future<void> _onLoadTables(LoadTables event, Emitter<TableState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));

      final tables = await _repository.fetchTables();
      

      emit(state.copyWith(tables: tables, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // optionally emit an error state or show snackbar
      print('Error loading tables: $e');
    }
  }

  // ----------------- Merge Tables -----------------
  void _onMergeTables(MergeTables event, Emitter<TableState> emit) {
    final ids = event.tableIds;
    if (ids.isEmpty) return;

    final updatedTables = state.tables.map((t) {
      if (ids.contains(t.id)) {
        return TableModel(
          id: t.id,
          tableNumber: t.tableNumber,
          status: 'occupied',
          mergedWith: List<int>.from(ids),
        );
      }
      return t;
    }).toList();

    emit(state.copyWith(tables: updatedTables));
  }

  // ✅ Pusher triggers THIS
  void _onTableStatusUpdated(
    TableStatusUpdated event,
    Emitter<TableState> emit,
  ) {
    print("🔍 Updating table ${event.tableId} to ${event.status}");

    final updated = state.tables.map((t) {
      if (t.id == event.tableId) {
        return TableModel(
          id: t.id,
          tableNumber: t.tableNumber,
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
          tableNumber: "Table ${t.id}",
          status: "free",
          mergedWith: [],
        );
      }
      return t;
    }).toList();

    emit(state.copyWith(tables: updated));
  }

  // ----------------- Clear merged -----------------
  void _onClearMergedTables(ClearMergedTables event, Emitter<TableState> emit) {
    final updatedTables = state.tables.map((table) {
      if (event.tableIds.contains(table.id)) {
        return table.copyWith(status: "free", mergedWith: []);
      }
      return table;
    }).toList();

    emit(state.copyWith(tables: updatedTables));
  }
}
