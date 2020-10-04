import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Media/media_selection_model.dart';
import 'package:miatracker/Models/DailyInputEntryPacket.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/error_handling_model.dart';
import 'package:miatracker/Models/input_entries_provider.dart';
import 'package:miatracker/Models/tab_change_notifier.dart';
import 'package:rxdart/rxdart.dart';
import '../Map.dart';
import 'GoalEntry.dart';
import 'InputEntry.dart';
import 'media.dart';
import 'user.dart';
import 'dart:math' as math;

class DatabaseService {
  DatabaseService._();

  final String _goalEntries = 'goalEntries';
  final String _aggregateInputEntries = 'aggregateInputEntries';
  final String _media = 'media';

  static final itemsPerPage = 15;

  Map<String, DocumentSnapshot> _lastDocuments =
      Map<String, DocumentSnapshot>();
  Map<String, bool> _hasMoreMedia = {
    'In Progress': true,
    'Complete': true,
    'Dropped': true
  };
  Map<String, List<List<Media>>> _allPagedResults =
      Map<String, List<List<Media>>>();

  Map<String, bool> get hasMoreMedia => _hasMoreMedia;

  var _mediaSubjects = {
    'In Progress': BehaviorSubject<List<Media>>.seeded([]),
    'Complete': BehaviorSubject<List<Media>>.seeded([]),
    'Dropped': BehaviorSubject<List<Media>>.seeded([]),
  };

  Stream<List<Media>> mediaStream(String type) {
    return _mediaSubjects[type].stream;
  }

  Map<DateTime, DailyInputEntry> _aggregateEntries =
      Map<DateTime, DailyInputEntry>();

  static final DatabaseService instance = DatabaseService._();

  Stream<AppUser> appUserStream(auth.User user) {
    var ref = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return ref.snapshots().map((doc) => AppUser.fromMap(doc.data()));
  }

