import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miatracker/Models/Entry.dart';
import '../Map.dart';
import 'GoalEntry.dart';
import 'InputEntry.dart';
import 'category.dart';

class DatabaseService {

  DatabaseService._();
  final String _inputEntries = 'inputEntries';
  final String _goalEntries = 'goalEntries';
  final String _categories = 'categories';

  Map<DateTime, List<Entry>> _entries = Map<DateTime, List<Entry>>();

  static final DatabaseService instance = DatabaseService._();

  Stream<List<InputEntry>> inputEntriesStream(FirebaseUser user, {Category category, DateTime startDate, DateTime endDate}) {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_inputEntries);
    
    if(startDate == null && endDate == null && category == null) {
      return ref.snapshots().map((list) =>
          list.documents.map((doc) => InputEntry.fromMap(doc.data, doc.documentID)).toList());
    } else if(startDate == null && endDate == null) {
      return ref.where('category', isEqualTo: category.name).snapshots().map((list) =>
          list.documents.map((doc) => InputEntry.fromMap(doc.data, doc.documentID)).toList());
    }
    startDate ??= DateTime.now();
    endDate ??= daysAgo(-1, DateTime.now());

    return ref.where('category', isEqualTo: category.name)
       .where('dateTime', isGreaterThanOrEqualTo: startDate)
       .where('dateTime', isLessThan: endDate).snapshots().map((list) =>
        list.documents.map((doc) => InputEntry.fromMap(doc.data, doc.documentID)).toList());
    
  }

  Stream<List<GoalEntry>> goalEntriesStream(FirebaseUser user, {Category category, DateTime startDate, DateTime endDate}) {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_goalEntries);

    if(startDate == null && endDate == null && category == null) {
      return ref.snapshots().map((list) =>
          list.documents.map((doc) => GoalEntry.fromMap(doc.data, doc.documentID)).toList());
    } else if(startDate == null && endDate == null) {
      return ref.where('category', isEqualTo: category.name).snapshots().map((list) =>
          list.documents.map((doc) => GoalEntry.fromMap(doc.data, doc.documentID)).toList());
    }
    startDate ??= DateTime.now();
    endDate ??= daysAgo(-1, DateTime.now());

    return ref.where('category', isEqualTo: category.name)
        .where('dateTime', isGreaterThanOrEqualTo: startDate)
        .where('dateTime', isLessThan: endDate).snapshots().map((list) =>
        list.documents.map((doc) => GoalEntry.fromMap(doc.data, doc.documentID)).toList());

  }

  Stream<GoalEntry> lastGoalEntry(FirebaseUser user, Category category) {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_goalEntries);

    return ref.where('inputType',isEqualTo: category.name).orderBy('dateTime', descending: true).limit(1).snapshots().map((list) =>
        list.documents.map((doc) => GoalEntry.fromMap(doc.data, doc.documentID)).first);
  }

  Stream<List<Category>> categoriesStream(FirebaseUser user) {
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_categories);

    return ref.orderBy('dateTime').snapshots().map((list) =>
        list.documents.map((doc) => Category.fromMap(doc.data, doc.documentID)).toList());
  }

  Future<bool> addInputEntry(FirebaseUser user, InputEntry inputEntry) async {
    _entries[daysAgo(0, inputEntry.dateTime)].add(inputEntry);
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
    _entries[daysAgo(0, goalEntry.dateTime)].add(goalEntry);
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
    int size;
    await ref.where('name', isEqualTo: category.name).getDocuments().then((value) => size = value.documents.length);
    if(size == 0) {
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
    _entries[daysAgo(0, inputEntry.dateTime)].remove(inputEntry);
    var ref = Firestore.instance.collection('users').document(user.uid).collection(_inputEntries);
    try {
      await ref.document(inputEntry.docID).delete();
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<bool> deleteGoalEntry(FirebaseUser user, GoalEntry goalEntry) async {
    _entries[daysAgo(0, goalEntry.dateTime)].add(goalEntry);
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


  //Specialized Methods

  Future<List<Entry>> getEntriesOnDay(FirebaseUser user, DateTime day) async {
    if(_entries[day] == null) {
      final temp = await _getEntriesAsFuture(user, dateTime: day);
      _entries[day] = temp;
    }
    return _entries[day] ?? [];
  }

  Future<List<Entry>> _getEntriesAsFuture(FirebaseUser user, {DateTime dateTime}) async{
    var inputRef = Firestore.instance.collection('users').document(user.uid).collection(_inputEntries);
    var goalRef = Firestore.instance.collection('users').document(user.uid).collection(_goalEntries);
    List<Entry> tempList = [];

    final iSnap = await inputRef
        .where('dateTime', isGreaterThanOrEqualTo: dateTime)
        .where('dateTime', isLessThan: daysAgo(-1, dateTime)).getDocuments();

    final gSnap = await goalRef
        .where('dateTime', isGreaterThanOrEqualTo: dateTime)
        .where('dateTime', isLessThan: daysAgo(-1, dateTime)).getDocuments();

    List<InputEntry> iEntries = iSnap.documents.map<InputEntry>((doc) => InputEntry.fromMap(doc.data, doc.documentID)).toList();;
    List<GoalEntry> gEntries = gSnap.documents.map<GoalEntry>((doc) => GoalEntry.fromMap(doc.data, doc.documentID)).toList();;

    tempList.addAll(iEntries);
    tempList.addAll(gEntries);
    tempList.sort();

    return tempList;
  }
}