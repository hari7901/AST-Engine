# Overview:-

This application is a simple 3-tier rule engine designed to determine user eligibility based on various attributes like age, department, income, and spend. The system uses an Abstract Syntax Tree (AST) to represent conditional rules dynamically, allowing for the creation, combination, and modification of these rules.

# Features:-

Rule Creation: Dynamically create rules which are transformed into an AST.
Rule Combination: Combine multiple rules into a single AST to evaluate complex conditions.
Rule Evaluation: Evaluate combined rules against user data to determine eligibility.
Dynamic Rule Modification: Support for dynamic changes in the rule's structure and criteria.

# Design Choices:-

AST Representation: Chose to represent rules as ASTs for flexibility in evaluating expressions and ease of integration.
Firebase Firestore: Selected for its real-time data handling, scalability, and ease of setup for storing rules and application metadata.
3-tier Architecture: Ensures separation of concerns, facilitating easier maintenance and scalability.

# Setup and Installation
To get this project up and running on your local machine, follow these steps:

# Prerequisites
Flutter installed on your machine
Firebase project setup

# Clone the repository
git clone https://github.com/yourusername/yourrepositoryname.git

# Navigate into the project directory
cd yourrepositoryname

# Install dependencies
flutter pub get

# Setup Firebase
 Follow Firebase documentation to connect your Flutter app to your Firebase project

# Run the application
flutter run

# Build for Android
flutter build apk

# API Design:-

create_rule(String ruleString): Parses a string representing a rule into an AST.
combine_rules(List<String> rules): Combines multiple rule strings into a single AST.
evaluate_rule(Map<String, dynamic> data): Evaluates the rule against provided JSON data.

# Data Storage:-

Firebase Firestore is used to store rules and their corresponding ASTs. Rules are stored with the following schema:

Rule String: The original string format of the rule.
AST: JSON representation of the rule's AST.
Metadata: Additional information like creation timestamps

# Test Cases:-

1) Combine rules and ensure the resulting AST reflects the logic.
2) Test rule evaluation with various JSON data inputs.
3) Dynamic rule modifications and their impact on evaluations.

# Bonus Features:-

1) Error Handling: Implemented robust error handling for syntax errors in rule strings and data format issues.
2) Attribute Validations: Ensured that all attributes used in rules are validated against a predefined catalog.
3) Rule Modification: Provided functionalities to modify existing rules dynamically.
