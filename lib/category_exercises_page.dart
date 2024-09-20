import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'video_player_page.dart';

class CategoryExercisesPage extends StatelessWidget {
  final String categoryName;
  final String id;

  CategoryExercisesPage({required this.categoryName, required this.id});

  // Fetch exercises by category from Firestore
  Stream<QuerySnapshot> fetchExercisesByCategory(String category) {
    return FirebaseFirestore.instance
        .collection('exercise_videos')
        .doc(id) // Document for the specific category
        .collection('exercises') // Subcollection containing exercises
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('$categoryName Exercises'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchExercisesByCategory(categoryName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No exercises available for $categoryName',
                    style: TextStyle(color: Colors.white)));
          }

          final exercises = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo Videos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise =
                        exercises[index].data() as Map<String, dynamic>;
                    final name = exercise['name'] ?? 'Unknown';
                    final description =
                        exercise['description'] ?? 'No description available';
                    final videoUrl = exercise['videoUrl'];
                    final icon = exercise['icon'] ?? '🏋️‍♂️';

                    return Card(
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Text(
                          icon,
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        subtitle: Text(
                          description,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          if (videoUrl != null && videoUrl.isNotEmpty) {
                            print(videoUrl);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoPlayerPage(videoUrl: videoUrl),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Video URL is missing')),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
