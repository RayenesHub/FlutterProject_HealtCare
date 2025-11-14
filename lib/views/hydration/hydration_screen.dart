import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthcare/db/hydration_db.dart';
import 'package:healthcare/entities/hydration_model.dart';
import 'package:healthcare/db/DBHelper.dart';
import 'package:healthcare/entities/user_model.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../components/water_fullscreen_animation.dart';
import 'hydration_quiz_screen.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int? _userId;
  List<Map<String, dynamic>> _weekData = [];
  List<HydrationEntry> _entries = [];
  double _dailyGoal = 2000;
  final _quantityCtrl = TextEditingController();

  double _calculateDailyGoal(int age, double weight) {
    if (age <= 55) return weight * 35;
    if (age <= 65) return weight * 30;
    return weight * 25;
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    if (id != null) {
      final user = await DBHelper.getUserById(id);
      if (user != null) {
        setState(() {
          _userId = id;
          _dailyGoal = _calculateDailyGoal(user.age, user.weight);
        });
        _loadEntries();
      }
    }
  }

  Future<void> _loadEntries() async {
    if (_userId == null) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final entries = await HydrationDB.getEntriesForDate(_userId!, today);
    final weekData = await HydrationDB.getLast7DaysTotals(_userId!);

    setState(() {
      _entries = entries;
      _weekData = weekData.reversed.toList();
    });
  }

  void _showWaterAnimation() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) {
        return WaterFullScreenAnimation(
          onFinished: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  Future<void> _addOrUpdateEntry({HydrationEntry? entry}) async {
    if (_quantityCtrl.text.isEmpty) return;
    final quantity = double.tryParse(_quantityCtrl.text);
    if (quantity == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (entry == null) {
      await HydrationDB.addEntry(HydrationEntry(
        userId: _userId!,
        quantity: quantity,
        date: today,
      ));
    } else {
      await HydrationDB.updateEntry(HydrationEntry(
        id: entry.id,
        userId: entry.userId,
        quantity: quantity,
        date: entry.date,
      ));
    }

    _quantityCtrl.clear();
    await _loadEntries();
    Navigator.pop(context);

    _showWaterAnimation();
  }

  Future<void> _deleteEntry(int id) async {
    await HydrationDB.deleteEntry(id);
    _loadEntries();
  }

  void _showEntryDialog({HydrationEntry? entry}) {
    if (entry != null) {
      _quantityCtrl.text = entry.quantity.toString();
    } else {
      _quantityCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(entry == null ? "Ajouter de l'eau" : "Modifier l'entrée"),
        content: TextField(
          controller: _quantityCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Quantité en ml",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => _addOrUpdateEntry(entry: entry),
            child: Text(entry == null ? "Ajouter" : "Modifier"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _entries.fold(0.0, (sum, e) => sum + e.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion d'Hydratation"),
        backgroundColor: Colors.green,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showEntryDialog(),
        child: const Icon(Icons.add),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🌸 Bouton Quiz centré & stylé
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8BBD0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.quiz, color: Colors.white, size: 26),
                label: const Text(
                  "Quiz Hydratation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HydrationQuizScreen()),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // 🎯 Objectif
            Text(
              "Objectif personnalisé : ${_dailyGoal.toStringAsFixed(0)} ml",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 6),

            LinearProgressIndicator(
              value: (total / _dailyGoal).clamp(0.0, 1.0),
              minHeight: 12,
              color: Colors.green,
              backgroundColor: Colors.grey.shade300,
            ),

            const SizedBox(height: 12),

            Text(
              "Total bu aujourd’hui : ${total.toStringAsFixed(0)} ml",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 25),

            // 🟡🔵 PIE CHART BLEU + JAUNE
            const Text(
              "Hydratation du jour",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Center(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(
                        color: Colors.blue,
                        value: (total / _dailyGoal * 100).clamp(0, 100),
                        title:
                        "${((total / _dailyGoal) * 100).clamp(0, 100).toStringAsFixed(0)}%",
                        titleStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        radius: 60,
                      ),
                      PieChartSectionData(
                        color: Colors.yellow.shade600,
                        value: (100 - (total / _dailyGoal * 100)).clamp(0, 100),
                        title: "",
                        radius: 60,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 📊 GRAPHIQUE 7 DERNIERS JOURS
            const Text(
              "Progression sur les 7 derniers jours",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 35),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= _weekData.length) {
                            return const SizedBox();
                          }
                          final date = _weekData[i]['date'];
                          final day =
                          DateFormat('E').format(DateTime.parse(date));
                          return Text(day.substring(0, 1));
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(_weekData.length, (i) {
                    final total = _weekData[i]['total'] ?? 0.0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: total.toDouble(),
                          color: Colors.green,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📄 LISTE DES ENTRÉES
            if (_entries.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text("Aucune donnée enregistrée aujourd’hui 🥤"),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Card(
                    child: ListTile(
                      leading:
                      const Icon(Icons.local_drink, color: Colors.blue),
                      title: Text("${entry.quantity.toStringAsFixed(0)} ml"),
                      subtitle: Text("Date : ${entry.date}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                            const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _showEntryDialog(entry: entry),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEntry(entry.id!),
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
    );
  }
}