  Future<bool> addInputEntry(AppUser user, InputEntry inputEntry) async {
    try {
      final docID =
          '${inputEntry.dateTime} ${inputEntry.inputType} ${inputEntry.amount} ${UniqueKey().hashCode}';
      inputEntry.docID = docID;
      _updateAggregateData(user, inputEntry);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteInputEntry(AppUser user, InputEntry inputEntry) async {
    try {
      InputEntriesProvider.instance.entries[daysAgo(0, inputEntry.dateTime)]
          .remove(inputEntry);
      _updateAggregateData(user, inputEntry, isDelete: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addGoalEntry(AppUser user, GoalEntry goalEntry) async {
    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    var ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(_goalEntries);

    try {
      int index = user.categories.indexOf(Category(name: goalEntry.inputType));
      if (index < 0 || user.categories[index].goalAmount == goalEntry.amount)
        return false;

      final docID =
          '${goalEntry.dateTime} ${goalEntry.inputType} ${goalEntry.amount}';
      goalEntry.docID = docID;
      InputEntriesProvider.instance.entries[daysAgo(0, goalEntry.dateTime)]
          .add(goalEntry);
      categoryFromName(goalEntry.inputType, user.categories).goalAmount =
          goalEntry.amount;

      await userRef.update(user.toMap());
      await ref.doc(docID).set(goalEntry.toMap());

      return true;
    } catch (e) {
      return false;
    }
  }

  void updateCategories(AppUser user, {Category category, bool isDelete}) {
    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    if (isDelete) {
      user.categories.remove(category);
      userRef.set(user.toMap());
    } else {
      //2 categories cannot have the same name
      int index = user.categories.indexOf(category);

      if (index == -1) {
        user.categories.add(category);
        userRef.set(user.toMap());
      }
    }
  }

  void editUser(AppUser user) {
    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    userRef.set(user.toMap(), SetOptions(merge: true));
  }

  Future<List<Entry>> getEntriesAsFuture(String uid,
      {DateTime dateTime}) async {
    var inputRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_aggregateInputEntries)
        .doc(daysAgo(0, dateTime).toString().replaceFirst('Z', ''));

    var goalRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_goalEntries);
    List<Entry> tempList = [];

    final gSnap = await goalRef
        .where('dateTime',
            isGreaterThanOrEqualTo: daysAgo(0, dateTime).toLocal())
        .where('dateTime', isLessThan: daysAgo(-1, dateTime).toLocal())
        .get();

    try {
      List<InputEntry> iEntries =
          DailyInputEntry.fromMap((await inputRef.get()).data()).inputEntries;

      List<GoalEntry> gEntries = gSnap.docs
          .map<GoalEntry>((doc) => GoalEntry.fromMap(doc.data(), doc.id))
          .toList();

      tempList.addAll(iEntries);
      tempList.addAll(gEntries);
      tempList.sort();
    } catch (e) {}
    return tempList;
  }

  Stream<DailyInputEntryPacket> getDailyInputEntriesOnDays(String uid,
      {@required DateTime startDate, @required DateTime endDate}) async* {
    if (_aggregateEntries[startDate] == null) {
      _aggregateEntries.addAll(await dailyInputEntriesStream(uid,
              startDate: startDate, endDate: endDate)
          .first);
    }
    var map = Map<DateTime, DailyInputEntry>.from(_aggregateEntries)
      ..removeWhere((date, value) =>
          date.isBefore(daysAgo(0, startDate)) ||
          date.isAfter(daysAgo(1, endDate)));
    yield DailyInputEntryPacket(
        startDate: startDate, endDate: endDate, dailyInputEntries: map);
  }

  Stream<Map<DateTime, DailyInputEntry>> dailyInputEntriesStream(String uid,
      {@required DateTime startDate, @required DateTime endDate}) {
    var ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_aggregateInputEntries);

    return ref
        .where('dateTime',
            isGreaterThanOrEqualTo: startDate.toLocal(),
            isLessThan: endDate.toLocal())
        .snapshots()
        .map((list) {
      var map = Map<DateTime, DailyInputEntry>.fromIterables(
          list.docs
              .map((doc) => DailyInputEntry.fromMap(doc.data()).dateTime)
              .toList(),
          list.docs.map((doc) => DailyInputEntry.fromMap(doc.data())).toList());
      return map ?? {};
    });
  }

  void _updateAggregateData(AppUser user, InputEntry inputEntry,
      {bool isDelete = false}) async {
    String docID =
        daysAgo(0, inputEntry.dateTime).toString().replaceFirst('Z', '');
    bool transactionSuccessful = false;
    int retryAttemptsAllowed = 5;

    var docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(_aggregateInputEntries)
        .doc(docID);
    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    var mediaRef;
    if (inputEntry.mediaID != null) {
      mediaRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(_media)
          .doc(inputEntry.mediaID.toString());
    }

    for (int i = 0; i < retryAttemptsAllowed; i++) {
      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          bool successfulDeletion = true;

          DailyInputEntry agData = await transaction.get(docRef).then((value) {
            if (!value.exists) {
              if (!isDelete) {
                final agData = DailyInputEntry(
                  dateTime: daysAgo(0, inputEntry.dateTime),
                  categoryHours: <String, dynamic>{
                    inputEntry.inputType: inputEntry.amount
                  },
                  inputEntries: [inputEntry],
                );
                _aggregateEntries[daysAgo(0, inputEntry.dateTime)] = agData;
                return agData;
              }
              return null;
            }
            //deep copy for comparison
            final oldData = DailyInputEntry.fromMap(value.data());
            final newData = _getUpdatedEntry(
                DailyInputEntry.fromMap(value.data()), inputEntry, isDelete);

            //Make sure data actually changed
            successfulDeletion = oldData.categoryHours[inputEntry.inputType] !=
                newData.categoryHours[inputEntry.inputType];

            return newData;
          });

          AppUser user =
              AppUser.fromMap((await transaction.get(userRef)).data());
          if (successfulDeletion) {
            user = _getUpdatedUser(user, inputEntry, isDelete: isDelete);
          }

          if (mediaRef != null && successfulDeletion) {
            Media media =
                Media.fromMap((await transaction.get(mediaRef)).data());
            media = _getUpdatedMedia(media, inputEntry, isDelete: isDelete);
            transaction.update(mediaRef, media.toMap());
          }
          transaction.update(userRef, user.toMap());
          transaction.set(docRef, agData.toMap());
        },
      ).timeout(Duration(seconds: 2), onTimeout: () {
        if (i == 0) {
          ErrorHandlingModel.instance.addValue(
              'This is taking a while... You can continue using the app');
          Crashlytics.instance.log('Transaction duration exceeded 2 seconds');
        }
      }).then((_) {
        if (!isDelete) updateOfflineEntries(inputEntry);
        transactionSuccessful = true;
      }).catchError((error, stack) {
        Crashlytics.instance.recordError(error, stack);
      });
      if(transactionSuccessful) break;
      await Future.delayed(Duration(seconds: 4));
    }
    if (!transactionSuccessful) {
      ErrorHandlingModel.instance
          .addValue('Something went wrong. Please try again');
    }
  }

