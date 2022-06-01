<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# Metacritic API for Dart
Simple API for querying, searching games and more from Metacritic.

## Features
* Query all game infromation (name, date, score, rating, etc...)
* Query reviews (Critic and User)
* Get the cover image URL of the game (from [IGDB](https://www.igdb.com))
* Search games by name & platfrom
* Convert the game information a JSON string

## Contents

* [Query game infromations](#query-game-informations)
* [Query reviews](#query-reviews)
* [Searching](#searching)
* [Get cover](#query-urls-of-cover-image)
* [Convert to a JSON string](#convert-all-data-a-json-string)

### Query game informations

#### Method Description
If we have the __name__ and __release platform__ of a game, we should query the game from [Metacritic.com](https://www.metacritic.com) and return a __MetacriticEntity__ object.

#### Parameters
* __Name__: The game name (required)
* __Platfrom__: The platfrom, where the game is released (Default value: "PC")

```dart
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
```

### Query reviews

#### Method Description
This method query all critic and user reviews information. (Now just critic reviews queried, user reviews is developing)

#### Parameters
* __Name__: The game name (required)
* __Platfrom__: The platfrom, where the game is released (Default value: "PC")
* __Type__: The type of reviews. (Default value: null (all review))

```dart
  //Return a list, wich contains all reviews the specified game
  //(Example: God of War, PC version);
  
  List<Review> reviews = await MetaCriticAPI.instance.getReviews(
    entity.name,
    entity.platfroms[0],
  );
```

### Searching 

#### Method Description
Search by name and return a list, which contains the game names and platfroms. __Result format__: "game name->platfrom"

#### Parameters
* __Name__: The game name (required)
* __Platfrom__: The platfrom, where the game is released (Default value: "")
* __Page Index__: Reduce the number of search results (Default value: null (all result))

```dart
  //Retrieve all item(s) name and platform, wich equal the input
  //Example
  //  - Name: God Of War,
  //  - Platform: PS4 / Playstation 4
  //  - Search Page Index: null (We search every existing pages)
  //Result: 6 game
  //Result format: "game name->platform"
  
  List<String> entities = await MetaCriticAPI.instance
      .searchFor(name: entity.name, platform: entity.platfroms[0]);
```

### Query URL(s) of cover image 

#### Method Description
Retrieve a list, which contains all cover image links from from [IGDB](https://www.igdb.com). (Yeah, this a little cheat, but this image(s) is bigger resolution, than Metacritic images)

#### Parameters
* __Name__: The game name (required)
* __Year__: The year, when the game is released. This parameter required for more accurate results (Default value: null)

```dart
  //Return a list of Uri, wich contains the founded image(s)
  //Example:
  //  - Name: Call of Duty: Modern Warfare
  //  - Year: 2019
  //Result: https://images.igdb.com/igdb/image/upload/t_cover_big/co1rsg.png
  
  List<Uri> images = await MetaCriticAPI.instance
      .getCovers(name: "Call of Duty: Modern Warfare", year: 2019);
```

### Convert all data a JSON string

#### Method Description
Return a JSON string from a MetacriticEntity object.

#### Parameters
* __plusArgs__: We can add extra data to the JSON string, if required. (Pl: cover URL(s)) (Default value: null)

```dart
  //If you don't like the prefabricated object
  //or have another reason convert the entity a .json string.
  String jsonEntity = entity.toJSON(plusArgs: {"covers": images});
```

<!--## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.-->
