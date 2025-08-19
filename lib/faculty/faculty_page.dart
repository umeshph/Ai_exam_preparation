import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_exam_prep/faculty/view_courses.dart';

class FacultyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Faculty Page")),
      body: ViewCourses(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseDialog(context),
        child: Icon(Icons.add),
        tooltip: "Add New Course",
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final TextEditingController courseIdController = TextEditingController();
    final TextEditingController courseTitleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController fileUrlController = TextEditingController();
    final TextEditingController topicsCoveredController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Course"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: courseIdController, decoration: InputDecoration(labelText: "Course ID")),
                SizedBox(height: 10),
                TextField(controller: courseTitleController, decoration: InputDecoration(labelText: "Course Title")),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Description", alignLabelWithHint: true),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                TextField(controller: fileUrlController, decoration: InputDecoration(labelText: "File URL")),
                SizedBox(height: 10),
                TextField(
                  controller: topicsCoveredController,
                  decoration: InputDecoration(labelText: "Topics Covered"),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (courseIdController.text.isEmpty ||
                    courseTitleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    fileUrlController.text.isEmpty ||
                    topicsCoveredController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all fields.")));
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('courses').doc(courseIdController.text).set({
                    'course_id': courseIdController.text,
                    'title': courseTitleController.text,
                    'description': descriptionController.text,
                    'file_url': fileUrlController.text,
                    'topics_covered': topicsCoveredController.text,
                    'uploaded_at': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Course added successfully!")));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
