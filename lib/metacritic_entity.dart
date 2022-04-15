import 'package:metacritic_request/review.dart';

class MetacriticEntity {
  final String type;
  final String name;
  final String developers;
  final String publishers;
  final String gernes;
  final String rating;
  final List<Review> reviews;
  final dynamic metaRating;
  String desc;
  DateTime? date;

  MetacriticEntity({
    this.type = "",
    this.developers = "",
    this.publishers = "",
    this.gernes = "",
    this.rating = "",
    this.metaRating = "",
    this.name = "",
    this.desc = "",
    this.date = null,
    this.reviews = const [],
  });
}
