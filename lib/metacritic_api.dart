import 'package:http/http.dart' as HTTP;
import 'package:metacritic_request/platfroms.dart';
import 'package:metacritic_request/review.dart';

import 'enums.dart';
import 'metacritic_entity.dart';

class MetaCriticAPI {
  //Sigleton pattern
  static MetaCriticAPI instance = new MetaCriticAPI();

  //The page url
  Uri? _selectedGamePageURL = null;

  //The authory
  final String _authory = "www.metacritic.com";

  //Separator sign
  static const String _separator = " <<separator>> ";

  //Searchable datas
  String _nameLine = "";
  final String _searchLine = "<ul class=\"search_results module\">";
  final String _dateLine = "<span class=\"label\">Release Date:</span>";
  final String _metaRatingLine = "<span itemprop=\"ratingValue\">";
  final String _gameDeveloperLine = "<span class=\"label\">Developer:</span>";
  final String _publisherLine = "<span class=\"label\">Publisher:</span>";
  final String _gernesLine = "<span class=\"label\">Genre(s): </span>";
  final String _ratingLine = "<span class=\"label\">Rating:</span>";
  final String _coverImageLine =
      "<div data-react-class=\"GamePageHeader\" data-react-props";

  final Map<String, String> _reviewLines = {
    "Critic": "<ol class=\"reviews critic_reviews\">",
    "User": "<ol class=\"reviews user_reviews\">"
  };

  //Months
  final Map<String, int> _months = {
    "Januar": 1,
    "Februar": 2,
    "March": 3,
    "April": 4,
    "May": 5,
    "June": 6,
    "July": 7,
    "August": 8,
    "September": 9,
    "October": 10,
    "November": 11,
    "December": 12,
  };

  //Special charachters for name formatmting
  final List<String> specialCharachters = [':', '\'', '(', ')'];

  //Format the name for correct URL text
  String _nameFormatToURL(String game) {
    String result = game;

    for (String specialCharacter in specialCharachters) {
      if (result.contains(specialCharacter)) {
        result =
            "${result.split(specialCharacter)[0].trim()} ${result.split(specialCharacter)[1].trim()}";
      }
    }

    return result.trim().split(' ').join('-').toLowerCase();
  }

  //Get the important data section
  Future<String> _getDataFrom(
      String text, String startLine, String endTag) async {
    if (!text.contains(startLine)) return "";

    //Kezdő index
    int startIndex = text.indexOf(startLine) + startLine.length;
    int index = startIndex;
    int letterCount = 0;

    //Vég html tag (</li>)
    String end = "";

    //Az szükséges, formázatlan adat
    String line = "";

    //Szükséges adatok kinyerése
    do {
      end = text.substring(index, index + endTag.length);
      letterCount++;
      index++;
    } while (end != endTag);

    line = text.substring(startIndex, startIndex + letterCount - 1);

    return line;
  }

  //Get DateTime object
  Future<DateTime?> _getFormattingDateData(
      String text, String startLine, String endTag) async {
    int year = 1970;
    int month = 1;
    int day = 1;
    int changeNumber = 0;

    List<String> results = [];

    //Az adatok begyüjtése
    String _value = await _getDataFrom(text, startLine, endTag);

    if (_value != "") {
      _value = _value.split('>')[1].split('<')[0].trimLeft().trimRight();

      //Dates: 0 = Day & Month, 1 = Year
      results = _value.split(',');

      try {
        if (results[0] != "TBA") {
          year = int.parse(results[1]);
          day = int.parse(results[0].split(' ')[1]);
          changeNumber += 2;
        }
      } on FormatException {
        day = int.parse(results[0].split(' ')[2]);
      } on RangeError {
        if (results[0].contains("TBA")) {
          year = int.tryParse(results[0].split(' ')[1]) ?? 0;
          changeNumber++;
        }
      }

      for (int i = 0; i < _months.length; i++) {
        if (_months.keys
            .elementAt(i)
            .toLowerCase()
            .contains(results[0].split(' ')[0].toLowerCase())) {
          month = _months.values.elementAt(i);
          changeNumber++;
          break;
        }
      }

      return new DateTime(year, month, day, changeNumber != 3 ? 4 : 0, 0,
          changeNumber != 3 ? 4 : 0);
    }

    return null;
  }

