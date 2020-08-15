
import 'package:flutter/material.dart';

class AppUser {
  String displayName;
  String email;
  String uid;
  List<Category> categories;

  AppUser({this.displayName, this.email, this.uid, this.categories});

  factory AppUser.fromMap(Map<String, dynamic> map) {
    List<Category> tempList = [];
    try {
      tempList = List<Category>.from(map['categories'].map((i) => Category.fromMap(i)));
    } catch (e) {print(e);}

    return AppUser(
      displayName: map['displayName'],
      email: map['email'],
      uid: map['uid'],
      categories: tempList,
    );
  }

  Map<String, dynamic> toMap() {
    var tempList = [];
    try {
      tempList =
          List<dynamic>.from(categories.map((category) => category.toMap()));
    } catch (e) {}

    return {
      'displayName': displayName,
      'email': email,
      'uid': uid,
      'categories': tempList,
    };
  }
}

class Category {
  String name;
  DateTime addDate;
  bool isTimeBased;
  double goalAmount;
  double lifetimeAmount;
  Color color;

  Category({this.name, this.addDate, this.isTimeBased, this.goalAmount=0, this.color, this.lifetimeAmount=0});

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        name: map['name'],
        addDate: map['addDate'].toDate(),
        isTimeBased: map['isTimeBased'],
        goalAmount: (map['goalAmount'] ?? 0).toDouble(),
        color: Color(map['color'] ?? 0).withOpacity(1),
        lifetimeAmount: (map['lifetimeAmount'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'addDate': addDate,
        'isTimeBased': isTimeBased,
        'goalAmount': goalAmount,
        'color': color.value,
        'lifetimeAmount': lifetimeAmount,
      };

  @override
  bool operator ==(other) {
    if (!(other is Category)) return false;
    return this.name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  bool fieldsEqual(Category other) {
    if(other == null) return false;

    return (
      name == other.name &&
      isTimeBased == other.isTimeBased &&
      goalAmount == other.goalAmount &&
      color == other.color
    );
  }
}
