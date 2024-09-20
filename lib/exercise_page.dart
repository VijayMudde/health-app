import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_exercises_page.dart'; // Import the new page

class ExercisePage extends StatelessWidget {
  // Fetch categories from Firestore
  Stream<QuerySnapshot> fetchCategories() {
    return FirebaseFirestore.instance.collection('exercise_videos').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar( title: const Text ('Exercise plan'),),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No categories available', style: TextStyle(color: Colors.white)));
          }

          final categories = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index].data() as Map<String, dynamic>;
                    final name = category['name'] ?? 'Unknown';
                    final icon = category['icon'] ?? '🏋️‍♂️';


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
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryExercisesPage(categoryName: name, id: category['id'],),
                            ),
                          );
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