  //Get a simple data
  Future<String> _getFormattingSimpleData(
      {required String text,
      String startLine = "",
      String endTag = "",
      String splitTag = ""}) async {
    //Data collecting
    List<String> results = [];

    String temp = await _getDataFrom(text, startLine, endTag);

    if (splitTag != "") {
      results = temp.split(splitTag);
    } else {
      results.add(temp);
    }

    //Formatting
    if (temp != "") {
      //If the data is a hyper link
      if (results.any((element) => element.contains("</a>"))) {
        for (int i = 0; i < results.length; i++) {
          String line = results[i];
          String splitTemp = "";

          if (line.contains("LLC")) {
            results.removeAt(i);
            continue;
          }

          splitTemp = line
              .split('>')[i == 0 ? 2 : 1]
              .split('<')[0]
              .trimLeft()
              .trimRight();

          results[i] = splitTemp;
        }
      } else {
        for (var i = 0; i < results.length; i++) {
          String lines = results[i];
          String temp = lines.split('>')[1].split('<')[0];
          results[i] = temp.trim();
        }
      }
    }

    return results.join(" & ");
  }

  ///Returns an entity that contains informations
  Future<MetacriticEntity> getMetacriticData({
    String platform = "pc",
    required String game,
  }) async {
    //Metacritic URL appending
    game = _nameFormatToURL(game);

    platform = platform.toLowerCase().split(' ').join('-');

    _nameLine =
        "<a href=\"/game/${platform.toLowerCase()}/${game}\" class=\"hover_none\">";

    _selectedGamePageURL = await Uri.https(
      _authory,
      "/game/${platform.toLowerCase()}/${game}",
    );

    //Get .HTML file from URL
    HTTP.Response _response = await HTTP.get(_selectedGamePageURL!);

    //If not exist the element, throw a exception
    if (_response.statusCode != 200) {
      throw new Exception(
          "This page not exist or not loaded! (${_selectedGamePageURL!.authority.toString()}${_selectedGamePageURL!.path}");
    }

    return await _fetchEntity(response: _response.body);
  }

  //Create a GameDataEntity
  Future<MetacriticEntity> _fetchEntity({required String response}) async {
    String name = "";
    String developer = "";
    String publisher = "";
    String gernes = "";
    String rating = "";
    String desc = "";
    DateTime? date = null;
    String mateRate = "";
    List<String> platforms = [];

    //Developer(s)
    developer = await _getFormattingSimpleData(
        text: response,
        startLine: _gameDeveloperLine,
        endTag: "</li>",
        splitTag: ',');

    //Publisher(s)
    publisher = await _getFormattingSimpleData(
        text: response,
        startLine: _publisherLine,
        endTag: "</li>",
        splitTag: ',');

    //Genre(s)
    gernes = await _getFormattingSimpleData(
        text: response, startLine: _gernesLine, endTag: "</li>", splitTag: ',');

    //Rating (pl: "M" rating)
    rating = await _getFormattingSimpleData(
        text: response, startLine: _ratingLine, endTag: "</li>", splitTag: ',');

    //Get all review, if all review count is equal 4
    if (response.contains(_metaRatingLine)) {
      int index = response.indexOf(_metaRatingLine);
      String line = response.substring(
        index,
        index + "<span itemprop=\"ratingValue\">".length + 3,
      );

      mateRate = line.split('>')[1].split('<')[0];
    }

    //Description of the game
    desc = await _getFormattingSimpleData(
        text: response,
        startLine: "<span class=\"blurb blurb_expanded\"",
        endTag: "</span>");

    //Name the game
    name = await _getFormattingSimpleData(
        text: response, startLine: _nameLine, endTag: "</a>", splitTag: ',');

    //Release date (if game release date equal "TBA {plenned release year}",
    //then the hour and the second properties equals 4)
    //The hour, minute, second properties together looks like the 404 error
    date = await _getFormattingDateData(response, _dateLine, "</li>");

    String platfromTempText =
        await _getDataFrom(response, "<span class=\"platform\">", "</span>");

    String mainPlatfromInThePage = await _getFormattingSimpleData(
        text: platfromTempText,
        startLine: "<a href=",
        endTag: "</a>",
        splitTag: "");

    platforms.add(mainPlatfromInThePage);

    platfromTempText = await _getDataFrom(
        response, "<li class=\"summary_detail product_platforms\"", "</li>");

    platfromTempText = await _getDataFrom(
        platfromTempText, "<span class=\"data\">", "</span>");

    List<String> platfromLines = platfromTempText.trim().split(',');

    for (var i = 0; i < platfromLines.length; i++) {
      String a = await _getFormattingSimpleData(
          text: platfromLines[i],
          startLine: "class=\"hover_none\"",
          endTag: "</a>",
          splitTag: "");

      platforms.add(a);
    }

    return new MetacriticEntity(
      name: name,
      developers: developer.split(" & "),
      publishers: publisher.split(" & "),
      desc: desc,
      date: date,
      gernes: gernes.split(" & "),
      rating: rating,
      metaRating: int.tryParse(mateRate) ?? "Not reviewed",
      platfroms: platforms,
    );
  }

