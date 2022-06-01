class Platfroms {
  //Singleton pattern
  static Platfroms get Instance {
    return new Platfroms();
  }

  int get PlatformCount {
    return _platformsNames.length;
  }

  //Platforms
  final Map<String, String> _platformsNames = {
    "PC": "PC",
    "PS5": "Playstation 5",
    "PS4": "Playstation 4",
    "PS3": "Playstation 3",
    "PS2": "Playstation 2",
    "PS": "Playstation",
    "PSP": "PSP",
    "VITA": "Playstation vita",
    "XBSX": "Xbox Series X",
    "XONE": "Xbox One",
    "X360": "Xbox 360",
    "XBOX": "Xbox",
    "SWITCH": "Switch",
    "WIIU": "Wii u",
    "WII": "Wii",
    "DS": "DS",
    "3DS": "3DS",
    "GAMECUBE": "Gamecube",
    "GBA": "Gamebox Advance",
    "GC": "Gamecube",
    "N64": "N64",
    "IOS": "iOS",
    "ANDROID": "Android",
  };

  String getPlatfromByName(String platfrom) {
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

  String getPlatfromByIndex(int index) {
    try {
      return _platformsNames.values.elementAt(index);
    } on IndexError {
      //If no result
      throw new Exception("This platform not exist or the input is incorrect!");
    }
  }
}
