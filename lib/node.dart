// lib/node.dart

class Node {
  String type; // 'operator' or 'operand'
  dynamic value;
  Node? left;
  Node? right;

  Node({required this.type, this.value, this.left, this.right});

  // Method to convert Node to JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {'type': type};
    if (value != null) json['value'] = value;
    if (left != null) json['left'] = left!.toJson();
    if (right != null) json['right'] = right!.toJson();
    return json;
  }

  // Method to create Node from JSON
  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      type: json['type'],
      value: json['value'],
      left: json['left'] != null ? Node.fromJson(json['left']) : null,
      right: json['right'] != null ? Node.fromJson(json['right']) : null,
    );
  }
}