  ///Return a list, which contains all reviews from specified [gameName] and [platform]
  Future<List<Review>> getReviews(
      {required String gameName,
      String platform = "pc",
      ReviewType? type = null}) async {
    List<Review> results = [];
    List<String> datas = [];
    List<String> reviewsDatas = [];

    platform = _nameFormatToURL(platform);
    gameName = _nameFormatToURL(gameName);

    if (type != null) {
      Uri URL = await Uri.https(
        _authory,
        "game/${platform}/${gameName}/${type.name.toLowerCase()}-reviews",
      );

      //Get .HTML file from URL
      HTTP.Response _response = await HTTP.get(URL);

      String temp =
          await _getDataFrom(_response.body, _reviewLines[type.name]!, "</ol>");
      datas = temp.split("<div class=\"review_stats\">");

      //Válogatás
      for (int i = 0; i < datas.length; i++) {
        if (i != 0) {
          String reviewData = datas[i].split("<div class=\"review_body\">")[0] +
              _separator +
              "<div class=\"review_body\">" +
              datas[i]
                  .split("<div class=\"review_body\">")[1]
                  .split("<div class=\"review_section review_actions\">")[0];

          reviewsDatas.add(reviewData.trim());
        }
      }

      //Set up all scored, provided review objects
      for (int i = 0; i < reviewsDatas.length; i++) {
        //Get the review content
        String content = await _getReviewContent(type.index, reviewsDatas[i]);

        //Get all same data
        Map<String, dynamic> baseDatas =
            await _getBaseReviewData(reviewsDatas[i]);

        results.add(
          new Review(
            author: baseDatas["author"],
            date: baseDatas["date"],
            reviewType: ReviewType.values.byName(type.name),
            content: content,
            score: baseDatas["score"],
          ),
        );
      }

      return results;
    }

    for (int i = 0; i < 2; i++) {
      Uri URL = await Uri.https(
        _authory,
        "game/${platform}/${gameName}/${ReviewType.values[i].name.toLowerCase()}-reviews",
      );

      //Get .HTML file from URL
      HTTP.Response _response = await HTTP.get(URL);

      String temp = await _getDataFrom(
          _response.body, _reviewLines[ReviewType.values[i].name]!, "</ol>");
      datas = temp.split("<div class=\"review_stats\">");

      //Válogatás
      for (int j = 0; j < datas.length; j++) {
        if (j != 0) {
          String reviewData = datas[j].split("<div class=\"review_body\">")[0] +
              _separator +
              "<div class=\"review_body\">" +
              datas[j]
                  .split("<div class=\"review_body\">")[1]
                  .split("<div class=\"review_section review_actions\">")[0];

          reviewsDatas.add(reviewData.trim());
        }
      }

      //Set up all scored, provided review objects
      for (int j = 0; j < reviewsDatas.length; j++) {
        //Get the review content
        String content = await _getReviewContent(i, reviewsDatas[j]);

        //Get all same data
        Map<String, dynamic> baseDatas =
            await _getBaseReviewData(reviewsDatas[j]);

        results.add(
          new Review(
            author: baseDatas["author"],
            date: baseDatas["date"],
            reviewType: ReviewType.values[i],
            content: content,
            score: baseDatas["score"],
          ),
        );
      }

      reviewsDatas.clear();
    }

    return results;
  }

