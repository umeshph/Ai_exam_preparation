import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewCoursesForStudents extends StatelessWidget {
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

  void openViewDialog(BuildContext context, QueryDocumentSnapshot course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(course['title'] ?? "No Title"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Course ID: ${course['course_id'] ?? "N/A"}"),
                SizedBox(height: 10),
                Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(course['description'] ?? "No Description"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Courses')),
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
                  onTap: () => openViewDialog(context, course), 
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
                    child: Text("Download Notes"),
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
