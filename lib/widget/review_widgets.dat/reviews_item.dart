import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sevis_lakay/widget/review_widgets.dat/reviews_comments.dart';

class ReviewItem extends StatefulWidget {
  final Map review;
  const ReviewItem({super.key, required this.review});

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  final supabase = Supabase.instance.client;
  bool isLiked = false;
  int likesCount = 0;
  bool working = false;

  @override
  void initState() {
    super.initState();
    fetchLikes();
  }

  Future<void> fetchLikes() async {
    final user = supabase.auth.currentUser;
    final reviewId = widget.review['id'];

    if (reviewId == null) return;

    try {
      final likesRes = await supabase
          .from('review_likes')
          .select('user_id')
          .eq('review_id', reviewId);

      final list = List<Map<String, dynamic>>.from(likesRes ?? []);
      setState(() {
        likesCount = list.length;
        isLiked = user != null && list.any((l) => l['user_id'] == user.id);
      });
    } catch (e) {
      debugPrint('fetchLikes error: $e');
    }
  }

  Future<void> toggleLike() async {
    if (working) return;
    setState(() => working = true);

    final user = supabase.auth.currentUser;
    final reviewId = widget.review['id'];

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Connecte-toi pour liker.")));
      setState(() => working = false);
      return;
    }
    if (reviewId == null) {
      debugPrint('reviewId est null');
      setState(() => working = false);
      return;
    }

    try {
      if (isLiked) {
        await supabase
            .from('review_likes')
            .delete()
            .eq('review_id', reviewId)
            .eq('user_id', user.id);
      } else {
        await supabase.from('review_likes').insert({
          'review_id': reviewId,
          'user_id': user.id,
        });
      }
      await fetchLikes();
    } catch (e) {
      debugPrint('toggleLike error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur like: $e')));
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  void openComments() {
    final reviewId = widget.review['id'];
    if (reviewId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewCommentsScreen(reviewId: reviewId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // texte du review
            Text(
              (widget.review['comment'] ?? '').toString(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            // actions
            Row(
              children: [
                IconButton(
                  onPressed: working ? null : toggleLike,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                ),
                Text('$likesCount'),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: openComments,
                  icon: const Icon(Icons.comment),
                ),
                const Text("Commentaires"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
