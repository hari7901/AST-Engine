import 'package:test/test.dart';
import '../lib/rule_parser.dart';
import '../lib/ast_node.dart';

void main() {
  test('Combine Rules Test', () {
    var parser = RuleParser();
    var rule1 = "age > 30 AND department = 'Sales'";
    var rule2 = "salary > 50000 OR experience > 5";

    var ast1 = parser.parse(rule1);
    var ast2 = parser.parse(rule2);

    // Ensure both ASTs are not null before combining
    if (ast1 != null && ast2 != null) {
      var combinedAST = Node.combine(ast1, ast2, 'AND');

      // Check if the combined AST is correctly structured
      expect(combinedAST.type, equals('operator'));
      expect(combinedAST.value, equals('AND'));
      expect(combinedAST.left.toString(), equals(ast1.toString()));
      expect(combinedAST.right.toString(), equals(ast2.toString()));

      // Output the structure of the combined AST
      print('Combined AST: $combinedAST');
    } else {
      fail("One or more ASTs were not created successfully. AST1: $ast1, AST2: $ast2");
    }
  });
}
