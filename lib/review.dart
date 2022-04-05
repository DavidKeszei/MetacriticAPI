class Review {
  final String author;
  final String content;
  final double score;
  final DateTime? date;
  final ReviewType reviewType;

  Review({
    required this.author,
    required this.reviewType,
    this.score = 0,
    this.date = null,
    this.content = "",
  });
}

enum ReviewType { Critic, User }
