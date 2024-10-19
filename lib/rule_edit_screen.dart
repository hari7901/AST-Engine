// lib/rule_edit_screen.dart

import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'node.dart';
import 'rule_parser.dart';
import 'dart:convert';

class RuleEditScreen extends StatefulWidget {
  final String ruleString;
  final String docId;

  RuleEditScreen({required this.ruleString, required this.docId});

  @override
  _RuleEditScreenState createState() => _RuleEditScreenState();
}

class _RuleEditScreenState extends State<RuleEditScreen> {
  final TextEditingController _ruleController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _ruleController.text = widget.ruleString;
  }

  Future<void> _saveRule() async {
    String ruleInput = _ruleController.text.trim();
    if (ruleInput.isEmpty) {
      setState(() {
        errorMessage = 'Rule cannot be empty.';
      });
      return;
    }

    try {
      Node ast = create_rule(ruleInput);

      var encoder = JsonEncoder.withIndent('  ');
      String astJsonString = encoder.convert(ast.toJson());

      await _firebaseService.updateRule(
        docId: widget.docId,
        updatedRuleString: ruleInput,
        updatedAstJsonString: astJsonString,
      );

      Navigator.pop(context, ruleInput);
    } catch (e) {
      setState(() {
        errorMessage = 'Error parsing rule: $e';
      });
    }
  }

  @override
  void dispose() {
    _ruleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Rule'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ruleController,
              decoration: InputDecoration(
                labelText: 'Rule',
                hintText: "e.g., age > 30 AND department == 'Sales'",
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            Spacer(),
            ElevatedButton(
              onPressed: _saveRule,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
