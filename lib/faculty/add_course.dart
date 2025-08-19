import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCourseTab extends StatelessWidget {
  final TextEditingController courseIdController = TextEditingController();
  final TextEditingController courseTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController fileUrlController = TextEditingController(); 
  final TextEditingController topicsCoveredController = TextEditingController(); 

  Future<void> saveCourseToFirestore(
      String courseId, String title, String description, String fileUrl, String topicsCovered) async {
    try {
      await FirebaseFirestore.instance.collection('courses').doc(courseId).set({
        'course_id': courseId,
        'title': title,
        'description': description,
        'file_url': fileUrl,
        'topics_covered': topicsCovered,
        'uploaded_at': FieldValue.serverTimestamp(),
      });
      print("Course successfully saved with ID: $courseId!");
    } catch (e) {
      print("Firestore Error: $e");
    }
  }

  void submitCourse(BuildContext context) async {
    if (courseIdController.text.isEmpty ||
        courseTitleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        fileUrlController.text.isEmpty ||
        topicsCoveredController.text.isEmpty) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    try {
      print("Submitting course data...");
      print("Course ID: ${courseIdController.text}");
      print("Title: ${courseTitleController.text}");
      print("Description: ${descriptionController.text}");
      print("File URL: ${fileUrlController.text}");
      print("Topics Covered: ${topicsCoveredController.text}");

      await saveCourseToFirestore(
        courseIdController.text,
        courseTitleController.text,
        descriptionController.text,
        fileUrlController.text,
        topicsCoveredController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Course added successfully!")),
      );

      courseIdController.clear();
      courseTitleController.clear();
      descriptionController.clear();
      fileUrlController.clear();
      topicsCoveredController.clear(); 
    } catch (e) {
      print("Error during course submission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Add Course"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: courseIdController,
                        decoration: InputDecoration(labelText: "Course ID"),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: courseTitleController,
                        decoration: InputDecoration(labelText: "Course Title"),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: "Description",
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: fileUrlController,
                        decoration: InputDecoration(labelText: "File URL"),
                      ),
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      submitCourse(context); 
                      Navigator.pop(context); 
                    },
                    child: Text("Submit"),
                  ),
                ],
              );
            },
          );
        },
        child: Text("Add Course"),
      ),
    );
  }
}
