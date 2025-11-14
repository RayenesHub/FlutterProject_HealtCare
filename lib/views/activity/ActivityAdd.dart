import 'package:flutter/material.dart';
import '../../db/Activity_DBHelper.dart';
import '../../entities/Activity_Model.dart';

class ActivityAdd extends StatefulWidget {
  final Activity? activity; // <-- paramètre optionnel pour l'édition

  const ActivityAdd({Key? key, this.activity}) : super(key: key);

  @override
  State<ActivityAdd> createState() => _ActivityAddState();
}

class _ActivityAddState extends State<ActivityAdd> {
  final _formKey = GlobalKey<FormState>();
  String _type = "Marche";
  int _duration = 30;
  DateTime _date = DateTime.now();

  final ActivityDBHelper _db = ActivityDBHelper();

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _type = widget.activity!.type;
      _duration = widget.activity!.duration;
      _date = widget.activity!.date;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final calories = (_duration * 5); // formule simple (MVP)
    final activity = Activity(
      id: widget.activity?.id,
      type: _type,
      duration: _duration,
      calories: calories,
      date: _date,
    );

    if (widget.activity == null) {
      await _db.insertActivity(activity);
    } else {
      await _db.updateActivity(activity);
    }

    // renvoyer true pour signaler le succès (ActivityList recharge)
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? 'Ajouter activité' : 'Modifier activité'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type d\'activité'),
                items: ['Marche', 'Course', 'Velo', 'Yoga', 'Musculation']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
                onSaved: (v) => _type = v ?? _type,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _duration.toString(),
                decoration: const InputDecoration(labelText: 'Durée (minutes)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Entrez une durée valide';
                  return null;
                },
                onSaved: (v) => _duration = int.parse(v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Date : ${_date.toLocal().toIso8601String().split('T').first}')),
                  TextButton(onPressed: _pickDate, child: const Text('Changer')),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(widget.activity == null ? 'Enregistrer' : 'Mettre à jour'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
