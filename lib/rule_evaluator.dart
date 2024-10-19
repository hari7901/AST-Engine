// lib/rule_evaluator.dart

import 'node.dart';

bool evaluate_rule(Node ast, Map<String, dynamic> data) {
  if (ast.type == 'operator') {
    bool left = evaluate_rule(ast.left!, data);
    bool right = evaluate_rule(ast.right!, data);
    if (ast.value == 'AND') {
      return left && right;
    } else if (ast.value == 'OR') {
      return left || right;
    } else {
      throw Exception('Unknown operator: ${ast.value}');
    }
  } else if (ast.type == 'operand') {
    String attribute = ast.value!['attribute'];
    String operator = ast.value!['operator'];
    dynamic value = ast.value!['value'];

    if (!data.containsKey(attribute)) {
      throw Exception('Data does not contain attribute: $attribute');
    }

    dynamic dataValue = data[attribute];

    switch (operator) {
      case '==':
        return dataValue == value;
      case '!=':
        return dataValue != value;
      case '>':
        return dataValue > value;
      case '<':
        return dataValue < value;
      case '>=':
        return dataValue >= value;
      case '<=':
        return dataValue <= value;
      default:
        throw Exception('Unknown operator: $operator');
    }
  } else {
    throw Exception('Unknown node type: ${ast.type}');
  }
}
