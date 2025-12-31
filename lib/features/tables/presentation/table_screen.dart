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
      _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    });
  }

  /// builds "02+04+07"
  String _mergedLabel(List<String> tableNumbers) {
    final s = [...tableNumbers]..sort();
    return s.join('+');
  }

  Future<void> _onRefresh() async {
    context.read<TableBloc>().add(LoadTables());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: BlocBuilder<TableBloc, TableState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                /// ID → tableNumber map (KEY FIX)
                final Map<int, String> idToTableNumber = {
                  for (final t in state.tables) t.id: t.tableNumber,
                };

                final size = MediaQuery.of(context).size;
                final isTablet = size.width > 600;
                final crossAxisCount = isTablet
                    ? (size.width ~/ 200).clamp(3, 6)
                    : 3;

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
                          table.mergedWith != null &&
                          table.mergedWith!.length > 1;

                      /// 🔑 merged TABLE NUMBERS (not IDs)
                      final mergedLabel = isMerged
                          ? _mergedLabel(
                              table.mergedWith!
                                  .map(
                                    (id) =>
                                        idToTableNumber[id] ?? id.toString(),
                                  )
                                  .toList(),
                            )
                          : null;

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
                          final tableNumbers = ids
                              .map((id) => idToTableNumber[id] ?? id.toString())
                              .toList();

                          Navigator.push(
                            context,
                            AnimatedPageRoute(
                              page: BlocProvider(
                                create: (_) => MenuBloc(ids),
                                child: MenuScreen.fromTableIds(
                                  tableIds: ids,
                                  tableName: tableNumbers,
                                ),
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

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 40,
      backgroundColor: Colors.transparent,
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
          onTap: () => context.read<TableBloc>().add(LoadTables()),
        ),
        _AppBarIcon(
          icon: _isMergeMode ? Icons.close_rounded : Icons.merge_type_rounded,
          onTap: _toggleMergeMode,
        ),
        _AppBarIcon(
          icon: Icons.list_alt_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => MenuBloc([])..add(LoadAllOrders()),
                  child: const AllOrdersScreen(),
                ),
              ),
            );
          },
        ),

        /// ✅ MERGE CONFIRM (FIXED)
      if (_isMergeMode)
  BlocBuilder<TableBloc, TableState>(
    buildWhen: (prev, curr) => prev.tables != curr.tables,
    builder: (context, state) {
      if (state.tables.isEmpty) {
        return const SizedBox.shrink();
      }

      // build ID → tableNumber map HERE
      final Map<int, String> idToTableNumber = {
        for (final t in state.tables) t.id: t.tableNumber,
      };

      return _AppBarIcon(
        icon: Icons.check_circle_rounded,
        color: Colors.greenAccent,
        onTap: _selected.isNotEmpty
            ? () {
                final ids = _selected.toList();

                final tableNumbers = ids
                    .map(
                      (id) => idToTableNumber[id] ?? id.toString(),
                    )
                    .toList();

                // 1️⃣ merge API
                context
                    .read<TableBloc>()
                    .add(MergeTables(tableIds: ids));

                // 2️⃣ exit merge mode
                setState(() => _mergeMode = false);

                // 3️⃣ navigate to menu
                Navigator.push(
                  context,
                  AnimatedPageRoute(
                    page: BlocProvider(
                      create: (_) => MenuBloc(ids),
                      child: MenuScreen.fromTableIds(
                        tableIds: ids,
                        tableName: tableNumbers,
                      ),
                    ),
                  ),
                ).then((_) {
                  setState(() {
                    _selected.clear();
                  });
                });
              }
            : null,
      );
    },
  ),

          // _AppBarIcon(
          //   icon: Icons.check_circle_rounded,
          //   color: Colors.greenAccent,
          //   onTap: _selected.isNotEmpty
          //       ? () {
          //           final ids = _selected.toList();

          //           // 1️⃣ merge API
          //           context.read<TableBloc>().add(MergeTables(tableIds: ids));

          //           // 2️⃣ exit merge mode
          //           setState(() => _mergeMode = false);

                    
                    
          //           // 3️⃣ navigate to menu
          //           Navigator.push(
          //             context,
          //             AnimatedPageRoute(
          //               page: BlocProvider(
          //                 create: (_) => MenuBloc(ids),
          //                 child: MenuScreen.fromTableIds(tableIds: ids,tableName: ,),
          //               ),
          //             ),
          //           ).then((_) {
          //             // 4️⃣ clear selection on return
          //             setState(() {
          //               _selected.clear();
          //             });
          //           });
          //         }
          //       : null,
          // ),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/asmaraOuter.jpeg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
        ),
      ),
    );
  }
}

// ================= TABLE CARD (UNCHANGED UI) =================

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blueAccent.withOpacity(0.7)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          width: isSelected ? 3 : 0,
        ),
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
          const Icon(Icons.table_restaurant, size: 34),
          Text(
            mergedLabel != null
                ? 'Table ${table.tableNumber} ($mergedLabel)'
                : 'Table ${table.tableNumber}',
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
        case 'order Ongoing':
        return Colors.purple;
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
