import 'package:test/test.dart';
import '../lib/rule_parser.dart';

void main() {
  test('Create and verify ASTs from rule strings', () {
    var parser = RuleParser();
    var ruleString1 = "age > 30 AND department = 'Sales'";
    var ruleString2 = "age < 25 AND department = 'Marketing'";

    var ast1 = parser.parse(ruleString1);
    var ast2 = parser.parse(ruleString2);

    // Ensure ASTs are not null before verification
    if (ast1 == null) {
      fail("Failed to create AST for Rule 1");
    } else {
      // Check if the AST is correctly structured for Rule 1
      expect(ast1.type, equals('operator'));
      expect(ast1.value, contains('AND'));
      expect(ast1.left.toString(), contains('age > 30'));
      expect(ast1.right.toString(), contains("department = 'Sales'"));
    }

    if (ast2 == null) {
      fail("Failed to create AST for Rule 2");
    } else {
      // Check if the AST is correctly structured for Rule 2
      expect(ast2.type, equals('operator'));
      expect(ast2.value, contains('AND'));
      expect(ast2.left.toString(), contains('age < 25'));
      expect(ast2.right.toString(), contains("department = 'Marketing'"));
    }

    // Optionally print the AST structures for visual verification during development or debugging
    print('AST for Rule 1: $ast1');
    print('AST for Rule 2: $ast2');
  });
}