  void updateOfflineEntries(InputEntry inputEntry) {
    if (InputEntriesProvider
            .instance.entries[daysAgo(0, inputEntry.dateTime)] !=
        null) {
      InputEntriesProvider
          .instance.entries[daysAgo(0, inputEntry.dateTime)] = _addUnique(
          inputEntry,
          InputEntriesProvider
              .instance.entries[daysAgo(0, inputEntry.dateTime)]);
    }
  }

  DailyInputEntry _getUpdatedEntry(
      DailyInputEntry oldEntry, InputEntry inputEntry, bool isDelete) {
    try {
      int previousSize = oldEntry.inputEntries.length;
      if (isDelete) {
        oldEntry.inputEntries.remove(inputEntry);
      } else {
        oldEntry.inputEntries = _addUnique(inputEntry, oldEntry.inputEntries);
      }
      int newSize = oldEntry.inputEntries.length;

      bool goodTransaction = newSize != previousSize;

      if (goodTransaction) {
        oldEntry.categoryHours[inputEntry.inputType] =
            (((isDelete) ? -1 : 1) * inputEntry.amount) +
                (oldEntry.categoryHours[inputEntry.inputType] ?? 0.0);

        oldEntry.categoryHours[inputEntry.inputType] =
            aboveZero(oldEntry.categoryHours[inputEntry.inputType]);
      }
      _aggregateEntries[daysAgo(0, inputEntry.dateTime)] = oldEntry;
    } catch (e) {}
    return oldEntry;
  }

  List<Entry> _addUnique(InputEntry inputEntry, List<Entry> entries) {
    var set = entries.toSet();
    set.add(inputEntry);
    return set.toList();
  }

  AppUser _getUpdatedUser(AppUser oldUser, InputEntry inputEntry,
      {bool isDelete = false}) {
    Category category =
        categoryFromName(inputEntry.inputType, oldUser.categories);

    category.lifetimeAmount += ((isDelete) ? -1 : 1) * inputEntry.amount;
    category.lifetimeAmount = aboveZero(category.lifetimeAmount);

    return oldUser;
  }

  Stream<DailyInputEntry> getFirstDayOfActivity(String uid) {
    var ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_aggregateInputEntries);

