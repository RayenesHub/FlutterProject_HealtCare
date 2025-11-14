import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../db/Activity_DBHelper.dart';
import '../../entities/Activity_Model.dart';
import 'ActivityAdd.dart';

class ActivityList extends StatefulWidget {
  const ActivityList({super.key});

  @override
  State<ActivityList> createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  final ActivityDBHelper db = ActivityDBHelper();

  late Future<List<Activity>> _activitiesFuture;
  late Future<Map<String, dynamic>?> _favoriteActivityFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _activitiesFuture = db.getActivities();
    _favoriteActivityFuture = db.getFavoriteActivity();
  }

  Future<void> _deleteActivity(int id) async {
    await db.deleteActivity(id);
    setState(() {
      _loadData();
    });
  }

  Future<void> _openForm([Activity? activity]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActivityAdd(activity: activity)),
    );

    if (result == true) {
      setState(() {
        _loadData();
      });
    }
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case "course":
        return Colors.orange.shade200;
      case "marche":
        return Colors.green.shade200;
      case "velo":
        return Colors.blue.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suivi de l'activité physique"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
          await _activitiesFuture;
        },
        child: ListView(
          children: [
            // 🔹 ACTIVITÉ PRÉFÉRÉE
            FutureBuilder<Map<String, dynamic>?>(
              future: _favoriteActivityFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) return const SizedBox();

                final fav = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade700),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 32),
                        const SizedBox(width: 10),
                        Text(
                          "Votre activité préférée : ${fav['type']} (${fav['count']} fois)",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 🔹 LISTE DES ACTIVITÉS
            FutureBuilder<List<Activity>>(
              future: _activitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: CircularProgressIndicator(),
                      ));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Text(
                        "Aucune activité enregistrée",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                final activities = snapshot.data!;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final a = activities[index];
                    final dateStr =
                    DateFormat.yMMMd().format(a.date as DateTime);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      color: _colorForType(a.type),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: const Icon(Icons.fitness_center, size: 32),
                        title: Text(
                          "${a.type} - ${a.duration} min",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${a.calories} kcal • $dateStr",
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                              const Icon(Icons.edit, color: Colors.black87),
                              onPressed: () => _openForm(a),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => _deleteActivity(a.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
