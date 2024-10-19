// lib/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'node.dart';
import 'dart:convert';

class FirebaseService {
  final CollectionReference rulesCollection =
  FirebaseFirestore.instance.collection('rules');

  // Save a rule to Firestore
  Future<void> saveRule({
    required String combinedRuleString,
    required String astJsonString,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await rulesCollection.add({
        'ruleString': combinedRuleString,
        'ast': astJsonString,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      });
    } catch (e) {
      print('Error saving rule: $e');
      throw e;
    }
  }

  // Update an existing rule
  Future<void> updateRule({
    required String docId,
    required String updatedRuleString,
    required String updatedAstJsonString,
  }) async {
    try {
      await rulesCollection.doc(docId).update({
        'ruleString': updatedRuleString,
        'ast': updatedAstJsonString,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating rule: $e');
      throw e;
    }
  }

  // Retrieve all rule documents from Firestore
  Future<List<Map<String, dynamic>>> getAllRuleDocuments() async {
    QuerySnapshot snapshot = await rulesCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return {
        'docId': doc.id,
        'ruleString': data?['ruleString'] ?? '',
        'ast': data?['ast'],
        'metadata': data?['metadata'],
        'timestamp': data?['timestamp'],
      };
    }).toList();
  }

  // Retrieve all rule nodes (ASTs) from Firestore
  Future<List<Node>> getAllRuleNodes() async {
    QuerySnapshot snapshot = await rulesCollection.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('ast')) {
        String astJsonString = data['ast'] as String;
        Map<String, dynamic> astData = jsonDecode(astJsonString);
        return Node.fromJson(astData);
      } else {
        // Handle the case where 'ast' field is missing or data is null
        print('Document ${doc.id} is missing "ast" field or data is null.');
        return null;
      }
    }).whereType<Node>().toList(); // Filters out null values and casts to List<Node>
  }

  // Delete a rule by document ID
  Future<void> deleteRule(String docId) async {
    await rulesCollection.doc(docId).delete();
  }
}
