import 'package:flutter/material.dart';
import 'package:gantt_chart/models/gantt_models.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class GanttDatabase extends ChangeNotifier {
  static late Isar isar;

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  List<Milestone> _milestones = [];
  List<Milestone> get milestones => _milestones;

  List<DBTask> _tasks = [];
  List<DBTask> get tasks => _tasks;

  GanttDatabase() {
    _initializeDatabase();
  }

  // Initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ProjectSchema, MilestoneSchema, DBTaskSchema],
        directory: dir.path);
  }

  Future<void> _initializeDatabase() async {
    await GanttDatabase.initialize();
    await fetchMilestonesc();
  }

  Future<void> fetchProjects() async {
    _projects = await isar.projects.where().findAll();
    for (var project in _projects) {
      await project.milestones.load();
    }
    notifyListeners();
  }

  //a~adido por mi
  Future<void> fetchMilestonesc() async {
    _milestones = await isar.milestones.where().findAll();
    for (var milestone in _milestones) {
      await milestone.tasks.load();
    }
    notifyListeners();
  }

  // Future<void> fetchMilestones(int projectId) async {
  //   _milestones = await isar.milestones.filter().projectIdEqualTo(projectId).findAll();
  //   for (var milestone in _milestones) {
  //     await milestone.tasks.load();
  //   }
  //   notifyListeners();
  // }

  Future<void> fetchTasks(int milestoneId) async {
    _tasks =
        await isar.dBTasks.filter().milestoneIdEqualTo(milestoneId).findAll();
    notifyListeners();
  }

  Future<void> addProject(String projectName, String description) async {
    final newProject = Project()
      ..projectName = projectName
      ..description = description
      ..status = true;
    await isar.writeTxn(() => isar.projects.put(newProject));
    await fetchProjects();
  }

  Future<void> updateProject(
      int id, String newName, String newDescription, bool newStatus) async {
    final existingProject = await isar.projects.get(id);
    if (existingProject != null) {
      existingProject.projectName = newName;
      existingProject.description = newDescription;
      existingProject.status = newStatus;
      await isar.writeTxn(() => isar.projects.put(existingProject));
      await fetchProjects();
    }
  }

  Future<void> deleteProject(int id) async {
    await isar.writeTxn(() => isar.projects.delete(id));
    await fetchProjects();
  }

  Future<void> addMilestone(
      int projectId, String milestoneName, String description) async {
    final newMilestone = Milestone()
      ..milestoneName = milestoneName
      ..description = description
      ..status = true;
    // ..projectId = projectId;
    await isar.writeTxn(() => isar.milestones.put(newMilestone));
    // await fetchMilestones(projectId);
    await fetchMilestonesc();
    notifyListeners();
  }

  Future<void> updateMilestone(
      int id, String newName, String newDescription, bool newStatus) async {
    final existingMilestone = await isar.milestones.get(id);
    if (existingMilestone != null) {
      existingMilestone.milestoneName = newName;
      existingMilestone.description = newDescription;
      existingMilestone.status = newStatus;
      await isar.writeTxn(() => isar.milestones.put(existingMilestone));
      await fetchMilestonesc();
      notifyListeners();
      // await fetchMilestones(existingMilestone.projectId);
    }
  }

  Future<void> deleteMilestone(int id) async {
    final milestone = await isar.milestones.get(id);
    if (milestone != null) {
      await isar.writeTxn(() => isar.milestones.delete(id));
      await fetchMilestonesc();
      notifyListeners();
      // await fetchMilestones(milestone.projectId);
    }
  }

  Future<void> addTask(
      int milestoneId, String taskName, String description) async {
    final newTask = DBTask()
      ..taskName = taskName
      ..description = description
      ..status = true
      ..milestoneId = milestoneId;
    await isar.writeTxn(() => isar.dBTasks.put(newTask));
    await fetchTasks(milestoneId);
    notifyListeners();
  }

  Future<void> updateTask(
      int id, String newName, String newDescription, bool newStatus) async {
    final existingTask = await isar.dBTasks.get(id);
    if (existingTask != null) {
      existingTask.taskName = newName;
      existingTask.description = newDescription;
      existingTask.status = newStatus;
      await isar.writeTxn(() => isar.dBTasks.put(existingTask));
      await fetchTasks(existingTask.milestoneId);
    }
  }

  Future<void> deleteTask(int id) async {
    final task = await isar.dBTasks.get(id);
    if (task != null) {
      await isar.writeTxn(() => isar.dBTasks.delete(id));
      await fetchTasks(task.milestoneId);
    }
  }
}
