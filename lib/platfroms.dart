class Platfroms {
  //Singleton pattern
  static Platfroms get Instance {
    return new Platfroms();
  }

  //Platforms
  final Map<String, String> _platformsNames = {
    "PC": "pc",
    "PS5": "playstation 5",
    "PS4": "playstation 4",
    "PS3": "playstation 3",
    "PS2": "playstation 2",
    "PS": "playstation",
    "PSP": "psp",
    "VITA": "playstation vita",
    "XBSX": "xbox series x",
    "XONE": "xbox one",
    "X360": "xbox 360",
    "XBOX": "xbox",
    "SWITCH": "switch",
    "WIIU": "wii u",
    "WII": "wii",
    "DS": "ds",
    "GAMECUBE": "gamecube",
    "GC": "gamecube",
    "N64": "n64",
    "IOS": "ios",
    "ANDROID": "android",
  };

  String getPlatfrom(String platfrom, String name) {
    //Formatting the input
    platfrom = platfrom.toLowerCase();

    //Search for the correct platform
    for (var i = 0; i < _platformsNames.length; i++) {
      String key = _platformsNames.keys.elementAt(i);
      String value = _platformsNames.values.elementAt(i);

      if (platfrom == key.toLowerCase()) {
        return value;
      } else if (platfrom == value.toLowerCase()) {
        return value;
      }
    }

    //If no result
    throw new Exception("This platform not exist or the input is incorrect!");
  }

  bool equal(String platfrom) {
    //Formatting the input
    platfrom = platfrom.toLowerCase();

    //Search for the correct platform
    for (var i = 0; i < _platformsNames.length; i++) {
      String key = _platformsNames.keys.elementAt(i);
      String value = _platformsNames.values.elementAt(i);

      if (platfrom == key.toLowerCase()) {
        return true;
      } else if (platfrom == value.toLowerCase()) {
        return true;
      }
    }

    return false;
  }
}
