class TableModel {
  final int id;         // table number (1,2,3…)
  final String name;    // table ka naam
  final String status;  // free / reserved / occupied

  TableModel({
    required this.id,
    required this.name,
    this.status = "free",
  });
}
