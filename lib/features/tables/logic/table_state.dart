import '../models/table_model.dart';

class TableState {
  final List<TableModel> tables;
  final bool isLoading;

  TableState({
    required this.tables,
    this.isLoading = false,
  });

  factory TableState.initial() {
    return TableState(tables: [], isLoading: false);
  }

  TableState copyWith({
    List<TableModel>? tables,
    bool? isLoading,
  }) {
    return TableState(
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