    return ref.orderBy('dateTime').limit(1).snapshots().map(
        (singleList) => DailyInputEntry.fromMap(singleList.docs.first.data()));
  }

  void addMedia(AppUser user, Media media) {
    var collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(_media);
    var id = DateTime.now().microsecondsSinceEpoch;
    media.id = id;
    collectionRef.doc(id.toString()).set(media.toMap());
  }

  void updateMedia(AppUser user, Media media) {
    var docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(_media)
        .doc(media.id.toString());
    docRef.set(media.toMap(), SetOptions(merge: true));
  }

  void deleteMedia(AppUser user, Media media) {
    var docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(_media)
        .doc(media.id.toString());
    docRef.delete();
  }

  Media _getUpdatedMedia(Media oldMedia, InputEntry inputEntry,
      {bool isDelete}) {
    if (isDelete) {
      oldMedia.totalTime -= inputEntry.amount;
      oldMedia.episodeWatchCount -= inputEntry.episodesWatched;
    } else {
      oldMedia.totalTime += inputEntry.amount;
      oldMedia.episodeWatchCount += inputEntry.episodesWatched;
    }
    if (oldMedia.episodeCount != null)
      oldMedia.isCompleted =
          oldMedia.episodeWatchCount >= oldMedia.episodeCount;
    oldMedia.totalTime = math.max(oldMedia.totalTime, 0);
    oldMedia.episodeWatchCount = math.max(oldMedia.episodeWatchCount, 0);
    oldMedia.lastUpDate = DateTime.now();

    return oldMedia;
  }

  void _resetMedia() {
    _allPagedResults['In Progress'].clear();
    _hasMoreMedia['In Progress'] = true;
    _lastDocuments['In Progress'] = null;

    _allPagedResults['Complete'].clear();
    _hasMoreMedia['Complete'] = true;
    _lastDocuments['Complete'] = null;

    _allPagedResults['Dropped'].clear();
    _hasMoreMedia['Dropped'] = true;
    _lastDocuments['Dropped'] = null;
  }

  void refreshMedia(String uid, String type,
      {Category category,
      SortType sortType,
      bool showComplete = false,
      bool showDropped = false}) {
    if (_allPagedResults[type] != null) _allPagedResults[type].clear();
    _hasMoreMedia[type] = true;
    _lastDocuments[type] = null;
    requestMedia(uid, type,
        category: category,
        sortType: sortType,
        showComplete: showComplete,
        showDropped: showDropped);
  }

  void requestMedia(String uid, String type,
      {Category category,
      SortType sortType,
      bool showComplete = false,
      bool showDropped = false}) {
    if (type == null) return;

    if (_allPagedResults[type] == null)
      _allPagedResults[type] = List<List<Media>>();

    var collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_media);

    var field;
    bool isDescending;

    switch (sortType) {
      case SortType.lastUpdated:
        field = 'lastUpDate';
        isDescending = true;
        break;
      case SortType.mostHours:
        field = 'totalTime';
        isDescending = true;
        break;
      case SortType.alphabetical:
        field = 'nameCaseInsensitive';
        isDescending = false;
        break;
      case SortType.newest:
        field = 'startDate';
        isDescending = true;
        break;
      case SortType.oldest:
        field = 'startDate';
        isDescending = false;
        break;
    }

    var pageMediaQuery = (category != null)
        ? collectionRef
            .orderBy(field, descending: isDescending)
            .where('categoryName', isEqualTo: category.name)
            .where('isCompleted', isEqualTo: showComplete)
            .where('isDropped', isEqualTo: showDropped)
            .limit(itemsPerPage)
        : collectionRef
            .orderBy(field, descending: isDescending)
            .where('isCompleted', isEqualTo: showComplete)
            .where('isDropped', isEqualTo: showDropped)
            .limit(itemsPerPage);

    if (_lastDocuments[type] != null) {
      pageMediaQuery = pageMediaQuery.startAfterDocument(_lastDocuments[type]);
    }
    if (!_hasMoreMedia[type]) return;

    var currentRequestIndex = _allPagedResults[type].length;

    if (MediaSelectionModel.instance.selectedCategory == category &&
        MediaSelectionModel.instance.selectedSortTypes[type] == sortType) {
      pageMediaQuery.snapshots().listen((mediaSnapshot) {
        if (MediaSelectionModel.instance.selectedCategory == category &&
            MediaSelectionModel.instance.selectedSortTypes[type] == sortType) {
          if (mediaSnapshot.docs.isNotEmpty) {
            var media = mediaSnapshot.docs
                .map((snapshot) => Media.fromMap(snapshot.data()))
                .toList();

            var pageExists =
                currentRequestIndex < _allPagedResults[type].length;
            if (pageExists) {
              _allPagedResults[type][currentRequestIndex] = media;
            } else {
              _allPagedResults[type].add(media);
            }

            var allMedia = _allPagedResults[type].fold<List<Media>>(
                List<Media>(),
                (initialValue, element) => initialValue..addAll(element));

            _mediaSubjects[type].add(allMedia);

            if (currentRequestIndex == _allPagedResults[type].length - 1) {
              _lastDocuments[type] = mediaSnapshot.docs.last;
            }
            _hasMoreMedia[type] = media.length >= itemsPerPage;
          } else {
            if (currentRequestIndex == 0) _mediaSubjects[type].add([]);
            _hasMoreMedia[type] = false;
          }
        }
      });
    }
  }

  clearCache() {
    _aggregateEntries.clear();
    TabChangeNotifier.instance.index = null;
    _resetMedia();
  }

  double aboveZero(double num) {
    return math.max(num, 0);
  }
}
