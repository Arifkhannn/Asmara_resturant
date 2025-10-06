import 'package:asmara_dine/features/tables/models/table_model.dart';

abstract class TableEvent {}

class TableLoad extends TableEvent {}

class TableStatusUpdated extends TableEvent {
  final int tableId; // kaunsa table update hua
  final String status;

  TableStatusUpdated({required this.tableId, required this.status});
}
