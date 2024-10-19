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

Firebase Setup Options:-

This project uses Firebase as its backend. There are two ways you can access the Firebase backend for testing and development purposes: Direct Access to my Firebase project or Setting Up Your Own Firebase Project.

# Option 1: Direct Access to Firebase Project
If you have been granted direct access to the Firebase project, here’s how to get started:

# Steps to Access Firebase:
Receive Invitation: Check your email associated with Firebase for an invitation to access the project.
Accept Invitation: Follow the link in the invitation to accept access.
Navigate to Firebase Console: Go to the Firebase Console and select the shared project.
Roles and Permissions:

Depending on the role assigned (Viewer, Editor, Owner), you will have different levels of access to the project resources.
Security Note: Ensure you understand the access level granted and avoid making changes that could affect the application’s production environment.

# Option 2: Setting Up Your Own Firebase Project
For setting up your own Firebase environment, follow these detailed steps:

1) Create a Firebase Project:

Go to the Firebase Console.
Click on "Add project" and follow the instructions.

2) Register the Application:

Click on the platform you are developing for (Web, Android, iOS).
Follow the steps to register your application and note your app's Firebase configuration

3) Download Firebase Configuration:

Android: Download google-services.json and place it into the app/ directory.

# Enable Firebase Services:
Firestore Database: Set up Firestore in test mode or production mode depending on your needs.

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
