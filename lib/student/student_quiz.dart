import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';


class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }
}

void main() {
  runApp(MaterialApp(home: ViewCoursesPage()));
}

class ViewCoursesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Course For Test')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No courses available."));
          }

          final courses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: ListTile(
                  title: Text(course['title'] ?? "No Title"),
                  subtitle: Text(course['description'] ?? "No Description"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DifficultySelectionPage(
                          courseTitle: course['title'] ?? "No Title",
                          topicsCovered: course['topics_covered'] ?? "",
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Page to Select Difficulty
class DifficultySelectionPage extends StatelessWidget {
  final String courseTitle;
  final String topicsCovered;

  DifficultySelectionPage({
    required this.courseTitle,
    required this.topicsCovered,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$courseTitle - Select Difficulty",style: TextStyle(fontSize: 18),)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ["Beginner", "Intermediate", "Advanced"]
            .map((level) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: Text(level),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizPage(
                    courseTitle: courseTitle,
                    topicsCovered: topicsCovered,
                    difficulty: level,
                  ),
                ),
              );
            },
          ),
        ))
            .toList(),
      ),
    );
  }
}

// Quiz Page
class QuizPage extends StatefulWidget {
  final String courseTitle;
  final String topicsCovered;
  final String difficulty;

  QuizPage({
    required this.courseTitle,
    required this.topicsCovered,
    required this.difficulty,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> questions = [];
  List<int?> selectedAnswers = [];
  bool isLoading = true;
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() => isLoading = true);
    questions = await fetchQuestionsFromGemini(widget.topicsCovered, widget.difficulty);
    selectedAnswers = List.filled(questions.length, null);
    setState(() => isLoading = false);
  }

  Future<List<Question>> fetchQuestionsFromGemini(String topics, String difficulty) async {
    try {
      const String apiKey = "";

      final response = await http.post(
        Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text": "Generate 10 multiple choice questions in JSON based on: $topics.\n"
                      "Difficulty: $difficulty.\n"
                      "Format: [{'questionText': '...', 'options': ['...'], 'correctAnswerIndex': 0}]"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String content = data["candidates"][0]["content"]["parts"][0]["text"];

        content = content.trim();
        if (content.startsWith("```json")) {
          content = content.substring(7, content.length - 3).trim();
        }

        final parsed = json.decode(content) as List<dynamic>;
        return parsed.map<Question>((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception("Gemini API error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  void submitQuiz() {
    setState(() => isSubmitted = true);

    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].correctAnswerIndex) {
        score++;
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Test Submitted"),
        content: Text("Your Score: $score / ${questions.length}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> downloadAsPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("${widget.courseTitle} - ${widget.difficulty}", 
              style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 16),
          ...List.generate(questions.length, (i) {
            final q = questions[i];
            final userAns = selectedAnswers[i];
            return pw.Column(children: [
              pw.Text("Q${i + 1}: ${q.questionText}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...List.generate(q.options.length, (j) {
                final isCorrect = j == q.correctAnswerIndex;
                final isSelected = j == userAns;
                final color = isCorrect
                    ? PdfColor.fromInt(0xFF00AA00)
                    : isSelected
                    ? PdfColor.fromInt(0xFFAA0000)
                    : PdfColor.fromInt(0xFF000000);
                return pw.Text("${j + 1}. ${q.options[j]}",
                    style: pw.TextStyle(color: color));
              }),
              pw.SizedBox(height: 10)
            ]);
          }),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/quiz_results.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    OpenFilex.open(filePath);
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading Test...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("${widget.courseTitle} - ${widget.difficulty}",style: TextStyle(fontSize: 18),)),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Q${index + 1}: ${q.questionText}", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(q.options.length, (i) {
                    Color? color;
                    if (isSubmitted) {
                      if (i == q.correctAnswerIndex) {
                        color = Colors.green;
                      } else if (i == selectedAnswers[index]) {
                        color = Colors.red;
                      }
                    }

                    return RadioListTile<int>(
                      value: i,
                      groupValue: selectedAnswers[index],
                      onChanged: isSubmitted
                          ? null
                          : (val) => setState(() => selectedAnswers[index] = val),
                      title: Text(q.options[i], style: TextStyle(color: color)),
                    );
                  })
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: isSubmitted
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: downloadAsPDF, child: Text("Download PDF")),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
        ],
      )
          : ElevatedButton(onPressed: submitQuiz, child: Text("Submit")),
    );
  }
}
