import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../db/objectif_db.dart';
import '../../entities/Objectif.dart';

class ObjectiveScreen extends StatefulWidget {
  const ObjectiveScreen({super.key});

  @override
  State<ObjectiveScreen> createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends State<ObjectiveScreen> {
  List<Objective> _objectives = [];
  final _titleCtrl = TextEditingController();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _currentBadge = '';

  // Map pour stocker le badge maximum par jour
  Map<String, String> _badgePerDay = {};

  @override
  void initState() {
    super.initState();
    _loadObjectives();
    _loadBadgesForMonth(_focusedDay);
  }

  // ------------ BADGE SYSTEM ------------
  String getBadge(int completedCount) {
    if (completedCount >= 5) return '💎';
    if (completedCount >= 4) return '🥇';
    if (completedCount >= 3) return '🥈';
    if (completedCount >= 2) return '🏅';
    return '';
  }

  // ------------ LOAD OBJECTIVES ------------
  Future<void> _loadObjectives() async {
    final dateStr = _selectedDay.toIso8601String().substring(0, 10);
    final list = await ObjectiveDB.getObjectives(dateStr);
    setState(() {
      _objectives = list;
      int completedCount = list.where((o) => o.completed).length;
      _currentBadge = getBadge(completedCount);
    });
  }

  // ------------ LOAD BADGES FOR MONTH ------------
  Future<void> _loadBadgesForMonth(DateTime focusedDay) async {
    _badgePerDay.clear();
    DateTime firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    DateTime lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    for (int i = 0; i < lastDayOfMonth.day; i++) {
      DateTime day = firstDayOfMonth.add(Duration(days: i));
      String dayStr = day.toIso8601String().substring(0, 10);
      final list = await ObjectiveDB.getObjectives(dayStr);
      if (list.isNotEmpty) {
        int completedCount = list.where((o) => o.completed).length;
        _badgePerDay[dayStr] = getBadge(completedCount);
      }
    }
    setState(() {});
  }

  // ------------ ADD OBJECTIVE ------------
  void _addObjective() {
    _titleCtrl.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎯 Fixer un objectif"),
        content: TextField(
          controller: _titleCtrl,
          decoration: InputDecoration(
            hintText: "Tu peux le faire!",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (_titleCtrl.text.isEmpty) return;
              await ObjectiveDB.addObjective(Objective(
                title: _titleCtrl.text,
                date: _selectedDay.toIso8601String().substring(0, 10),
              ));
              Navigator.pop(context);
              _loadObjectives();
              _loadBadgesForMonth(_focusedDay);
            },
            child: const Text("Ajouter"),
          )
        ],
      ),
    );
  }

  // ------------ EDIT / DELETE / TOGGLE ------------
  void _editObjective(Objective obj) {
    _titleCtrl.text = obj.title;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("✏️ Modifier l'objectif"),
        content: TextField(
          controller: _titleCtrl,
          decoration: InputDecoration(
            hintText: "Nouveau titre",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              if (_titleCtrl.text.isEmpty) return;
              obj.title = _titleCtrl.text;
              await ObjectiveDB.updateObjective(obj);
              Navigator.pop(context);
              _loadObjectives();
              _loadBadgesForMonth(_focusedDay);
            },
            child: const Text("Modifier"),
          ),
        ],
      ),
    );
  }

  void _toggleCompleted(Objective obj) async {
    obj.completed = !obj.completed;
    await ObjectiveDB.updateObjective(obj);
    _loadObjectives();
    _loadBadgesForMonth(_focusedDay);
  }

  void _deleteObjective(Objective obj) async {
    await ObjectiveDB.deleteObjective(obj.id!);
    _loadObjectives();
    _loadBadgesForMonth(_focusedDay);
  }

  // ------------ UI ------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon journal"),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addObjective,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              // ------------------ CALENDRIER ------------------
              TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadObjectives();
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _loadBadgesForMonth(focusedDay);
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    String dayStr = date.toIso8601String().substring(0, 10);
                    if (_badgePerDay.containsKey(dayStr)) {
                      return Positioned(
                        bottom: 4,
                        child: Text(
                          _badgePerDay[dayStr]!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),

              // ------------------ BADGE ------------------
              if (_currentBadge.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.greenAccent, Colors.green]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    'Vous êtes $_currentBadge',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),

              // ------------------ OBJECTIFS ------------------
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _objectives.length,
                itemBuilder: (_, i) {
                  final obj = _objectives[i];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: obj.completed ? Colors.green.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: obj.completed,
                        activeColor: Colors.green,
                        onChanged: (_) => _toggleCompleted(obj),
                      ),
                      title: Text(
                        obj.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: obj.completed ? TextDecoration.lineThrough : TextDecoration.none,
                          color: obj.completed ? Colors.grey : Colors.black87,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editObjective(obj),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteObjective(obj),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
