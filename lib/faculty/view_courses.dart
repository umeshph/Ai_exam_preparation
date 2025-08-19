import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; 

class ViewCourses extends StatelessWidget {
  Future<void> launchFileUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch URL: $url")),
      );
    }
  }

  void openEditDialog(BuildContext context, QueryDocumentSnapshot course) {
    TextEditingController courseIdController = TextEditingController(text: course['course_id']);
    TextEditingController titleController = TextEditingController(text: course['title']);
    TextEditingController descriptionController = TextEditingController(text: course['description']);
    TextEditingController fileUrlController = TextEditingController(text: course['file_url']);
    TextEditingController topicsCoveredController = TextEditingController(text: course['topics_covered'] ?? "");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Course"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: courseIdController, decoration: InputDecoration(labelText: "Course ID")),
                SizedBox(height: 10),
                TextField(controller: titleController, decoration: InputDecoration(labelText: "Course Title")),
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
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('courses').doc(course.id).delete();
                Navigator.pop(context); 
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Course deleted successfully!")),
                );
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('courses').doc(course.id).update({
                  'course_id': courseIdController.text,
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'file_url': fileUrlController.text,
                  'topics_covered': topicsCoveredController.text,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Course updated successfully!")),
                );
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course['description'] ?? "No Description"),
                      SizedBox(height: 4),
                      Text("Topics: ${course['topics_covered'] ?? "Not Provided"}", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  onTap: () => openEditDialog(context, course), 
                  trailing: ElevatedButton(
                    onPressed: () {
                      final String? fileUrl = course['file_url'];
                      if (fileUrl != null && fileUrl.isNotEmpty) {
                        launchFileUrl(fileUrl, context); 
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("File URL is not available!")),
                        );
                      }
                    },
                    child: Text("Uploaded PDF"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
