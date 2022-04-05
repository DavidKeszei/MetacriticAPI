import 'package:metacritic_request/review.dart';

class MetacriticEntity {
  final String type;
  final String name;
  final dynamic metaRating;
  final List<Review> reviews;
  String desc;
  DateTime? date;

  MetacriticEntity({
    this.type = "",
    this.name = "",
    this.desc = "",
    this.date = null,
    this.metaRating = 0,
    this.reviews = const [],
  });
}

class MetacriticGameEntity extends MetacriticEntity {
  final String developers;
  final String publishers;
  final String gernes;
  final String rating;

  MetacriticGameEntity({
    this.developers = "",
    this.publishers = "",
    this.gernes = "",
    this.rating = "",
    dynamic metaRating = "",
    String name = "",
    String desc = "",
    DateTime? date = null,
    List<Review> reviews = const [],
  }) : super(
            name: name,
            metaRating: metaRating,
            date: date,
            reviews: reviews,
            desc: desc,
            type: "Game");
}
