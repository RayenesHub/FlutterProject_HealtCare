import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../db/gratitude_db.dart';
import '../../entities/Gratitude.dart';


class GratitudeScreen extends StatefulWidget {
  const GratitudeScreen({super.key});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> {
  List<GratitudeEntry> _entries = [];
  final _controller = TextEditingController();
  int? _userId;
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    if (id != null) {
      setState(() => _userId = id);
      _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    if (_userId == null) return;
    final entries = await GratitudeDB.getEntries(_userId!, today);
    setState(() => _entries = entries);
  }

  void _showEntryDialog({GratitudeEntry? entry}) {
    if (entry != null) _controller.text = entry.content;
    else _controller.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(entry == null ? "Ajouter une gratitude" : "Modifier la gratitude"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "Ex: J'ai apprécié ma journée"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_controller.text.isEmpty) return;
              if (entry == null) {
                await GratitudeDB.addEntry(
                  GratitudeEntry(
                    userId: _userId!,
                    content: _controller.text,
                    date: today,
                  ),
                );
              } else {
                await GratitudeDB.updateEntry(
                  GratitudeEntry(
                    id: entry.id,
                    userId: entry.userId,
                    content: _controller.text,
                    date: entry.date,
                  ),
                );
              }
              _controller.clear();
              _loadEntries();
              Navigator.pop(context);
            },
            child: Text(entry == null ? "Ajouter" : "Modifier"),
          ),
        ],
      ),
    );
  }

  void _deleteEntry(int id) async {
    await GratitudeDB.deleteEntry(id);
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal de Gratitude"),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showEntryDialog(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _entries.isEmpty
            ? const Center(child: Text("Aucune gratitude ajoutée aujourd'hui"))
            : ListView.builder(
          itemCount: _entries.length,
          itemBuilder: (context, index) {
            final entry = _entries[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_emotions, color: Colors.green),
                title: Text(entry.content),
                subtitle: Text("Date: ${entry.date}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
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
      ),
    );
  }
}
