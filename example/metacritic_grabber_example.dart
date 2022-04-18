import 'package:metacritic_request/metacritic_entity.dart';
import 'package:metacritic_request/metacritic_api.dart';

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
      .getMetacriticData(game: "God Of War", platform: "PC");

  //Retrieve all item(s) name and platform, wich equal the input
  //Example
  //  - Name: God Of War,
  //  - Platform: PS4 / Playstation 4
  //
  //Result: 6 game
  //REsult format: "game name->platform"
  List<dynamic> entities = await MetaCriticAPI.instance
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
