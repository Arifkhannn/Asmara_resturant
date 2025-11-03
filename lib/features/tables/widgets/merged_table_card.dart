/*import 'package:asmara_dine/features/menu/logic/event_bloc.dart';
import 'package:asmara_dine/features/menu/logic/event_menu.dart';
import 'package:asmara_dine/features/menu/presentation/menu_screen.dart';
import 'package:asmara_dine/features/tables/models/merge_table_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MergedTableCard extends StatelessWidget {
  final MergedTable mergedTable;
  const MergedTableCard({required this.mergedTable});

  @override
  Widget build(BuildContext context) {
    final label = "Table ${mergedTable.mergedId}";
    return InkWell(
      onTap: () {
        // When tapped, open menu for merged table (first table ID)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) {
                final bloc = MenuBloc(mergedTable.tableIds.first);
                bloc.add(LoadMenu());
                return bloc;
              },
              child: MenuScreen(tableNo: mergedTable.tableIds.first),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black26, width: 1.5),
        ),
        child: Center(
          child: Text(
            "$label (Merged)",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}*/
