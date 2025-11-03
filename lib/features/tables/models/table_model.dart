class TableModel {
  final int id;         // table number (1,2,3…)
  final String name;    // table ka naam
  final String status;  // free / reserved / occupied
  final List<int>? mergedWith; // optional: ids when this table is merged (keeps group on each member)

  TableModel({
    required this.id,
    required this.name,
    this.status = "free",
    this.mergedWith,
  });

  TableModel copyWith({
    int? id,
    String? name,
    String? status,
    List<int>? mergedWith,
  }) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      mergedWith: mergedWith ?? this.mergedWith,
    );
  }
}
