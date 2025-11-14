import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../db/Humeur_DB.dart';
import '../../entities/humeur.dart';

class HumeurStatsScreen extends StatelessWidget {
  final db = HumeurDB();

  HumeurStatsScreen({super.key});

  // Retourne une couleur selon le niveau
  Color _colorForNiveau(int niveau) {
    switch (niveau) {
      case 5:
      case 4:
        return Colors.green;
      case 3:
        return Colors.grey;
      case 2:
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  // Retourne l'émoji selon le niveau
  String _emojiForNiveau(int niveau) {
    switch (niveau) {
      case 5:
      case 4:
        return "😄";
      case 3:
        return "😐";
      case 2:
        return "😔";
      default:
        return "😤";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Statistiques humeur")),
      body: FutureBuilder<List<Humeur>>(
        future: db.getHumeurs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucune donnée disponible"));
          }

          final humeurs = snapshot.data!;
          final spots = humeurs
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.niveau.toDouble()))
              .toList();

          return Padding(
            padding: EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                minY: 1,
                maxY: 5,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < humeurs.length) {
                          return Text(
                            "${index + 1}",
                            style: TextStyle(fontSize: 12),
                          );
                        }
                        return SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        return Text(
                          _emojiForNiveau(value.toInt()),
                          style: TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: _colorForNiveau(humeurs[index].niveau),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.4),
                          Colors.blue.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
