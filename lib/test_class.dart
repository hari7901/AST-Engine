// lib/test_result.dart

class TestResult {
  final String testName;
  final String description;
  final bool passed;
  final String details;

  TestResult({
    required this.testName,
    required this.description,
    required this.passed,
    required this.details,
  });
}
