import 'package:ai_exam_prep/student/student_course.dart';
import 'package:ai_exam_prep/student/student_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  final String studentId;

  StudentDashboard({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: studentId)
          .limit(1)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(body: Center(child: Text("User not found")));
        }

        final userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final name = userData['name'] ?? 'Student';

        return Scaffold(
          appBar: AppBar(title: Text('Student Dashboard'), centerTitle: true),
          backgroundColor: Colors.grey[100],
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 90,
                    backgroundImage: NetworkImage(
                      'https://st3.depositphotos.com/15648834/17930/v/450/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg',
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Welcome Back, $name!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("We're glad to see you again.",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  SizedBox(height: 32),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ViewCoursesForStudents()),
                          );
                        },
                        child: DashboardCard(
                          title: 'Courses',
                          description: 'View courses',
                          icon: Icons.book,
                          color: Colors.blue,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ViewCoursesPage()),
                          );
                        },
                        child: DashboardCard(
                          title: 'Tests',
                          description: 'View your tests',
                          icon: Icons.edit,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DashboardCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(description, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
