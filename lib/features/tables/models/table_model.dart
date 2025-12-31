class TableModel {
  final int id;
  final String tableNumber;
  final String status;
  final List<int> mergedWith;

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.mergedWith,
  });

  bool get isMerged => mergedWith.length > 1;

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      tableNumber: json['table_number'].toString(),
      status: json['status'] ?? 'free',
      mergedWith: json['merged_with'] != null
          ? List<int>.from(json['merged_with'])
          : [json['id']], // fallback safety
    );
  }


  
TableModel copyWith({
    int? id,
    String? tableNumber,
    String? status,
    List<int>? mergedWith,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      mergedWith: mergedWith ?? this.mergedWith,
    );
  }
}

