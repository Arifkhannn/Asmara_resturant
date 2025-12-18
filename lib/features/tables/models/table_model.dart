class TableModel {
  final int id;               // table id
  final String name;          // table number/name
  final String status;        // free / reserved / occupied
  final List<int>? mergedWith; // optional

  TableModel({
    required this.id,
    required this.name,
    required this.status ,
    this.mergedWith,
  });

  // ✅ Convert JSON → TableModel
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] ?? 0,
      name: json['table_number']?.toString() ?? json['name'] ?? '',
      status: json['status'] ?? 'free',
      mergedWith: (json['merged_with'] != null)
          ? List<int>.from(json['merged_with'])
          : null,
    );
  }

  // ✅ Convert TableModel → JSON (if you ever need to send data back)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': name,
      'status': status,
      if (mergedWith != null) 'merged_with': mergedWith,
    };
  }

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
