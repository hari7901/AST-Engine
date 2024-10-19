import 'package:flutter/material.dart';
import 'dart:convert';
import 'node.dart';
import 'rule_parser.dart';
import 'rule_evaluator.dart';
import 'firebase_service.dart';
import 'rule_list_screen.dart';

class TestScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onUserDataChanged;

  TestScreen({required this.userData, required this.onUserDataChanged});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // Controllers and state for user-inputted rules
  List<TextEditingController> _ruleControllers = [TextEditingController()];
  List<String> _operators = []; // Operators between user-inputted rules

  // Combined rule information
  Node? combinedAst;
  String? combinedAstJson;
  String? combinedRuleString;
  bool? evaluationResult;
  String? errorMessage;

  final FirebaseService _firebaseService = FirebaseService();

  // State variables for stored rules
  List<Map<String, dynamic>> _storedRules = [];
  Set<String> _selectedStoredRuleIds = {};
  bool _isStoredRulesLoading = true;
  String? _storedRulesError;

  // Operator between user-inputted rules and stored rules
  String _storedRulesOperator = 'AND';

  @override
  void initState() {
    super.initState();
    _fetchStoredRules(); // Fetch stored rules when the screen initializes
  }

  @override
  void dispose() {
    for (var controller in _ruleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Fetches all stored rules from Firebase and updates the state.
  Future<void> _fetchStoredRules() async {
    setState(() {
      _isStoredRulesLoading = true;
      _storedRulesError = null;
    });

    try {
      List<Map<String, dynamic>> rules = await _firebaseService.getAllRuleDocuments();
      setState(() {
        _storedRules = rules;
        _isStoredRulesLoading = false;
      });
    } catch (e) {
      setState(() {
        _storedRulesError = 'Error fetching stored rules: $e';
        _isStoredRulesLoading = false;
      });
    }
  }

  /// Adds a new rule input field.
  void _addRuleField() {
    setState(() {
      _ruleControllers.add(TextEditingController());
      // Default operator between rules is 'AND'
      if (_ruleControllers.length > 1) {
        _operators.add('AND');
      }
    });
  }

  /// Removes a rule input field at the specified index.
  void _removeRuleField(int index) {
    setState(() {
      if (_ruleControllers.length > 1) {
        _ruleControllers[index].dispose();
        _ruleControllers.removeAt(index);
        if (index > 0) {
          _operators.removeAt(index - 1);
        }
      }
    });
  }

  /// Combines user-inputted rules and selected stored rules, evaluates them, and saves the combined rule.
  Future<void> _combineAndEvaluateRules() async {
    setState(() {
      combinedAst = null;
      combinedAstJson = null;
      combinedRuleString = null;
      evaluationResult = null;
      errorMessage = null;
    });

    List<Node> ruleAsts = [];
    List<String> ruleStrings = [];

    try {
      // 1. Parse user-inputted rules
      for (int i = 0; i < _ruleControllers.length; i++) {
        String ruleInput = _ruleControllers[i].text.trim();
        if (ruleInput.isEmpty) {
          setState(() {
            errorMessage = 'Rule ${i + 1} is empty.';
          });
          return;
        }
        try {
          Node ast = create_rule(ruleInput);
          ruleAsts.add(ast);
          ruleStrings.add('($ruleInput)');
        } catch (e) {
          setState(() {
            errorMessage = 'Error in Rule ${i + 1}: $e';
          });
          return;
        }
      }

      // 2. Include selected stored rules
      if (_selectedStoredRuleIds.isNotEmpty) {
        // Filter the stored rules based on selected IDs
        List<Map<String, dynamic>> selectedRules = _storedRules
            .where((rule) => _selectedStoredRuleIds.contains(rule['docId']))
            .toList();

        // Parse each selected stored rule
        List<Node> storedRuleAsts = [];
        List<String> storedRuleStrings = [];
        for (int i = 0; i < selectedRules.length; i++) {
          Map<String, dynamic> rule = selectedRules[i];
          String ruleString = rule['ruleString'];
          String? astJsonString = rule['ast'];

          if (astJsonString == null) {
            setState(() {
              errorMessage = 'Stored rule "${ruleString}" is missing AST.';
            });
            return;
          }

          try {
            // Parse the AST from the JSON string
            Map<String, dynamic> astData = jsonDecode(astJsonString);
            Node ast = Node.fromJson(astData);
            storedRuleAsts.add(ast);
            storedRuleStrings.add('($ruleString)');
          } catch (e) {
            setState(() {
              errorMessage = 'Error parsing stored rule "${ruleString}": $e';
            });
            return;
          }
        }

        // Combine stored rules into a single AST based on the selected operator
        Node combinedStoredRulesAst = storedRuleAsts[0];
        String combinedStoredRulesString = storedRuleStrings[0];

        for (int i = 1; i < storedRuleAsts.length; i++) {
          String operator = _storedRulesOperator;
          combinedStoredRulesAst = Node(
            type: 'operator',
            value: operator,
            left: combinedStoredRulesAst,
            right: storedRuleAsts[i],
          );
          combinedStoredRulesString = '($combinedStoredRulesString $operator ${storedRuleStrings[i]})';
        }

        // If there are existing user-inputted rules, combine them with stored rules
        if (ruleAsts.isNotEmpty) {
          String operator = _storedRulesOperator;
          Node combined = Node(
            type: 'operator',
            value: operator,
            left: ruleAsts.isNotEmpty ? ruleAsts[0] : null,
            right: combinedStoredRulesAst,
          );

          // Generate the combined rule string
          String combinedRule = '(${ruleStrings.join(' AND ')}) $operator ($combinedStoredRulesString)';

          // Generate the combined AST JSON string
          var encoder = JsonEncoder.withIndent('  ');
          String combinedAstString = encoder.convert(combined.toJson());

          // Evaluate the combined rule against the user data
          bool result = evaluate_rule(combined, widget.userData);

          // Save the combined rule to Firebase
          await _firebaseService.saveRule(
            combinedRuleString: combinedRule,
            astJsonString: combinedAstString,
          );

          // Update the UI with the results
          setState(() {
            combinedAst = combined;
            combinedAstJson = combinedAstString;
            combinedRuleString = combinedRule;
            evaluationResult = result;
          });

          return;
        }

        // If there are no user-inputted rules, just use the combined stored rules
        if (storedRuleAsts.isNotEmpty) {
          Node combined = storedRuleAsts[0];
          String combinedRule = storedRuleStrings[0];

          for (int i = 1; i < storedRuleAsts.length; i++) {
            String operator = _storedRulesOperator;
            combined = Node(
              type: 'operator',
              value: operator,
              left: combined,
              right: storedRuleAsts[i],
            );
            combinedRule = '($combinedRule $operator ${storedRuleStrings[i]})';
          }

          // Generate the combined AST JSON string
          var encoder = JsonEncoder.withIndent('  ');
          String combinedAstString = encoder.convert(combined.toJson());

          // Evaluate the combined rule against the user data
          bool result = evaluate_rule(combined, widget.userData);

          // Save the combined rule to Firebase
          await _firebaseService.saveRule(
            combinedRuleString: combinedRule,
            astJsonString: combinedAstString,
          );

          // Update the UI with the results
          setState(() {
            combinedAst = combined;
            combinedAstJson = combinedAstString;
            combinedRuleString = combinedRule;
            evaluationResult = result;
          });
        }
      }

      if (ruleAsts.isEmpty) {
        setState(() {
          errorMessage = 'No rules to combine.';
        });
        return;
      }

      // 3. Combine all rules using the specified operators
      Node combined = ruleAsts[0];
      String combinedRule = ruleStrings[0];

      for (int i = 1; i < ruleAsts.length; i++) {
        String operator = _operators.length >= i ? _operators[i - 1] : 'AND'; // Default to 'AND' if not enough operators
        combined = Node(
          type: 'operator',
          value: operator,
          left: combined,
          right: ruleAsts[i],
        );
        // Update the combined rule string
        combinedRule = '($combinedRule $operator ${ruleStrings[i]})';
      }

      // 4. Generate the combined AST JSON string
      var encoder = JsonEncoder.withIndent('  ');
      String combinedAstString = encoder.convert(combined.toJson());

      // 5. Evaluate the combined rule against the user data
      bool result = evaluate_rule(combined, widget.userData);

      // 6. Save the combined rule to Firebase
      await _firebaseService.saveRule(
        combinedRuleString: combinedRule,
        astJsonString: combinedAstString,
      );

      // 7. Update the UI with the results
      setState(() {
        combinedAst = combined;
        combinedAstJson = combinedAstString;
        combinedRuleString = combinedRule;
        evaluationResult = result;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error combining or evaluating rules: $e';
      });
    }
  }

  /// Opens a dialog to edit the user data.
  void _editUserData() async {
    var encoder = JsonEncoder.withIndent('  ');
    String userDataJson = encoder.convert(widget.userData);
    TextEditingController _userDataController =
    TextEditingController(text: userDataJson);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User Data'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _userDataController,
              decoration: InputDecoration(
                hintText: 'Enter user data in JSON format',
              ),
              maxLines: null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validate and update the user data
                try {
                  Map<String, dynamic> updatedData =
                  jsonDecode(_userDataController.text);
                  Navigator.of(context).pop(); // Close the dialog
                  setState(() {
                    widget.userData.clear();
                    widget.userData.addAll(updatedData);
                    widget.onUserDataChanged(widget.userData); // Notify main app
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid JSON data: $e')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Navigates to the RuleListScreen to view all saved rules.
  void _navigateToRuleListScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RuleListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var encoder = JsonEncoder.withIndent('  ');
    String userDataJson = encoder.convert(widget.userData);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('AST Engine')),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Display the user data
              ExpansionTile(
                title: Text('User Data'),
                initiallyExpanded: false,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      userDataJson,
                      style: TextStyle(fontFamily: 'Courier'),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _editUserData,
                    child: Text('Edit User Data'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 2. Dynamic list of rule input fields for new rules
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _ruleControllers.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      if (index > 0)
                      // Operator selector between rules
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<String>(
                              value: _operators.length >= index
                                  ? _operators[index - 1]
                                  : 'AND',
                              items: ['AND', 'OR'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  if (newValue != null) {
                                    if (_operators.length >= index) {
                                      _operators[index - 1] = newValue;
                                    } else {
                                      _operators.add(newValue);
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ruleControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Enter Rule ${index + 1}',
                                hintText:
                                "e.g., age > 30 AND department == 'Sales'",
                              ),
                              maxLines: null,
                            ),
                          ),
                          if (_ruleControllers.length > 1)
                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () => _removeRuleField(index),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addRuleField,
                child: Text('Add Another Rule'),
              ),
              SizedBox(height: 20),
              // 3. Operator selector between user-inputted rules and stored rules
              if (_storedRules.isNotEmpty)
                Row(
                  children: [
                    Text(
                      'Combine with stored rules using:',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _storedRulesOperator,
                      items: ['AND', 'OR'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            _storedRulesOperator = newValue;
                          }
                        });
                      },
                    ),
                  ],
                ),
              SizedBox(height: 10),
              // 4. Section for selecting existing stored rules
              ExpansionTile(
                title: Text('Select Existing Rules'),
                initiallyExpanded: false,
                children: [
                  if (_isStoredRulesLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_storedRulesError != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _storedRulesError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  else if (_storedRules.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No stored rules available.'),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _storedRules.length,
                        itemBuilder: (context, index) {
                          final rule = _storedRules[index];
                          return CheckboxListTile(
                            title: Text(rule['ruleString']),
                            value: _selectedStoredRuleIds.contains(rule['docId']),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedStoredRuleIds.add(rule['docId']);
                                } else {
                                  _selectedStoredRuleIds.remove(rule['docId']);
                                }
                              });
                            },
                          );
                        },
                      ),
                  SizedBox(height: 10),
                  // Optional: Button to refresh stored rules
                  TextButton(
                    onPressed: _fetchStoredRules,
                    child: Text('Refresh Stored Rules'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 5. Button to combine, evaluate, and save rules
              ElevatedButton(
                onPressed: _combineAndEvaluateRules,
                child: Text('Combine Rules, Evaluate, and Save'),
              ),
              SizedBox(height: 20),
              // 6. Display error messages if any
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              // 7. Display the combined rule string
              if (combinedRuleString != null)
                ExpansionTile(
                  title: Text('Combined Rule String'),
                  initiallyExpanded: false,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        combinedRuleString!,
                        style: TextStyle(fontFamily: 'Courier'),
                      ),
                    ),
                  ],
                ),
              // 8. Display the combined AST JSON
              if (combinedAstJson != null)
                ExpansionTile(
                  title: Text('Combined Rules AST'),
                  initiallyExpanded: false,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        combinedAstJson!,
                        style: TextStyle(fontFamily: 'Courier'),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              // 9. Display the evaluation result
              if (evaluationResult != null)
                Text(
                  'Evaluation Result: ${evaluationResult! ? 'True' : 'False'}',
                  style: TextStyle(
                      color: evaluationResult! ? Colors.green : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 20),
              // 10. Button to navigate to the RuleListScreen
              ElevatedButton(
                onPressed: _navigateToRuleListScreen,
                child: Text('View Saved Rules'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
