import 'package:metacritic_request/metacritic_entity.dart';
import 'package:metacritic_request/metacritic_api.dart';

void main() {
  test();
}

void test() async {
  DateTime start = DateTime.now();

  //Return a entity, wich contains God Of War game propeties from specifed type and platform (pl: Game - PC)
  //Example result:
  //  - name: God Of War
  //  - publisher(s): PlayStation Studios & PlayStation PC
  //  - devloper(s): SCE Santa Monica
  //  - gerne: Action Adventure & Linear
  //  - score / meta rating: 93
  //  - etc...
  MetacriticEntity entity = await MetaCriticAPI.instance
      .getMetacriticData(game: "God Of War", platform: "PC");

  //Retrieve all item(s) name, wich equal the input
  //Example
  //  - Name: God Of War,
  //  - Platform: PS4 / Playstation 4
  //
  //Result: 6 game
  List<String> entities =
      await MetaCriticAPI.instance.searchFor(name: "Call of Duty");

  //Return a list of Uri, wich contains the founded image(s)
  //Example:
  //  - Name: Call of Duty: Modern Warfare
  //  - Year: 2019
  List<Uri> images = await MetaCriticAPI.instance
      .getCovers(name: "Call of Duty: Modern Warfare", year: 2019);

  Duration end = start.difference(DateTime.now());

  print("object");
}
