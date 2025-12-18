import 'package:asmara_dine/core/allOrders.dart';
import 'package:asmara_dine/core/animation/animatedPageRoute.dart';
import 'package:asmara_dine/features/menu/logic/event_bloc.dart';
import 'package:asmara_dine/features/menu/logic/event_menu.dart';
import 'package:asmara_dine/features/menu/presentation/menu_screen.dart';
import 'package:asmara_dine/features/tables/logic/table_bloc.dart';
import 'package:asmara_dine/features/tables/logic/table_event.dart';
import 'package:asmara_dine/features/tables/logic/table_state.dart';
import 'package:asmara_dine/features/tables/models/table_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final Set<int> _selected = {};
  bool _mergeMode = false;

  @override
  void initState() {
    super.initState();
    context.read<TableBloc>().add(LoadTables());
  }

  bool get _isMergeMode => _mergeMode;

  void _toggleMergeMode() {
    setState(() {
      _mergeMode = !_mergeMode;
      if (!_mergeMode) _selected.clear();
    });
  }

  void _selectToggle(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  String _mergedLabel(List<int> ids) {
    final s = [...ids]..sort();
    return s.join('+');
  }

  Future<void> _onRefresh() async {
    context.read<TableBloc>().add(LoadTables());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   // --- UI Update: Clean, transparent AppBar ---
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   // --- End UI Update ---
      //   title: Text(
      //     _isMergeMode ? 'Merge Tables (${_selected.length})' : 'Tables',
      //     style: const TextStyle(
      //       fontWeight: FontWeight.bold,
      //       fontSize: 20,
      //       color: Color.fromARGB(255, 255, 255, 255),
      //       // --- UI Update: Added a subtle shadow to text for readability ---
      //       shadows: [
      //         Shadow(
      //           color: Colors.black26,
      //           blurRadius: 4,
      //           offset: Offset(1, 1),
      //         ),
      //       ],
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(
      //         Icons.refresh_outlined,
      //         color: const Color.fromARGB(255, 255, 255, 254),
      //         size: 38, // UI Update: Slightly larger icon
      //       ),
      //       onPressed: () {
      //         context.read<TableBloc>().add(LoadTables());
      //       },
      //     ),
      //     IconButton(
      //       icon: Icon(
      //         _isMergeMode ? Icons.close : Icons.merge_type,
      //         color: const Color.fromARGB(255, 255, 255, 255),
      //         size: 38, // UI Update: Slightly larger icon
      //       ),
      //       onPressed: _toggleMergeMode,
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.list_alt, color: Colors.white),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (_) => BlocProvider(
      //               create: (_) => MenuBloc([])..add(LoadAllOrders()),
      //               child: const AllOrdersScreen(),
      //             ),
      //           ),
      //         );
      //       },
      //     ),

      //     if (_isMergeMode)
      //       IconButton(
      //         icon: const Icon(
      //           Icons.check,
      //           color: Color.fromARGB(255, 255, 252, 251),
      //           size: 38, // UI Update: Slightly larger icon
      //         ),
      //         onPressed: _selected.isNotEmpty
      //             ? () {
      //                 final ids = _selected.toList();
      //                 context.read<TableBloc>().add(MergeTables(tableIds: ids));
      //                 setState(() {
      //                   _mergeMode = false;
      //                 });
      //                 Navigator.push(
      //                   context,
      //                   MaterialPageRoute(
      //                     builder: (_) => BlocProvider(
      //                       create: (_) => MenuBloc(ids),
      //                       child: MenuScreen.fromTableIds(tableIds: ids),
      //                     ),
      //                   ),
      //                 ).then((_) {
      //                   setState(() {
      //                     _selected.clear();
      //                   });
      //                 });
      //               }
      //             : null,
      //       ),
      //   ],
      // ),
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: const Color.fromARGB(0, 255, 249, 249),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 6),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 214, 255, 66).withOpacity(0.1),
                    const Color.fromARGB(255, 252, 253, 252).withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          _isMergeMode ? 'Merge Tables (${_selected.length})' : 'Tables',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        actions: [
          _AppBarIcon(
            icon: Icons.refresh_rounded,
            onTap: () =>
                context.read<TableBloc>().add(LoadTables()),
          ),
          _AppBarIcon(
            icon: _isMergeMode
                ? Icons.close_rounded
                : Icons.merge_type_rounded,
            onTap: _toggleMergeMode,
          ),
          _AppBarIcon(
            icon: Icons.list_alt_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) =>
                        MenuBloc([])..add(LoadAllOrders()),
                    child: const AllOrdersScreen(),
                  ),
                ),
              );
            },
          ),
          if (_isMergeMode)
            _AppBarIcon(
              icon: Icons.check_circle_rounded,
              color: Colors.greenAccent,
              onTap: _selected.isNotEmpty
                  ? () {
                      final ids = _selected.toList();
                      context
                          .read<TableBloc>()
                          .add(MergeTables(tableIds: ids));
                      setState(() => _mergeMode = false);

                     Navigator.push(
  context,
  AnimatedPageRoute(
    page: BlocProvider(
      create: (_) => MenuBloc(ids),
      child: MenuScreen.fromTableIds(
        tableIds: ids,
      ),
    ),
  ),
).then((_) {
  setState(_selected.clear);
});


                 

                    }
                  : null,
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/asmaraOuter.jpeg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: BlocBuilder<TableBloc, TableState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator(
                    color: Colors.green,
                  ));
                }

                final size = MediaQuery.of(context).size;
                final isTablet = size.width > 600;
                final crossAxisCount = isTablet
                    ? (size.width ~/ 200).clamp(3, 6)
                    : 3;

                // return GridView.builder(
                //   padding: const EdgeInsets.all(16),
                //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: crossAxisCount,
                //     crossAxisSpacing: 16,
                //     mainAxisSpacing: 16,
                //     childAspectRatio: isTablet ? 1.2 : 0.9,
                //   ),
                //   itemCount: state.tables.length,
                //   itemBuilder: (context, index) {
                //     final table = state.tables[index];
                //     final isSelected = _selected.contains(table.id);
                //     final isMerged =
                //         table.mergedWith != null &&
                //         table.mergedWith!.isNotEmpty;
                //     final mergedLabel = isMerged
                //         ? _mergedLabel(table.mergedWith!)
                //         : null;

                //     return GestureDetector(
                //       onLongPress: () {
                //         setState(() {
                //           _mergeMode = true;
                //           _selectToggle(table.id);
                //         });
                //       },
                //       onTap: () {
                //         if (_isMergeMode) {
                //           _selectToggle(table.id);
                //           return;
                //         }

                //         final ids = isMerged ? table.mergedWith! : [table.id];

                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (_) => BlocProvider(
                //               create: (_) => MenuBloc(ids),
                //               child: MenuScreen.fromTableIds(tableIds: ids),
                //             ),
                //           ),
                //         );
                //       },
                //       child: _TableCard(
                //         table: table,
                //         isSelected: isSelected,
                //         mergedLabel: mergedLabel,
                //       ),
                //     );
                //   },
                // );
                return RefreshIndicator(
  onRefresh: _onRefresh,
  color: Colors.green,
  child: GridView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isTablet ? 1.2 : 0.9,
    ),
    itemCount: state.tables.length,
    itemBuilder: (context, index) {
      final table = state.tables[index];
      final isSelected = _selected.contains(table.id);
      final isMerged =
          table.mergedWith != null && table.mergedWith!.isNotEmpty;
      final mergedLabel =
          isMerged ? _mergedLabel(table.mergedWith!) : null;

      return GestureDetector(
        onLongPress: () {
          setState(() {
            _mergeMode = true;
            _selectToggle(table.id);
          });
        },
        onTap: () {
          if (_isMergeMode) {
            _selectToggle(table.id);
            return;
          }

          final ids = isMerged ? table.mergedWith! : [table.id];

          Navigator.push(
  context,
  AnimatedPageRoute(
    page: BlocProvider(
      create: (_) => MenuBloc(ids),
      child: MenuScreen.fromTableIds(tableIds: ids),
    ),
  ),
);

        },
        child: _TableCard(
          table: table,
          isSelected: isSelected,
          mergedLabel: mergedLabel,
        ),
      );
    },
  ),
);

              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Entirely New _TableCard Widget (Soft UI / Neumorphic) ---
