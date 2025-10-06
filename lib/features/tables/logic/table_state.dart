import 'package:asmara_dine/features/tables/models/table_model.dart';

class TableState {
  final List<TableModel> tables;
  final bool isLoading;
  TableState({required this.tables,this.isLoading = false});
   TableState copyWith({List<TableModel>? tables, bool? isLoading}) {
    return TableState(
      tables: tables ?? this.tables,       // agar naya list mila to use, warna purana hi rakho
      isLoading: isLoading ?? this.isLoading, // same logic
    );
  }
  
}
