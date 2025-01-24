import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  Future<void> _likePost(String postId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    final doc = await docRef.get();
    final likes = List<String>.from(doc['likes'] ?? []);

    if (likes.contains(userId)) {
      likes.remove(userId); // Dislike
    } else {
      likes.add(userId); // Like
    }

    await docRef.update({'likes': likes});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed', style: TextStyle(fontFamily: 'Billabong', fontSize: 24)),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final likes = List<String>.from(post['likes'] ?? []);
              final isLiked = likes.contains(FirebaseAuth.instance.currentUser!.uid);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(post['mediaUrl'], fit: BoxFit.cover, height: 250, width: double.infinity),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(post['caption'] ?? '', style: const TextStyle(fontSize: 16)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                          onPressed: () => _likePost(post.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.grey),
                          onPressed: () {
                            Navigator.pushNamed(context, '/comments', arguments: post.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
