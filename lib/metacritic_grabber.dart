import 'package:http/http.dart' as HTTP;
import 'package:metacritic_request/platfroms.dart';
import 'package:metacritic_request/review.dart';

import 'metacritic_entity.dart';

///Simple library for grabbing data from Metacritic.
class MetaCriticGrabber {
  static MetaCriticGrabber instance = new MetaCriticGrabber();
  final String _authory = "www.metacritic.com";

  //Az adott honlap url-je
  Uri? _selectedGamePageURL = null;

  bool _forSearch = false;

  //Kereséshez való fromai adatok
  final String _searchLine = "<ul class=\"search_results module\">";

  //Alap keresendő adatok
  String _nameLine = "";
  final String _dateLine = "<span class=\"label\">Release Date:</span>";
  final String _metaRatingLine = "<span itemprop=\"ratingValue\">";
  final String _criticReviewLine = "<ol class=\"reviews critic_reviews\">";

  //Játékhoz kapcsoldó keresendő adatok
  final String _gameDeveloperLine = "<span class=\"label\">Developer:</span>";
  final String _publisherLine = "<span class=\"label\">Publisher:</span>";
  final String _gernesLine = "<span class=\"label\">Genre(s): </span>";
  final String _ratingLine = "<span class=\"label\">Rating:</span>";
  final String _coverImageLine =
      "<div data-react-class=\"GamePageHeader\" data-react-props";

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

  ///Returns an entity that contains information about the specified type, if exist. (Types: Game, Tv, ect.)
  Future<MetacriticEntity?> getMetacriticData(
      {String platform = "pc",
      required String game,
      required String type}) async {
    //Metacritic URL appending
    String input = game.toLowerCase().split(' ').join('-');
    platform = platform.toLowerCase().split(' ').join('-');

    _nameLine =
        "<a href=\"/game/${platform.toLowerCase()}/${input}\" class=\"hover_none\">";

    _selectedGamePageURL = await Uri.https(
      _authory,
      "/game/${platform.toLowerCase()}/${input}",
    );

    //Get .HTML file from URL
    HTTP.Response _response = await HTTP.get(_selectedGamePageURL!);

    //If not exist the element, return null value
    if (_response.statusCode != 200) {
      return null;
    }

    return await _setMetacriticEntity(response: _response.body);
  }

  //Create a MetacriticEntity
  Future<MetacriticEntity> _setMetacriticEntity(
      {required String response}) async {
    String name = "";
    String developer = "";
    String publisher = "";
    String gernes = "";
    String rating = "";
    DateTime? date = null;
    List<Review> reviews = [];
    String mateRate = "Not reviewed";

    //Ha nem csak keresési elözmény adatira vagyunk kiváncsiak
    if (!_forSearch) {
      //Reviews
      reviews = await _getReviews(_criticReviewLine, "</ol>");

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

      //Gerne(s)
      gernes = await _getFormattingSimpleData(
          text: response,
          startLine: _gernesLine,
          endTag: "</li>",
          splitTag: ',');

      //Rating (pl: "M" rating)
      rating = await _getFormattingSimpleData(
          text: response,
          startLine: _ratingLine,
          endTag: "</li>",
          splitTag: ',');
    }

    //Az értéklés lekérdezése, ha van elegendő értékelés
    if (response.contains(_metaRatingLine)) {
      int index = response.indexOf(_metaRatingLine);
      String line = response.substring(
        index,
        index + "<span itemprop=\"ratingValue\">".length + 3,
      );

      mateRate = line.split('>')[1].split('<')[0];
    }

    //Name the game
    name = await _getFormattingSimpleData(
        text: response, startLine: _nameLine, endTag: "</a>", splitTag: ',');

    //Release date (if game release date equal "TBA {plenned release year}",
    //then the hour and the second properties equals 4)
    //The hour, minute, second properties together looks like the 404 error
    date = await _getFormattingDateData(response, _dateLine, "</li>");

    return new MetacriticGameEntity(
      name: name,
      developers: developer,
      publishers: publisher,
      date: date,
      gernes: gernes,
      rating: rating,
      reviews: reviews,
      metaRating: int.tryParse(mateRate) ?? "Not reviewed",
    );
  }

