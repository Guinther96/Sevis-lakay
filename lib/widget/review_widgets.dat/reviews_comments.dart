import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewCommentsScreen extends StatefulWidget {
  final String reviewId;
  const ReviewCommentsScreen({super.key, required this.reviewId});

  @override
  State<ReviewCommentsScreen> createState() => _ReviewCommentsScreenState();
}

class _ReviewCommentsScreenState extends State<ReviewCommentsScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  List comments = [];

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final response = await supabase
        .from('review_comments')
        .select('comment, created_at, user_id')
        .eq('review_id', widget.reviewId)
        .order('created_at');

    setState(() {
      comments = response;
    });
  }

  Future<void> addComment() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (_controller.text.trim().isEmpty) return;

    await supabase.from('review_comments').insert({
      'review_id': widget.reviewId,
      'user_id': user.id,
      'comment': _controller.text.trim(),
    });

    _controller.clear();
    fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Commentaires")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final c = comments[index];
                return ListTile(
                  title: Text(c['comment']),
                  subtitle: Text(c['created_at']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Écrire un commentaire...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(onPressed: addComment, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
