import 'dart:math';
import 'package:flutter/material.dart';

class HydrationQuizScreen extends StatefulWidget {
  const HydrationQuizScreen({super.key});

  @override
  _HydrationQuizScreenState createState() => _HydrationQuizScreenState();
}

class _HydrationQuizScreenState extends State<HydrationQuizScreen> {
  final List<Map<String, dynamic>> _questionPool = [
    {
      "question": "Quelle quantité d’eau est recommandée par jour ?",
      "answers": ["1 litre", "1.5 à 2 litres", "3 litres", "500 ml"],
      "correct": 1
    },
    {
      "question": "Quel signe indique une déshydratation ?",
      "answers": ["Urines foncées", "Urines claires", "Beaucoup d’énergie", "Bouche fraîche"],
      "correct": 0
    },
    {
      "question": "Quel aliment hydrate le plus ?",
      "answers": ["Chips", "Pastèque", "Pain", "Bonbons"],
      "correct": 1
    },
    {
      "question": "Quel moment est idéal pour boire ?",
      "answers": [
        "Uniquement le soir",
        "Quand on a très soif",
        "Régulièrement toute la journée",
        "Jamais pendant un repas"
      ],
      "correct": 2
    },
    {
      "question": "Quelle boisson déshydrate le plus ?",
      "answers": ["Eau", "Tisane", "Soda sucré", "Jus sans sucre"],
      "correct": 2
    },
    {
      "question": "Quelle partie du corps contient le plus d’eau ?",
      "answers": ["Les os", "Le sang", "Les cheveux", "Les ongles"],
      "correct": 1
    },
    {
      "question": "Boire assez d’eau aide à :",
      "answers": [
        "Améliorer la concentration",
        "Augmenter la fièvre",
        "Rendre malade",
        "Sécher la peau"
      ],
      "correct": 0
    },
  ];

  late List<Map<String, dynamic>> _questions;
  int _currentQuestion = 0;
  int _score = 0;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _generateNewQuiz();
  }

  void _generateNewQuiz() {
    final random = Random();
    final poolCopy = List<Map<String, dynamic>>.from(_questionPool)..shuffle();
    final selected = poolCopy.take(5).toList();

    _questions = selected.map((q) {
      final answers = List<String>.from(q["answers"]);
      answers.shuffle(random);

      final correctAnswer = q["answers"][q["correct"]];
      final correctIndex = answers.indexOf(correctAnswer);

      return {
        "question": q["question"],
        "answers": answers,
        "correct": correctIndex,
      };
    }).toList();

    _currentQuestion = 0;
    _score = 0;
    _answered = false;
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _answered = true;
      if (index == _questions[_currentQuestion]["correct"]) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (_currentQuestion + 1 < _questions.length) {
        setState(() {
          _currentQuestion++;
          _answered = false;
        });
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🎉 Résultat du Quiz"),
        content: Text(
          "Votre score : $_score / ${_questions.length}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _generateNewQuiz());
            },
            child: const Text("Nouveau quiz"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Retour"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F6), // 🌸 Rose très clair
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BBD0), // Rose pastel
        title: const Text("Quiz Hydratation"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Question ${_currentQuestion + 1} / ${_questions.length}",
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 20),

              // ======= CARTE BLANCHE AVEC SHADOW =======
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade100.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      question["question"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),

                    ...List.generate(question["answers"].length, (index) {
                      final isCorrect = index == question["correct"];

                      Color color;
                      if (!_answered) {
                        color = Colors.green.shade300;
                      } else {
                        color = isCorrect ? Colors.green : Colors.pinkAccent;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => _selectAnswer(index),
                          child: Text(
                            question["answers"][index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
