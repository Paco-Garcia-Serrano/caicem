import 'package:isar/isar.dart';

part 'gantt_models.g.dart';

@Collection()
class Project {
  Id id = Isar.autoIncrement;
  late String projectName;
  late String description;
  late bool status;
  final milestones = IsarLinks<Milestone>();
}

@Collection()
class Milestone {
  Id id = Isar.autoIncrement;
  late String milestoneName;
  late String description;
  late bool status;
  // late int projectId; 
  final tasks = IsarLinks<DBTask>();
}

@Collection()
class DBTask {
  Id id = Isar.autoIncrement;
  late String taskName;
  late String description;
  late bool status;
  late int milestoneId;
}