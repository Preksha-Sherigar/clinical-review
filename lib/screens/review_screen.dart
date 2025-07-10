// UPDATED review_screen.dart (Enhanced UI + Prevent Deleting Others' Reviews + Home Page Attractive UI)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatefulWidget {
  final String clinicId;
  final String clinicName;

  const ReviewScreen({super.key, required this.clinicId, required this.clinicName});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _reviewCtrl = TextEditingController();
  double _rating = 0;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("clinic")
          .doc(widget.clinicId)
          .collection("reviews")
          .doc(uid)
          .set({
        'text': _reviewCtrl.text.trim(),
        'rating': _rating,
        'userId': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _reviewCtrl.clear();
      setState(() => _rating = 0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit review")),
      );
    }
  }

  Future<void> _tryDeleteReview(String reviewUserId) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    if (currentUid != reviewUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot delete others' reviews.")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("clinic")
        .doc(widget.clinicId)
        .collection("reviews")
        .doc(currentUid)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewRef = FirebaseFirestore.instance
        .collection("clinic")
        .doc(widget.clinicId)
        .collection("reviews");

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.clinicName} Reviews"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 0,
              allowHalfRating: true,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewCtrl,
              decoration: InputDecoration(
                labelText: "Write your review",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Submit Review"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: reviewRef.orderBy("timestamp", descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading reviews"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No reviews yet"));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final review = docs[i];
                      final rating = (review['rating']?.toDouble() ?? 0);
                      final reviewUserId = review['userId'] ?? '';

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.teal.shade50,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            review['text'] ?? "",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: RatingBarIndicator(
                              rating: rating,
                              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                              itemSize: 20,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _tryDeleteReview(reviewUserId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
