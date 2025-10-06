import 'package:asmara_dine/features/tables/models/merge_table_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MergedTableState {
  final List<MergedTable> mergedTables;

  MergedTableState({required this.mergedTables});

  MergedTableState copyWith({List<MergedTable>? mergedTables}) {
    return MergedTableState(mergedTables: mergedTables ?? this.mergedTables);
  }
}

abstract class MergedTableEvent {}

class MergeTables extends MergedTableEvent {
  final List<int> tableIds;
  MergeTables(this.tableIds);
}

class UnmergeTables extends MergedTableEvent {
  final String mergedId;
  UnmergeTables(this.mergedId);
}

class MergedTableBloc extends Bloc<MergedTableEvent, MergedTableState> {
  MergedTableBloc() : super(MergedTableState(mergedTables: [])) {
    on<MergeTables>(_onMergeTables);
    on<UnmergeTables>(_onUnmergeTables);
  }

  void _onMergeTables(MergeTables event, Emitter<MergedTableState> emit) {
    final id = event.tableIds.join('-');
    final newMerged = MergedTable(mergedId: id, tableIds: event.tableIds);
    final updated = [...state.mergedTables, newMerged];
    emit(state.copyWith(mergedTables: updated));
  }

  void _onUnmergeTables(UnmergeTables event, Emitter<MergedTableState> emit) {
    final updated = state.mergedTables
        .where((m) => m.mergedId != event.mergedId)
        .toList();
    emit(state.copyWith(mergedTables: updated));
  }
}