  ///Search for by input, which return a game(s) objects.
  Future<List<String>> searchFor({
    String platform = "",
    String name = "",
    int? pageIndex = null,
  }) async {
    name = name.toLowerCase().split(' ').join(' ');

    List<String> results = [];
    int page = pageIndex ?? 0;

    do {
      //Metacritic URL appending
      Uri searchURL = Uri.https(
          _authory, "/search/game/${name}/results", {"page": page.toString()});

      //HTTPS request
      HTTP.Response response = await HTTP.get(searchURL);

      //If connection status is success
      if (response.statusCode != 200) {
        throw new Exception("The connection is field!");
      }

      //Get the required text section
      String resultText =
          await _getDataFrom(response.body, _searchLine, "</ul>");

      //Selected informations
      List<String> temp = resultText.split("<div class=\"result_wrap\">");

      if (temp.length < 2) {
        break;
      }

      for (int i = 1; i < temp.length; i++) {
        //Get name of the game
        String _name = temp[i].split("<a href=")[1].split('>')[1].split('<')[0];
        _name = _name.trim();

        //Retrieve the game platform information
        String _platform = temp[i]
            .split("<span class=\"platform\"")[1]
            .split('>')[1]
            .split('<')[0];

        //If specified the platfrom
        if (platform != "") {
          _platform =
              Platfroms.Instance.getPlatfromByName(_platform).toLowerCase();

          if (_platform ==
              Platfroms.Instance.getPlatfromByName(platform).toLowerCase()) {
            results.add("${_name}->${_platform}");
          }
          continue;
        }

        //If NOT specified the platfrom
        _platform =
            Platfroms.Instance.getPlatfromByName(_platform).toLowerCase();
        results.add("${_name}->${_platform}");
      }

      if (pageIndex == page && pageIndex != null) {
        break;
      }

      //Set next page index
      page++;
    } while (true);

    return results;
  }

  ///Return a list, wich contains games name and platfrom by one specified category (Action, First-Person, etc..)
  Future<List<String>> getGamesByCategory({
    required GameCategory category,
    SortedBy sortedBy = SortedBy.Date,
    String platform = "all",
    int pageNumber = 0,
  }) async {
    //The results
    List<String> _results = [];

    if (platform != "all") {
      platform = Platfroms.Instance.getPlatfromByName(platform);
    }

    //Set the URL
    Uri _currentPageURL = Uri.https(
        "www.metacritic.com",
        "/browse/games/genre/${sortedBy.name.toLowerCase()}/${category.name.toLowerCase()}/${_nameFormatToURL(platform)}",
        {"page": "$pageNumber"});

    return await _getCategoryResultInPage(_currentPageURL);
  }

  ///Return a list, wich contains cover image(s).
  ///If the year parameter equal null, then all image we find put in a list and return those.
  Future<List<Uri>> getCovers({required String name, int? year = null}) async {
    //Founded image(s)
    List<Uri> result = [];

    //Formatting the input
    String _name = name.toLowerCase();

    if (_name.contains(':')) {
      _name = "${_name.split(':')[0].trim()} ${_name.split(':')[1].trim()}"
          .split(' ')
          .join('-');
    } else {
      _name = _name.split(' ').join('-');
    }

    //Actually viewed page
    int gamePageIndex = 0;

    //No more images found
    bool end = false;

    do {
      //If the game page index equal 0, then no page numbering is required
      String unEncodedPath = gamePageIndex == 0
          ? "/games/${_name}"
          : "/games/${_name}--${gamePageIndex}";

      //The game page URL
      Uri _url = Uri.https("www.igdb.com", unEncodedPath);

      //HTTPS request
      HTTP.Response response = await HTTP.get(_url);

      //If the page is not the search list page
      if (response.body.contains(_coverImageLine)) {
        //The part of the text that contains the necessary information
        String text =
            await _getDataFrom(response.body, _coverImageLine, "data-hydrate");
        String line = text.split("cover&quot;:")[1];

        //The year
        String yearLine =
            await _getDataFrom(line, "release_date&quot;:&quot;", "&quot;");

        int _year = 0;

        if (!yearLine.contains(',')) {
          try {
            _year = int.parse(yearLine.split('&')[0]);
          } on FormatException {
            _year = int.parse(yearLine.split('&')[0].split(' ')[1]);
          }
        } else {
          _year = int.parse(yearLine.split('&')[0].split(',')[1]);
        }

        //If the year parameter not equal null value,
        //then get only the picture, wich equal the year parameter.
        //Else all image we find, add the list.
        if (year != null) {
          if (year == _year) {
            String temp = await _getDataFrom(
                line, "cloudinary_id&quot;:&quot;", "&quot;");
            String imageId = temp.split('&')[0];

            result.add(Uri.https("images.igdb.com",
                "/igdb/image/upload/t_cover_big/${imageId}.png"));

            break;
          }
        } else {
          String temp =
              await _getDataFrom(line, "cloudinary_id&quot;:&quot;", "&quot;");
          String imageId = temp.split('&')[0];

          result.add(Uri.https("images.igdb.com",
              "/igdb/image/upload/t_cover_big/${imageId}.png"));
        }

        //Increase the page number
        gamePageIndex++;
      } else {
        end = true;
      }
    } while (!end);

    return result;
  }

