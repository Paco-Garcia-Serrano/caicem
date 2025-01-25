import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineWidget extends StatefulWidget {
  const TimelineWidget(this._scrollController, {super.key});
  final ScrollController _scrollController;
  @override
  _TimelineWidgetState createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  String _selectedPeriod = 'Year';
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year', 'Quarter'];
  List<String> timeline = [];

  @override
  void initState() {
    super.initState();
    timeline = _generateTimeline();
  }

  List<String> _generateTimeline() {
    DateTime now = DateTime.now();
    List<String> timeline = [];

    switch (_selectedPeriod) {
      case 'Day':
        DateTime startTime = DateTime(now.year, now.month, now.day, 0); // Start at 12 AM
        for (int i = 0; i < 24; i++) {
          timeline.add(DateFormat('hh:00 a').format(startTime.add(Duration(hours: i))));
        }
        break;
      case 'Week':
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday % 7)); // Start at Sunday
        for (int i = 0; i < 7; i++) {
          timeline.add(DateFormat('EEEE').format(startOfWeek.add(Duration(days: i))));
        }
        break;
      case 'Month':
        DateTime startOfMonth = DateTime(now.year, now.month, 1); // Start at the 1st of the current month
        int daysInMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 0).day;
        for (int i = 0; i < daysInMonth; i++) {
          timeline.add(DateFormat('d MMM').format(startOfMonth.add(Duration(days: i))));
        }
        break;
      case 'Year':
        DateTime startOfYear = DateTime(now.year, 1, 1); // Start at January 1st
        for (int i = 0; i < 12; i++) {
          timeline.add(DateFormat('MMMM').format(DateTime(startOfYear.year, startOfYear.month + i, 1)));
        }
        break;
      case 'Quarter':
        DateTime startOfQuarter = DateTime(now.year, 1, 1); // Start at January 1st
        for (int i = 0; i < 5; i++) {
          for (int j = 1; j <= 4; j++) {
            timeline.add('Q$j ${startOfQuarter.year + i}');
          }
        }
        break;
    }

    return timeline;
  }

  @override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.black, width: 1.0),
        bottom: BorderSide(color: Colors.black, width: 1.0),
      ),
    ),
    child: Column(
      children: [
        Container(
          color: const Color.fromARGB(255, 170, 1, 68),
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'General Timeline',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  items: _periods.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                                          style: TextStyle(color: Colors.white),),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPeriod = newValue!;
                      timeline = _generateTimeline();
                    });
                  },
                  hint: Text(
                    _selectedPeriod,
                    style: const TextStyle(color: Colors.white),
                  ),
                  dropdownColor: const Color.fromARGB(255, 170, 1, 68),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 0),
          color: const Color.fromARGB(255, 170, 1, 68),
          height: 35,
          child: ListView.builder(
            controller: widget._scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    timeline[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

}
