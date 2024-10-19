import 'package:test/test.dart';
import '../lib/rule_parser.dart';
import '../lib/ast_node.dart';

void main() {
  group('Rule Engine Tests', () {
    test('Evaluate rule with TestData1', () {
      var parser = RuleParser();
      var ruleString = "((age > 30 AND department = 'Sales') OR (age < 25 AND department = 'Marketing')) AND (salary > 50000 OR experience > 5)";
      var ast = parser.parse(ruleString);

      var testData1 = {'age': 35, 'department': 'Sales', 'salary': 60000, 'experience': 3};

      // Check if AST is not null before evaluation
      if (ast != null) {
        expect(ast.evaluate(testData1), isTrue, reason: "TestData1 should pass the rule conditions.");
      } else {
        fail("AST was not created successfully.");
      }
    });

    test('Evaluate rule with TestData2', () {
      var parser = RuleParser();
      var ruleString = "((age > 30 AND department = 'Sales') OR (age < 25 AND department = 'Marketing')) AND (salary > 50000 OR experience > 5)";
      var ast = parser.parse(ruleString);

      var testData2 = {'age': 24, 'department': 'Marketing', 'salary': 45000, 'experience': 6};

      // Check if AST is not null before evaluation
      if (ast != null) {
        expect(ast.evaluate(testData2), isFalse, reason: "TestData2 should fail the rule conditions.");
      } else {
        fail("AST was not created successfully.");
      }
    });

    test('Dynamic combination of rules', () {
      var parser = RuleParser();
      var rules = [
        "age > 30 AND department = 'Sales'",
        "salary > 50000 OR experience > 5",
        "department = 'Marketing' AND experience < 3"
      ];

      var asts = rules.map(parser.parse).toList();
      // Ensure all ASTs are not null before combining
      if (asts.any((ast) => ast == null)) {
        fail("One or more ASTs were not created successfully.");
      } else {
        var combinedAST = asts.reduce((result, element) => Node.combine(result, element, 'AND'));

        var testData = {'age': 31, 'department': 'Sales', 'salary': 51000, 'experience': 2};

        expect(combinedAST.evaluate(testData), isTrue, reason: "Combined rules should evaluate to true for given testData.");
      }
    });
  });
}