class _TableCard extends StatelessWidget {
  final TableModel table;
  final bool isSelected;
  final String? mergedLabel;

  const _TableCard({
    required this.table,
    this.isSelected = false,
    this.mergedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(table.status);

    // --- UI Update: Define colors for the soft UI style ---
    final cardColor = isSelected
        ? Colors.blueAccent.withOpacity(0.7)
        : Colors.white.withOpacity(0.5);
    final shadowColor = Colors.black.withOpacity(0.1);
    final highlightColor = Colors.white.withOpacity(0.7);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      // --- Animation: Scale transform ---
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        // --- UI Update: Animated border ---
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          width: isSelected ? 3 : 0,
        ),
        // --- UI Update: Animated shadows for "soft" effect ---
        boxShadow: isSelected
            ? [
                // No shadows when selected, just the border and scale
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [
                // "Extruded" look with a dark and light shadow
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(5, 5),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: highlightColor,
                  offset: const Offset(-5, -5),
                  blurRadius: 10,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
                // --- UI Update: Add a subtle shadow to the status pill ---
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                table.status,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Icon(
                Icons.table_restaurant, // Changed icon
                size: 48,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            mergedLabel != null
                ? '${table.id} ($mergedLabel)'
                : table.id.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "reserved":
        return Colors.orange;
      case "occupied":
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}
class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _AppBarIcon({
    required this.icon,
    this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 22,
      icon: Icon(icon, size: 28, color: color),
      onPressed: onTap,
    );
  }
}