  //Get a simple data
  Future<String> _getFormattingSimpleData(
      {required String text,
      String startLine = "",
      String endTag = "",
      String splitTag = ""}) async {
    //Az adatok begyüjtése
    List<String> results = [];

    String temp = await _getDataFrom(text, startLine, endTag);

    if (splitTag != "") {
      results = temp.split(splitTag);
    } else {
      results.add(temp);
    }

    //Formázás
    if (temp != "") {
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

  //Get DateTime object
  Future<DateTime?> _getFormattingDateData(
      String text, String startLine, String endTag) async {
    int year = 1970;
    int month = 1;
    int day = 1;
    int changeNumber = 0;

    List<String> results = [];
    DateTime? result = null;

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

  //Get the important data section
  Future<String> _getDataFrom(
      String text, String startLine, String endTag) async {
    if (!text.contains(startLine)) return "";

    //Kezdő index
    int startIndex = text.indexOf(startLine) + startLine.length;
    int index = startIndex;
    int letterCount = 0;

    //Vég html tag (</li>>)
    String end = "";

    //Az szükséges, formázatlan adat
    String line = "";

    //Szükséges adatok kinyerése
    do {
      end = text.substring(index, index + endTag.length);
      letterCount++;
      index++;
    } while (end != endTag);

    line = text.substring(startIndex, startIndex + letterCount);

    return line;
  }

  //Get all reviews
  Future<List<Review>> _getReviews(String startLine, String endTag) async {
    List<Review> results = [];
    List<String> datas = [];
    List<String> reviewsDatas = [];

    Uri _criticsURL = await Uri.https(
      _selectedGamePageURL!.authority,
      "${_selectedGamePageURL!.path}/critic-reviews",
    );

    Uri _userURL = await Uri.https(
      _selectedGamePageURL!.authority,
      "${_selectedGamePageURL!.path}/user-reviews",
    );

    //.HTML fájl lekérése a címről / Get .HTML file from URL
    HTTP.Response _response = await HTTP.get(_criticsURL);

    String temp = await _getDataFrom(_response.body, startLine, endTag);
    datas = temp.split("<div class=\"review_stats\">");

    //Válogatás
    for (int i = 0; i < datas.length; i++) {
      if (i != 0) {
        String reviewData = datas[i].split("<div class=\"review_body\">")[0] +
            "<->" +
            "<div class=\"review_body\">" +
            datas[i]
                .split("<div class=\"review_body\">")[1]
                .split("<div class=\"review_section review_actions\">")[0];
        ;

        reviewsDatas.add(reviewData.trim());
      }
    }

    //Set up all scored, provided review objects
    for (int i = 0; i < reviewsDatas.length; i++) {
      //The review content
      String content = await _getFormattingSimpleData(
          text: reviewsDatas[i].split("<->")[1],
          startLine: "<div class=\"review_body\"",
          endTag: "</div>");

      //Get author
      String author = reviewsDatas[i].split("<->")[0];

      //If author data a link
      if (author.contains("</a>")) {
        author = author.split("</a>")[0].split('>')[3];
      } else {
        //If not
        author = author.split("<div class=\"source\">")[1].split('<')[0];
      }

      //Get date the review
      DateTime? date = await _getFormattingDateData(
          reviewsDatas[i].split("<->")[0], "<div class=\"date\"", "</div>");

      //Given score
      double score = double.parse(
        await _getFormattingSimpleData(
            text: reviewsDatas[i].split("<->")[0],
            startLine: "<div class=\"metascore_w",
            endTag: "</div>"),
      );

      results.add(
        new Review(
            author: author,
            date: date,
            reviewType: ReviewType.Critic,
            content: content,
            score: score),
      );
    }

    return results;
  }

  ///Returns a list, wich constains the name of the search item(s)
  Future<List<String>> searchFor({
    required String type,
    String platform = "",
    String name = "",
  }) async {
    name = name.toLowerCase().split(' ').join(' ');
    type = type.toLowerCase();

    List<String> results = [];
    bool hasSearchResult = true;
    int pageIndex = 0;

    do {
      //Result infromations
      List<String> resultInfos = [];

      //Metacritic URL összeillesztés / Metacritic URL appending
      Uri searchURL = Uri.https(_authory, "/search/${type}/${name}/results",
          {"search_type": "advanced", "page": pageIndex.toString()});

      //HTTPS request from the page
      HTTP.Response response = await HTTP.get(searchURL);

      //If connection status is success
      if (response.statusCode == 200) {
        String resultText =
            await _getDataFrom(response.body, _searchLine, "</ul>");

        //Selected infotmations
        List<String> temp = resultText.split("<div class=\"result_wrap\">");

        if (temp.length != 1) {
          for (var i = 0; i < temp.length; i++) {
            //Retrieve data from 1 index to end of the temp list
            if (i != 0) {
              //Get name of the game
              String name =
                  temp[i].split("<a href=")[1].split('>')[1].split('<')[0];
              name = name.trim();

              if (name.contains(':')) {
                name = name.split(':')[0] + name.split(':')[1];
              }

              //Retrieve the game platform information
              String _platform = temp[i]
                  .split("<span class=\"platform\"")[1]
                  .split('>')[1]
                  .split('<')[0];

              //If specified the platfrom
              if (platform != "") {
                if (Platfroms.Instance.getPlatfrom(platform) == _platform) {
                  results.add(name);
                }
                continue;
              }

              //If NOT specified the platfrom
              results.add(name);
            }
          }

          //Set next page index
          pageIndex++;
        } else {
          hasSearchResult = false;
        }
      } else {
        hasSearchResult = false;
      }
    } while (hasSearchResult);

    return results;
  }

  ///Return a list, wich contains cover image(s)
  ///If the year parameter equal null, then all image we find put in a list and retirn those.
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
        //then get only the picture you need.
        //Else all image we find put the list.
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
}