  //Get all same info for the comment(author, score, etc...)
  Future<Map<String, dynamic>> _getBaseReviewData(String text) async {
    String author = text.split(_separator)[0];

    //If author data a link
    if (author.contains("</a>")) {
      author = author.split("</a>")[0].split('>')[3];
    } else {
      //If not a link
      author = author.split("<div class=\"source\">")[1].split('<')[0];
    }

    //Get date the review
    DateTime? date = await _getFormattingDateData(
        text.split("->")[0], "<div class=\"date\"", "</div>");

    //Given score
    double score = double.parse(
      await _getFormattingSimpleData(
          text: text.split("->")[0],
          startLine: "<div class=\"metascore_w",
          endTag: "</div>"),
    );

    return {"author": author, "date": date, "score": score};
  }

  Future<String> _getReviewContent(int typeIndex, String text) async {
    String result = "";

    switch (typeIndex) {
      case 0:
        result = await _getFormattingSimpleData(
            text: text.split(_separator)[1],
            startLine: "<div class=\"review_body\"",
            endTag: "</div>");
        break;
      case 1:
        if (text.contains("<span class=\"blurb blurb_expanded\"")) {
          result = await _getFormattingSimpleData(
              text: text.split(_separator)[1],
              startLine: "<span class=\"blurb blurb_expanded\"",
              endTag: "</span>");

          break;
        }

        result = await _getFormattingSimpleData(
            text: text.split(_separator)[1],
            startLine: "<span",
            endTag: "</span>");

        break;
    }

    return result;
  }

  Future<List<String>> _getCategoryResultInPage(Uri _currentPageURL) async {
    List<String> _results = [];

    //The games structure section numbers
    List<String> _pageSections = ["one", "two", "three", "four"];

    //Send the request
    HTTP.Response _response = await HTTP.get(_currentPageURL);

    //If the page not contains any game, return a empty list
    if (_response.body.contains("No games found.") ||
        _response.statusCode != 200) return [];

    for (int i = 0; i < _pageSections.length; i++) {
      String endTag = i < _pageSections.length - 1
          ? "<div class=\"browse_list_wrapper ${_pageSections[i + 1]}"
          : "<div class=\"marg_top1\">";

      //Trim for the data
      String temp = await _getDataFrom(_response.body,
          "<div class=\"browse_list_wrapper ${_pageSections[i]}", endTag);

      temp =
          await _getDataFrom(temp, "<table class=\"clamp-list\">", "</table>");

      temp = temp.trim();

      //Split the string to games sections
      List<String> gamesDatas = temp.split("<tr class=\"spacer\"></tr>");

      //Get the games (name + platfrom)
      for (int j = 0; j < gamesDatas.length; j++) {
        if (!gamesDatas[j].contains("class=\"title\"><h3>") ||
            !gamesDatas[j].contains("class=\"title\"><h3>")) {
          continue;
        }

        //Get name
        String name =
            await _getDataFrom(gamesDatas[j], "class=\"title\"><h3>", "</h3>");

        //Get platform
        String _platform = await _getDataFrom(
            gamesDatas[j], "<span class=\"data\">", "</span>");

        _results.add("${name}->${_platform.trim()}");
      }
    }

    return _results;
  }
}
