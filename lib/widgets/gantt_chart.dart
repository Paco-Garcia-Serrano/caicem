// Aqui mis problemas son el cambio de tama~o de las barras del timeline, cuando se cambia de formato (Day, Week, Month).
// y las barras negras, que cada que implemento un cambio en el tama~o se multiplican demaciado
import 'dart:math';
import 'package:flutter/material.dart';

class GanttChart extends StatelessWidget {
  final Color barColor;
  final Color lineColor;
  final double fontSize;
  const GanttChart({
    super.key,
    this.barColor = Colors.blue,
    this.lineColor = Colors.grey,
    this.fontSize = 15,
  });
  List<MileStone> generateDummyData() {
    List<MileStone> milestones = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      List<Task> tasks = [];
      for (int j = 0; j < 3; j++) {
        DateTime start = now.add(Duration(days: Random().nextInt(30)));
        DateTime end = start.add(Duration(days: Random().nextInt(10) + 1));
        tasks.add(Task(
          title: 'Task ${i * 3 + j + 1}',
          description: 'Description for Task ${i * 3 + j + 1}',
          start: start,
          end: end,
        ));
      }
      milestones.add(MileStone(
        title: 'Milestone ${i + 1}',
        description: 'Description for Milestone ${i + 1}',
        start: tasks
            .map((task) => task.start)
            .reduce((a, b) => a.isBefore(b) ? a : b),
        end: tasks
            .map((task) => task.end)
            .reduce((a, b) => a.isAfter(b) ? a : b),
        tasks: tasks,
      ));
    }
    return milestones;
  }

  @override
  Widget build(BuildContext context) {
    List<MileStone> milestones = generateDummyData();
    DateTime startDate = milestones
        .map((milestone) => milestone.start)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    DateTime endDate = milestones
        .map((milestone) => milestone.end)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    double width = (endDate.difference(startDate).inDays + 1) * 50;
    double height = milestones.length * 150.0;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: GanttPainter(
          milestones,
          startDate,
          endDate,
          barColor,
          lineColor,
          fontSize,
        ),
      ),
    );
  }
}

class GanttPainter extends CustomPainter {
  final List<MileStone> milestones;
  final DateTime startDate;
  final DateTime endDate;
  final Paint taskPaint;
  final Paint linePaint;
  final Paint backgroundLinePaint;
  final TextPainter textPainter;
  final double fontSize;
  final double padding;
  GanttPainter(this.milestones, this.startDate, this.endDate, Color barColor,
      Color lineColor, this.fontSize,
      {this.padding = 10})
      : taskPaint = Paint()
          ..color = barColor
          ..style = PaintingStyle.fill,
        linePaint = Paint()
          ..color = lineColor
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
        backgroundLinePaint = Paint()
          ..color = Colors.black
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
        textPainter = TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            text: TextSpan(style: TextStyle(fontSize: fontSize))) {
    textPainter.layout();
  }
  @override
  void paint(Canvas canvas, Size size) {
    double barHeight = 30;
    double currentY = 0;
    for (double x = 0; x < size.width; x += 100) {
      canvas.drawLine(
          Offset(x, 0), Offset(x, size.height), backgroundLinePaint);
    }
    for (int i = 0; i < milestones.length; i++) {
      MileStone milestone = milestones[i];
      int minStart = milestone.tasks
          .map((task) => task.start.difference(startDate).inDays)
          .reduce(min);
      int maxEnd = milestone.tasks
          .map((task) => task.end.difference(startDate).inDays + 1)
          .reduce(max);
      double x = minStart * 50;
      double width = (maxEnd - minStart) * 50;
      Rect barRect = Rect.fromLTWH(x, currentY, width, barHeight);
      canvas.drawRect(barRect, taskPaint);
      double textX = x + width / 2;
      double textY = currentY + barHeight / 2 - textPainter.height / 2;
      textPainter.text = TextSpan(
          text: milestone.title, style: const TextStyle(color: Colors.black));
      textPainter.layout();
      textPainter.paint(canvas, Offset(textX, textY));
      currentY += barHeight + padding;
      for (Task task in milestone.tasks) {
        int start = task.start.difference(startDate).inDays;
        int end = task.end.difference(startDate).inDays + 1;
        double taskX = start * 50;
        double taskWidth = (end - start) * 50;
        Rect taskRect = Rect.fromLTWH(taskX, currentY, taskWidth, barHeight);
        canvas.drawRect(taskRect, taskPaint);
        double taskTextX = taskX + taskWidth / 2;
        double taskTextY = currentY + barHeight / 2 - textPainter.height / 2;
        textPainter.text = TextSpan(
            text: task.title, style: const TextStyle(color: Colors.black));
        textPainter.layout();
        textPainter.paint(canvas, Offset(taskTextX, taskTextY));
        currentY += barHeight + padding;
      }
    }
    double lineY = size.height;
    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Task {
  final String title;
  final String description;
  late bool status;
  final DateTime start;
  final DateTime end;
  Task(
      {required this.title,
      required this.description,
      required this.start,
      required this.end});
}

class MileStone {
  final String title;
  final String description;
  late bool status;
  final DateTime start;
  final DateTime end;
  final List<Task> tasks;
  MileStone(
      {required this.title,
      required this.description,
      required this.start,
      required this.end,
      required this.tasks});
}
