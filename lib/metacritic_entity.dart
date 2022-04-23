class MetacriticEntity {
  final String type;
  final String name;
  final String developers;
  final String publishers;
  final List<String> platfroms;
  final String gernes;
  final String rating;
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
    this.platfroms = const [],
  });

  String toJSON({Map<String, dynamic>? plusArgs = null}) {
    Map<String, dynamic> values = {
      "name": name,
      "developers": developers.split(" & "),
      "publishers": publishers.split(" & "),
      "platforms": platfroms,
      "genres": gernes.split(' & '),
      "rating": rating,
      "score": metaRating,
    };

    if (plusArgs != null) {
      values.addAll(plusArgs);
    }

    String result = "{\n";

    for (int i = 0; i < values.length; i++) {
      String lineEnd = i == values.length - 1 ? ' ' : ',';
      dynamic currentObject = values.values.elementAt(i);

      if (currentObject is List) {
        result += "\t\"${values.keys.elementAt(i)}\": [\n";

        for (int i = 0; i < currentObject.length; i++) {
          String lineEndInArray = i == currentObject.length - 1 ? ' ' : ',';
          result += "\t\t\"${currentObject[i]}\"${lineEndInArray}\n";
        }

        result += "\t],\n";
      } else {
        if (currentObject is DateTime) {
          String date =
              "${currentObject.year}/${currentObject.month}/${currentObject.day}";

          result +=
              "\t\"${values.keys.elementAt(i)}\": \"${date}\"${lineEnd}\n";
        } else if (currentObject is String || currentObject is Uri) {
          result +=
              "\t\"${values.keys.elementAt(i)}\": \"${currentObject}\"${lineEnd}\n";
        } else {
          result +=
              "\t\"${values.keys.elementAt(i)}\": ${currentObject}${lineEnd}\n";
        }
      }
    }

    result += "}";

    return result;
  }
}
