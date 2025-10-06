import 'package:asmara_dine/features/menu/logic/event_bloc.dart';
import 'package:asmara_dine/features/menu/logic/event_menu.dart';
import 'package:asmara_dine/features/menu/presentation/menu_screen.dart';
import 'package:asmara_dine/features/tables/logic/merge_table_bloc.dart';
import 'package:asmara_dine/features/tables/logic/table_bloc.dart';
import 'package:asmara_dine/features/tables/logic/table_state.dart';
import 'package:asmara_dine/features/tables/models/table_model.dart';
import 'package:asmara_dine/features/tables/widgets/merged_table_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TablesPage extends StatelessWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
  child: const Icon(Icons.merge),
  onPressed: () {
    context.read<MergedTableBloc>().add(MergeTables([7, 8]));
  },
),

      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(20), // <-- reduce height here
  child: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    title: const Text(
      "",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.brown,
      ),
    ),
    actions: [
      Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),
      ),
    ],
  ),
),

      body: Stack(
        children: [
          // Background image with opacity
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/asmaraOuter.jpeg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black12, // adjust this to control opacity/darkness
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child:BlocBuilder<MergedTableBloc, MergedTableState>(
  builder: (context, mergedState) {
    return BlocBuilder<TableBloc, TableState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final size = MediaQuery.of(context).size;
        final isTablet = size.width > 600;
        final crossAxisCount = isTablet ? (size.width ~/ 200).clamp(3, 6) : 3;

        // 🧩 Collect merged IDs
        final mergedIds =
            mergedState.mergedTables.expand((m) => m.tableIds).toSet();

        // Build merged tiles
        final mergedTiles = mergedState.mergedTables.map((m) {
          return MergedTableCard(mergedTable: m);
        }).toList();

        // Build normal tiles (excluding merged)
        final singleTables = state.tables
            .where((t) => !mergedIds.contains(t.id))
            .map((t) => _TableCard(table: t, tableId: t.id))
            .toList();

        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isTablet ? 1.2 : 0.9,
          children: [
            ...mergedTiles,
            ...singleTables,
          ],
        );
      },
    );
  },
),

          ),
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  final TableModel table;
  final tableId;
  const _TableCard({required this.table,required this.tableId});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(table.status);

    return InkWell(
      onTap: () {
       Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => MenuBloc(table.id)..add(LoadMenu()),
      child: MenuScreen(tableNo:  table.id),
    ),
  ),
);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.54),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusDot(
                      color: Colors.white,
                      isOccupied: table.status == "occupied",
                    ),
                    const SizedBox(width: 4),
                    Text(
                      table.status,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Icon(Icons.table_bar, size: 48, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                table.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "reserved":
        return Colors.orange;
      case "occupied":
        return Colors.red;
      case "blocked":
        return Colors.black;
      default:
        return Colors.green;
    }
  }
}

class _StatusDot extends StatefulWidget {
  final Color color;
  final bool isOccupied;
  const _StatusDot({required this.color, this.isOccupied = false});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOccupied) {
      return _dot(widget.color);
    }
    return FadeTransition(opacity: _opacity, child: _dot(widget.color));
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
