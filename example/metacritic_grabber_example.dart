import 'package:metacritic_request/metacritic_entity.dart';
import 'package:metacritic_request/metacritic_grabber.dart';

void main() {
  test();
}

void test() async {
  //Return a entity, wich contains God Of War game propeties from specifed type and platform (pl: Game - PC)
  //Example result:
  //  - name: God Of War
  //  - publisher(s): PlayStation Studios & PlayStation PC
  //  - devloper(s): SCE Santa Monica
  //  - gerne: Action Adventure & Linear
  //  - score / meta rating: 93
  //  - etc...
  MetacriticEntity? entity = await MetaCriticGrabber.instance
      .getMetacriticData(game: "God Of War", type: "game", platform: "PC");

  //Retrieve all item(s), wich equal the input (name, type, platform)
  //Input: "call of duty", not specified platform
  //Result: 256 items
  List<String> entities = await MetaCriticGrabber.instance
      .searchFor(name: "call of duty", type: "game");

  print("");
}
