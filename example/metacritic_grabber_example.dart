import 'package:metacritic_request/metacritic_entity.dart';
import 'package:metacritic_request/metacritic_api.dart';
import 'package:metacritic_request/review.dart';

void main() {
  test();
}

void test() async {
  //Return a entity, wich contains God Of War game propeties
  //Example result:
  //  - name: God Of War
  //  - publisher(s): PlayStation Studios & PlayStation PC
  //  - devloper(s): SCE Santa Monica
  //  - gerne: Action Adventure & Linear
  //  - score / meta rating: 93
  //  - etc...
  MetacriticEntity entity = await MetaCriticAPI.instance
      .getMetacriticData(game: "God of War", platform: "PC");

  //Return a list, wich contains all reviews the specified game
  //(Example: God of War, PC version);
  List<Review> reviews = await MetaCriticAPI.instance.getReviews(
    entity.name,
    entity.platfroms[0],
  );

  //Retrieve all item(s) name and platform, wich equal the input
  //Example
  //  - Name: God Of War,
  //  - Platform: PS4 / Playstation 4
  //  - Search Page Index: null (We search every existing pages)
  //Result: 6 game
  //Result format: "game name->platform"
  List<String> entities = await MetaCriticAPI.instance
      .searchFor(name: "God Of War", platform: "PC");

  //Return a list of Uri, wich contains the founded image(s)
  //Example:
  //  - Name: Call of Duty: Modern Warfare
  //  - Year: 2019
  List<Uri> images = await MetaCriticAPI.instance
      .getCovers(name: "Call of Duty: Modern Warfare", year: 2019);

  //If you don't like the prefabricated object
  //or have another reason convert the entity a .json object.
  String jsonEntity = entity.toJSON(plusArgs: {"covers": images});
}
