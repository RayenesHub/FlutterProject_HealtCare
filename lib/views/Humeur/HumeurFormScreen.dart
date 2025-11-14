import 'package:flutter/material.dart';
import '../../db/Humeur_DB.dart';
import '../../entities/humeur.dart';

class HumeurFormScreen extends StatefulWidget {
  final Humeur? humeur;
  const HumeurFormScreen({super.key, this.humeur});

  @override
  State<HumeurFormScreen> createState() => _HumeurFormScreenState();
}

class _HumeurFormScreenState extends State<HumeurFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _situation = "😄 Heureux"; // valeur par défaut
  String _commentaire = '';
  final db = HumeurDB();

  // Liste des situations possibles
  final List<String> _situations = [
    "😄 Heureux",
    "😐 Neutre",
    "😔 Triste",
    "😤 Stressé",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.humeur != null) {
      // Convertir le niveau en situation
      switch (widget.humeur!.niveau) {
        case 5:
        case 4:
          _situation = "😄 Heureux";
          break;
        case 3:
          _situation = "😐 Neutre";
          break;
        case 2:
          _situation = "😔 Triste";
          break;
        default:
          _situation = "😤 Stressé";
      }
      _commentaire = widget.humeur!.commentaire;
    }
  }

  // Retourne la couleur selon la situation
  Color _colorForSituation(String situation) {
    switch (situation) {
      case "😄 Heureux":
        return Colors.green.shade400;
      case "😐 Neutre":
        return Colors.grey.shade400;
      case "😔 Triste":
        return Colors.blue.shade300;
      case "😤 Stressé":
        return Colors.orange.shade300;
      default:
        return Colors.grey.shade200;
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Convertir la situation en niveau
      int niveau;
      switch (_situation) {
        case "😄 Heureux":
          niveau = 5;
          break;
        case "😐 Neutre":
          niveau = 3;
          break;
        case "😔 Triste":
          niveau = 2;
          break;
        default:
          niveau = 1;
      }

      final humeur = Humeur(
        id: widget.humeur?.id ?? '',
        date: DateTime.now(),
        niveau: niveau,
        commentaire: _commentaire,
      );

      if (widget.humeur == null) {
        await db.addHumeur(humeur);
      } else {
        await db.updateHumeur(widget.humeur!.id, humeur);
      }

      // Afficher popup motivant si pas Heureux
      if (_situation != "😄 Heureux") {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Motivation"),
            content: Text(
              _situation == "😐 Neutre"
                  ? "Reste positif, chaque jour compte ! 🌟"
                  : _situation == "😔 Triste"
                  ? "Courage ! Les jours meilleurs arrivent 💛"
                  : "Respire profondément, tu peux gérer ce stress 💪",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Merci"),
              ),
            ],
          ),
        );
      }

      FocusScope.of(context).unfocus();
      Navigator.pop(context, true); // fermer le formulaire après popup
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(widget.humeur == null ? "Nouvelle humeur" : "Modifier humeur"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Comment vous sentez-vous aujourd'hui ?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Émoji principal
                  Text(
                    _situation.characters.first,
                    style: TextStyle(
                      fontSize: 48,
                      color: _colorForSituation(_situation),
                    ),
                  ),
                  SizedBox(height: 20),

                  // ChoiceChip pour sélectionner la situation
                  Wrap(
                    spacing: 10,
                    children: _situations.map((sit) {
                      return ChoiceChip(
                        label: Text(sit),
                        selected: _situation == sit,
                        selectedColor:
                        _colorForSituation(sit).withOpacity(0.5),
                        onSelected: (_) => setState(() => _situation = sit),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  // Commentaire
                  TextFormField(
                    initialValue: _commentaire,
                    decoration: InputDecoration(
                      labelText: "Commentaire (optionnel)",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSaved: (v) => _commentaire = v ?? '',
                  ),
                  SizedBox(height: 30),

                  // Bouton enregistrer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text("Enregistrer"),
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
