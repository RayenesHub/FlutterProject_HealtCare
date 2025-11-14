import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../db/Humeur_DB.dart';
import '../../entities/humeur.dart';
import 'HumeurFormScreen.dart';
import 'HumeurStatsScreen.dart';

class HumeurListScreen extends StatefulWidget {
  const HumeurListScreen({super.key});

  @override
  State<HumeurListScreen> createState() => _HumeurListScreenState();
}

class _HumeurListScreenState extends State<HumeurListScreen> {
  final HumeurDB db = HumeurDB();
  late Future<List<Humeur>> _humeursFuture;

  @override
  void initState() {
    super.initState();
    _loadHumeurs();
  }

  void _loadHumeurs() {
    _humeursFuture = db.getHumeurs();
  }

  Future<void> _deleteHumeur(String id) async {
    await db.deleteHumeur(id);
    setState(() {
      _loadHumeurs();
    });
  }

  Future<void> _openForm([Humeur? humeur]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HumeurFormScreen(humeur: humeur)),
    );
    if (result == true) {
      setState(() {
        _loadHumeurs();
      });
    }
  }

  // Convertir le niveau en situation pour affichage
  String _situationFromNiveau(int niveau) {
    switch (niveau) {
      case 5:
      case 4:
        return "😄 Heureux";
      case 3:
        return "😐 Neutre";
      case 2:
        return "😔 Triste";
      default:
        return "😤 Stressé";
    }
  }

  // Couleur selon la situation
  Color _colorForSituation(String situation) {
    switch (situation) {
      case "😄 Heureux":
        return Colors.green.shade300;
      case "😐 Neutre":
        return Colors.grey.shade300;
      case "😔 Triste":
        return Colors.blue.shade200;
      case "😤 Stressé":
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Suivi de l'humeur"),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HumeurStatsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadHumeurs();
          });
          await _humeursFuture;
        },
        child: FutureBuilder<List<Humeur>>(
          future: _humeursFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "Aucune humeur enregistrée",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final humeurs = snapshot.data!;
            return ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: humeurs.length,
              separatorBuilder: (_, __) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final humeur = humeurs[index];
                final situation = _situationFromNiveau(humeur.niveau);
                final dateStr = DateFormat.yMMMd().format(humeur.date);

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  color: _colorForSituation(situation),
                  child: ListTile(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Text(
                      situation.characters.first,
                      style: TextStyle(fontSize: 36),
                    ),
                    title: Text(
                      situation,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (humeur.commentaire.isNotEmpty)
                          Text(humeur.commentaire),
                        SizedBox(height: 4),
                        Text(dateStr,
                            style: TextStyle(
                                fontSize: 12, fontStyle: FontStyle.italic)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black87),
                          onPressed: () => _openForm(humeur),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteHumeur(humeur.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _openForm(),
      ),
    );
  }
}
