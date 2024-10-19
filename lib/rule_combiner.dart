// rule_combiner.dart

import 'node.dart';
import 'firebase_service.dart';

Node combine_rules_from_list(List<Node> ruleNodes) {
  if (ruleNodes.isEmpty) {
    throw ArgumentError('No rules provided.');
  }

  Node root = ruleNodes[0];

  for (int i = 1; i < ruleNodes.length; i++) {
    root = Node(
      type: 'operator',
      value: 'OR',
      left: root,
      right: ruleNodes[i],
    );
  }

  return root;
}

Future<Node> combine_rules() async {
  FirebaseService firebaseService = FirebaseService();
  List<Node> ruleNodes = await firebaseService.getAllRuleNodes(); // Updated method name

  if (ruleNodes.isEmpty) {
    // Return a default node that always evaluates to false
    return Node(
      type: 'operand',
      value: {
        'attribute': 'default',
        'operator': '==',
        'value': 'default',
      },
    );
  }

  // Combine nodes using OR operator
  Node root = ruleNodes[0];

  for (int i = 1; i < ruleNodes.length; i++) {
    root = Node(
      type: 'operator',
      value: 'OR',
      left: root,
      right: ruleNodes[i],
    );
  }

  return root;
}
