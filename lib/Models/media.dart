class Media {
  int id;
  String name;
  String categoryName;
  int episodeWatchCount;
  int episodeCount;
  double timePerUnit;
  double totalTime;
  DateTime startDate;
  DateTime completeDate;
  DateTime lastUpDate;
  bool isCompleted;
  bool isDropped;

  Media(
      {this.id,
      this.name,
      this.categoryName,
      this.episodeWatchCount = 0,
      this.episodeCount,
      this.timePerUnit = 0.0,
      this.totalTime,
      this.startDate,
      this.completeDate,
      this.lastUpDate,
      this.isCompleted = false,
      this.isDropped = false}) {
    totalTime ??= timePerUnit * episodeWatchCount.toDouble();
  }

  factory Media.fromMap(Map<String,dynamic> map) => Media(
    id: map['id'],
    name: map['name'],
    categoryName: map['categoryName'],
    episodeWatchCount: map['episodeWatchCount'],
    episodeCount: map['episodeCount'],
    timePerUnit: (map['timePerUnit'] ?? 0).toDouble(),
    totalTime: (map['totalTime'] ?? 0).toDouble(),
    startDate: (map['startDate'] != null) ? map['startDate'].toDate() : null,
    completeDate: (map['completeDate'] != null) ? map['completeDate'].toDate() : null,
    lastUpDate: (map['lastUpDate'] != null) ? map['lastUpDate'].toDate() : null,
    isCompleted: map['isCompleted'] ?? false,
    isDropped: map['isDropped'] ?? false
  );

  Map<String,dynamic> toMap() => {
    'id': id,
    'name': name,
    'categoryName': categoryName,
    'episodeWatchCount': episodeWatchCount,
    'episodeCount': episodeCount,
    'timePerUnit': timePerUnit,
    'totalTime': totalTime,
    'startDate': startDate,
    'completeDate': completeDate,
    'lastUpDate': lastUpDate,
    'isCompleted': isCompleted,
    'isDropped': isDropped
  };
}
