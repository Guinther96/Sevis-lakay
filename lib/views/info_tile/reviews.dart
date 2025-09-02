import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WriteReviewScreen extends StatefulWidget {
  final String businessId; // ID du business à reviewer
  const WriteReviewScreen({super.key, required this.businessId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _reviewController = TextEditingController();
  int rating = 0;
  bool isLoading = true;
  bool canWriteReview = false;

  @override
  void initState() {
    super.initState();
    checkReviewPermission();
  }

  Future<void> submitReview() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final userId = user.id;
    final comment = _reviewController.text.trim();

    if (rating == 0 || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a rating and a review")),
      );
      return;
    }

    try {
      await supabase.from('reviews').insert({
        'user_id': userId, // ⚠️ doit être UUID
        'business_id': widget.businessId, // ⚠️ aussi UUID
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now()
            .toUtc()
            .toIso8601String(), // facultatif si la colonne a une valeur par défaut
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting review: $e")));
    }
  }

  Future<void> checkReviewPermission() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        canWriteReview = false;
      });
      return;
    }

    final userId = user.id;

    // Vérifie si l’utilisateur a déjà laissé un avis
    final response = await supabase
        .from('reviews')
        .select()
        .eq('user_id', userId) // <-- doit être une string uuid
        .eq('business_id', widget.businessId) // <-- doit être une string uuid
        .limit(1)
        .maybeSingle();

    if (response == null) {
      setState(() {
        canWriteReview = true;
        isLoading = false;
      });
    } else {
      setState(() {
        canWriteReview = false;
        isLoading = false;
      });
    }
  }

  Widget buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          rating = index;
        });
      },
      icon: Icon(
        index <= rating ? Icons.star : Icons.star_border,
        color: Colors.orange,
        size: 36,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!canWriteReview) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Write a Review"),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black),
        ),
        body: const Center(
          child: Text(
            "You are not allowed to write a review for this business.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a Review"),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Rate this Business',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => buildStar(index + 1)),
            ),
            const Center(
              child: Text(
                'Tap to rate',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Review',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  submitReview();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Review',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
