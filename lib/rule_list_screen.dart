// lib/rule_list_screen.dart

import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'rule_edit_screen.dart';

class RuleListScreen extends StatefulWidget {
  @override
  _RuleListScreenState createState() => _RuleListScreenState();
}

class _RuleListScreenState extends State<RuleListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRules();
  }

  Future<void> _fetchRules() async {
    try {
      List<Map<String, dynamic>> rules =
      await _firebaseService.getAllRuleDocuments();
      setState(() {
        _rules = rules;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching rules: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRule(String docId) async {
    try {
      await _firebaseService.deleteRule(docId);
      _fetchRules(); // Refresh the list after deletion
    } catch (e) {
      print('Error deleting rule: $e');
    }
  }

  void _editRule(Map<String, dynamic> rule) async {
    String? updatedRuleString = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RuleEditScreen(
          ruleString: rule['ruleString'],
          docId: rule['docId'],
        ),
      ),
    );

    if (updatedRuleString != null) {
      _fetchRules(); // Refresh the list after editing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Rules'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _rules.isEmpty
          ? Center(child: Text('No rules found.'))
          : ListView.builder(
        itemCount: _rules.length,
        itemBuilder: (context, index) {
          final rule = _rules[index];
          return ListTile(
            title: Text(rule['ruleString']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editRule(rule),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteRule(rule['docId']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
