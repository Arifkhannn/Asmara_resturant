import '../models/table_model.dart';

abstract class TableEvent {}

class LoadTables extends TableEvent {}

class MergeTables extends TableEvent {
  final List<int> tableIds;
  MergeTables({required this.tableIds});
}

class TableStatusUpdated extends TableEvent {
  final int tableId;
  final String status;
  TableStatusUpdated({required this.tableId, required this.status});
}

class UnmergeTables extends TableEvent {
  final List<int> tableIds;
  UnmergeTables({required this.tableIds});
}

class ClearMergedTables extends TableEvent {
  final List<int> tableIds;
  ClearMergedTables({required this.tableIds});
}
