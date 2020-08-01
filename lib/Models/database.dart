import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'GoalEntry.dart';
import 'InputEntry.dart';
import 'category.dart';

class DatabaseService {

  DatabaseService._();
  final String _inputEntries = 'inputEntries';
  final String _goalEntries = 'goalEntries';
  final String _categories = 'categories';

  static final DatabaseService instance = DatabaseService._();

  Stream<List<InputEntry>> inputEntriesStream(FirebaseUser user) {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_inputEntries);

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => InputEntry.fromMap(doc.data, doc.documentID)).toList());
  }

  Stream<List<GoalEntry>> goalEntriesStream(FirebaseUser user) {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_goalEntries);

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => GoalEntry.fromMap(doc.data, doc.documentID)).toList());
  }

  Stream<List<Category>> categoriesStream(FirebaseUser user) {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_categories);

    return ref.snapshots().map((list) =>
        list.documents.map((doc) => Category.fromMap(doc.data, doc.documentID)).toList());
  }

  Future<bool> addInputEntry(FirebaseUser user, InputEntry inputEntry) async {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_inputEntries);
    try {
      await ref.add(inputEntry.toMap());
      return true;
    } catch(e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> addGoalEntry(FirebaseUser user, GoalEntry goalEntry) async {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_goalEntries);
    try {
      await ref.add(goalEntry.toMap());
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<bool> addCategory(FirebaseUser user, Category category) async {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_categories);
    if(await ref.where(category.name).snapshots().isEmpty) {
      try {
        await ref.add(category.toMap());
        return true;
      } catch(e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> deleteInputEntry(FirebaseUser user, InputEntry inputEntry) async {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_inputEntries);
    try {
      await ref.document(inputEntry.docID).delete();
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<bool> deleteGoalEntry(FirebaseUser user, GoalEntry goalEntry) async {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_goalEntries);
    try {
      await ref.document(goalEntry.docID).delete();
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<bool> deleteCategory(FirebaseUser user, Category category) async {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_categories);
    try {
      await ref.document(category.docID).delete();
      return true;
    } catch(e) {
      return false;
    }
  }
}