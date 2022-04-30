class MetacriticEntity {
  final String name;
  final List<String> developers;
  final List<String> publishers;
  final List<String> platfroms;
  final List<String> gernes;
  final String rating;
  final dynamic metaRating;
  String desc;
  DateTime? date;

  MetacriticEntity({
    this.name = "",
    this.metaRating = "",
    this.rating = "",
    this.gernes = const [],
    this.desc = "",
    this.date = null,
    this.publishers = const [],
    this.developers = const [],
    this.platfroms = const [],
  });

  String toJSON({Map<String, dynamic>? plusArgs = null}) {
    //Fetch all data
    Map<String, dynamic> values = {
      "name": name,
      "rating": rating,
      "score": metaRating,
      "developers": developers,
      "publishers": publishers,
      "platforms": platfroms,
      "genres": gernes,
    };

    //Add plus element to Map<String, dynamic>
    if (plusArgs != null) {
      values.addAll(plusArgs);
    }

    //Write the JSON String
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
