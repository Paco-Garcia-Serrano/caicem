import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gantt_chart/models/gantt_database.dart';
import 'package:gantt_chart/models/gantt_models.dart';
import 'package:gantt_chart/widgets/gantt_chart.dart';
import 'package:gantt_chart/widgets/general_timeline.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GanttDatabase()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Gantt(),
      ),
    );
  }
}

Color getRandomColor() {
  Random random = Random();
  List<Color> colors = [
    Color.fromARGB(255, 170, 1, 68),
    Color.fromARGB(255, 102, 194, 233),
    Color.fromARGB(255, 230, 103, 134),
    Color.fromARGB(255, 59, 11, 79),
  ];
  return colors[random.nextInt(colors.length)];
}

class Gantt extends StatefulWidget {
  const Gantt({super.key});
  @override
  _GanttState createState() => _GanttState();
}

class _GanttState extends State<Gantt> {
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController1.addListener(() {
      if (_scrollController1.offset != _scrollController2.offset) {
        _scrollController2.jumpTo(_scrollController1.offset);
      }
    });
    _scrollController2.addListener(() {
      if (_scrollController2.offset != _scrollController1.offset) {
        _scrollController1.jumpTo(_scrollController2.offset);
      }
    });
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ganttDatabase = Provider.of<GanttDatabase>(context);
    final List<Color> colors = List.generate(
        ganttDatabase.milestones.length, (index) => getRandomColor());
    return ChangeNotifierProvider(
        create: (context) => GanttDatabase()..fetchMilestonesc(),
        builder: (context, child) {
          return MaterialApp(
            home: SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color.fromARGB(255, 170, 1, 68),
                  title: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: _toggleDrawer,
                      ),
                      const Text(
                        'Project Name',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                body: Row(
                  children: [
                    if (_isDrawerOpen)
                      SizedBox(
                        width: 250,
                        child: Column(
                          children: [
                            // Container(
                            //   color: const Color.fromARGB(255, 170, 1, 68),
                            //   padding: const EdgeInsets.all(16.0),
                            //   child: const Center(
                            //     child: Text(
                            //       'Project Name',
                            //       style: TextStyle(
                            //         color: Colors.black,
                            //         fontSize: 16.0,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Container(
                              height: 82,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 170, 1, 68),
                                border: Border(
                                  top: BorderSide(
                                      width: 1.0, color: Colors.black),
                                  bottom: BorderSide(
                                      width: 1.0, color: Colors.black),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: ganttDatabase.milestones.length,
                                  itemBuilder: (context, index) {
                                    final milestone =
                                        ganttDatabase.milestones[index];
                                    return ExpansionTile(
                                        title: Text(
                                          milestone.milestoneName,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: colors[index],
                                        collapsedBackgroundColor: colors[index],
                                        subtitle: Text(
                                          'Status: ${milestone.status}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        children: [
                                          Text(
                                            'Description: ${milestone.description}',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () {
                                                  _editMilestone(
                                                      context, milestone);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  ganttDatabase.deleteMilestone(
                                                      milestone.id);
                                                },
                                              ),
                                            ],
                                          ),
                                          ...ganttDatabase.tasks
                                              .where((task) =>
                                                  task.milestoneId ==
                                                  milestone.id)
                                              .map((task) {
                                            return ListTile(
                                              title: Text(
                                                'Task: ${task.taskName}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              subtitle: Text(
                                                'Status: ${task.status}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    onPressed: () {
                                                      _editTask(context, task);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    onPressed: () {
                                                      ganttDatabase
                                                          .deleteTask(task.id);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              _addTask(context, milestone.id);
                                            },
                                          ),
                                        ]);
                                  }),
                            ),
                            TextButton(
                              onPressed: () {
                                _addMilestone(context,
                                    ganttDatabase.milestones.length + 1);
                              },
                              child: const Text('+ Milestone'),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                TimelineWidget(_scrollController1),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _scrollController2,
                                      // Este widget es donde esta mi problema. Todos son visuales.
                                      child: GanttChart(
                                        barColor: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 50,
                            color: const Color.fromARGB(255, 170, 1, 68),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.person),
                                        onPressed: () {},
                                        color: Colors.white,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.chat_rounded),
                                        onPressed: () {},
                                        color: Colors.white,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.settings),
                                        onPressed: () {},
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _addMilestone(BuildContext context, int projectId) {
    final TextEditingController milestoneNameController =
        TextEditingController();
    final TextEditingController milestoneDescriptionController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: milestoneNameController,
                decoration: const InputDecoration(labelText: 'Milestone Name'),
              ),
              TextField(
                controller: milestoneDescriptionController,
                decoration:
                    const InputDecoration(labelText: 'Milestone Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<GanttDatabase>(context, listen: false).addMilestone(
                  projectId,
                  milestoneNameController.text,
                  milestoneDescriptionController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

void _editMilestone(BuildContext context, Milestone milestone) {
  final TextEditingController milestoneNameController =
      TextEditingController(text: milestone.milestoneName);
  final TextEditingController milestoneDescriptionController =
      TextEditingController(text: milestone.description);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Milestone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: milestoneNameController,
              decoration: const InputDecoration(labelText: 'Milestone Name'),
            ),
            TextField(
              controller: milestoneDescriptionController,
              decoration:
                  const InputDecoration(labelText: 'Milestone Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GanttDatabase>(context, listen: false)
                  .updateMilestone(
                milestone.id,
                milestoneNameController.text,
                milestoneDescriptionController.text,
                milestone.status,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void _addTask(BuildContext context, int milestoneId) {
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskNameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: taskDescriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GanttDatabase>(context, listen: false).addTask(
                milestoneId,
                taskNameController.text,
                taskDescriptionController.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

void _editTask(BuildContext context, DBTask task) {
  final TextEditingController taskNameController =
      TextEditingController(text: task.taskName);
  final TextEditingController taskDescriptionController =
      TextEditingController(text: task.description);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskNameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: taskDescriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GanttDatabase>(context, listen: false).updateTask(
                task.id,
                taskNameController.text,
                taskDescriptionController.text,
                task.status,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
