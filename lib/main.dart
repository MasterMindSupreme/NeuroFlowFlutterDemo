import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

var searchQuery = '';
List<dynamic> searchResults = [];
var currentArtist = [];
var doneGettingPictures = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: const Color.fromRGBO(30, 215, 96, .1),
      100: const Color.fromRGBO(30, 215, 96, .2),
      200: const Color.fromRGBO(30, 215, 96, .3),
      300: const Color.fromRGBO(30, 215, 96, .4),
      400: const Color.fromRGBO(30, 215, 96, .5),
      500: const Color.fromRGBO(30, 215, 96, .6),
      600: const Color.fromRGBO(30, 215, 96, .7),
      700: const Color.fromRGBO(30, 215, 96, .8),
      800: const Color.fromRGBO(30, 215, 96, .9),
      900: const Color.fromRGBO(30, 215, 96, 1),
    };
    MaterialColor spotifyGreen = MaterialColor(0xFF1ED760, color);
    return MaterialApp(
      title: 'Spotify Artist Search Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: spotifyGreen),
      home: const MyHomePage(title: 'Search for Artists on Spotify'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var size = 0.0;
  var artistsDisplayList = [];
  var row1Artists = [];
  var row2Artists = [];
  var row3Artists = [];

  void initializeArtistsDisplay() async {
    var clientId = "2b72b242cdf34a3baa265d280967dd36";
    var clientSecret = "02bc504e06904f44a534679e6898ba2a";
    var responseForAccessToken = await http
        .post(Uri.https('accounts.spotify.com', '/api/token'), headers: {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}'
    }, body: {
      "grant_type": "client_credentials",
    });
    var accessToken = jsonDecode(responseForAccessToken.body)["access_token"];
    var popPlaylist =
        'https://api.spotify.com/v1/playlists/37i9dQZF1DXcBWIGoYBM5M';
    var responseForPopPlaylist = await http.get(Uri.parse(popPlaylist),
        headers: {'Authorization': 'Bearer $accessToken'});
    var jsonArtists =
        jsonDecode(responseForPopPlaylist.body)["tracks"]["items"];
    for (var i = 0; i < jsonArtists.length / 2; i++) {
      var responseForArtistInPopPlaylist = await http.get(
          Uri.parse(jsonArtists[i]["track"]["artists"][0]["href"]),
          headers: {'Authorization': 'Bearer $accessToken'});
      artistsDisplayList.add(
          jsonDecode(responseForArtistInPopPlaylist.body)["images"][0]["url"]);
    }
    var rapPlaylist =
        'https://api.spotify.com/v1/playlists/37i9dQZF1DX0XUsuxWHRQd';
    var responseForRapPlaylist = await http.get(Uri.parse(rapPlaylist),
        headers: {'Authorization': 'Bearer $accessToken'});
    jsonArtists = jsonDecode(responseForRapPlaylist.body)["tracks"]["items"];
    for (var i = 0; i < jsonArtists.length / 2; i++) {
      var responseForArtistInRapPlaylist = await http.get(
          Uri.parse(jsonArtists[i]["track"]["artists"][0]["href"]),
          headers: {'Authorization': 'Bearer $accessToken'});
      if (jsonDecode(responseForArtistInRapPlaylist.body)["images"]
          .isNotEmpty) {
        artistsDisplayList.add(
            jsonDecode(responseForArtistInRapPlaylist.body)["images"][0]
                ["url"]);
      }
    }
    // This section was commented out because as it takes a lot of requests I did not want to overload the Spotify Web API
    // which would cause an API quota limit error if the app is loaded and/or used many subsequent times

    // var hitsPlaylist =
    //     'https://api.spotify.com/v1/playlists/37i9dQZF1DXcRXFNfZr7Tp';
    // var responseForHitsPlaylist = await http.get(Uri.parse(hitsPlaylist),
    //     headers: {'Authorization': 'Bearer $accessToken'});
    // jsonArtists = jsonDecode(responseForHitsPlaylist.body)["tracks"]["items"];
    // for (var i = 0; i < jsonArtists.length; i++) {
    //   var responseForArtistInHitsPlaylist = await http.get(
    //       Uri.parse(jsonArtists[i]["track"]["artists"][0]["href"]),
    //       headers: {'Authorization': 'Bearer $accessToken'});
    //   if (jsonDecode(responseForArtistInHitsPlaylist.body)["images"]
    //       .isNotEmpty) {
    //     artistsDisplayList.add(
    //         jsonDecode(responseForArtistInHitsPlaylist.body)["images"][0]
    //             ["url"]);
    //   }
    // }
    artistsDisplayList.shuffle();
    artistsDisplayList = artistsDisplayList.toSet().toList();
    row1Artists =
        artistsDisplayList.sublist(0, (artistsDisplayList.length / 3).round());
    row2Artists = artistsDisplayList.sublist(
        (artistsDisplayList.length / 3).round(),
        (artistsDisplayList.length / 3).round() * 2);
    row3Artists = artistsDisplayList.sublist(
        (artistsDisplayList.length / 3).round() * 2,
        (artistsDisplayList.length / 3).round() * 3);
    doneGettingPictures = true;
  }

  var artistSizeRatio = 3.5;
  late Timer updateRows;
  var speed = 2.0;

  @override
  void initState() {
    super.initState();
    initializeArtistsDisplay();
    var frames = 0;
    updateRows = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      setState(() {
        if (doneGettingPictures && currentArtist.isEmpty) {
          speed = (2 / (1 + exp(frames / 6 - 8))) * 16 + 2;
          if (row1.hasClients) {
            row1.jumpTo(row1.position.pixels + speed);
            if (row1.position.pixels >=
                (10 + (size / artistSizeRatio)) * row1Artists.length) {
              row1.jumpTo(0);
            }
          }
          if (row2.hasClients) {
            row2.jumpTo(row2.position.pixels - speed);
            if (row2.position.pixels <= 0) {
              row2.jumpTo(
                  ((10 + (size / artistSizeRatio)) * row2Artists.length));
            }
          }
          if (row3.hasClients) {
            row3.jumpTo(row3.position.pixels + speed);
            if (row3.position.pixels >=
                (10 + (size / artistSizeRatio)) * row3Artists.length) {
              row3.jumpTo(0);
            }
          }
        }
        frames++;
      });
    });
  }

  var row1 = ScrollController(initialScrollOffset: 0);
  var row2 = ScrollController(initialScrollOffset: 0);
  var row3 = ScrollController(initialScrollOffset: 0);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: GoogleFonts.sourceSans3(
                fontSize: size / 17, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                currentArtist =
                    await showSearch(context: context, delegate: SearchPage());
                setState(() {});
              })
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
            Widget>[
          if (currentArtist.isNotEmpty) ...[
            Container(
                width: size,
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(currentArtist[1],
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    style: GoogleFonts.sourceSans3(
                        fontSize: size / 9, fontWeight: FontWeight.w400))),
            SizedBox(
                height: size,
                width: size,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Image.network(currentArtist[0], fit: BoxFit.cover))),
            Container(
                margin: const EdgeInsets.only(top: 7),
                width: size,
                child: Text("Follower Count: ${currentArtist[2]}",
                    textAlign: TextAlign.center,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    style: GoogleFonts.sourceSans3(
                        fontSize: size / 12.5, fontWeight: FontWeight.w300))),
            SizedBox(height: size / 4)
          ] else if (doneGettingPictures && currentArtist.isEmpty) ...[
            SingleChildScrollView(
                controller: row1,
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (var pictureIndex = 0;
                      pictureIndex < row1Artists.length * 2;
                      pictureIndex++)
                    Container(
                        decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(6))),
                        height: size / artistSizeRatio,
                        width: size / artistSizeRatio,
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            child: Image.network(row1Artists[
                                pictureIndex % row1Artists.length]))),
                ])),
            SingleChildScrollView(
                controller: row2,
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (var pictureIndex = 0;
                      pictureIndex < row2Artists.length * 2;
                      pictureIndex++)
                    Container(
                        decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(6))),
                        height: size / artistSizeRatio,
                        width: size / artistSizeRatio,
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            child: Image.network(row2Artists[
                                pictureIndex % row2Artists.length]))),
                ])),
            SingleChildScrollView(
                controller: row3,
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (var pictureIndex = 0;
                      pictureIndex < row3Artists.length * 2;
                      pictureIndex++)
                    Container(
                        decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(6))),
                        height: size / artistSizeRatio,
                        width: size / artistSizeRatio,
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            child: Image.network(row3Artists[
                                pictureIndex % row3Artists.length]))),
                ]))
          ] else
            SizedBox(
                height: MediaQuery.of(context).size.height / 13,
                width: MediaQuery.of(context).size.height / 13,
                child: const CircularProgressIndicator())
        ]),
      ),
    );
  }
}

class SearchPage extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (searchResults.isNotEmpty) {
      close(context, searchResults[0]);
    }
    return Container(child: null);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    searchQuery = query;
    var size = MediaQuery.of(context).size.height / 13;
    return FutureBuilder(
        future: getSpotifyArtists(searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              searchResults = snapshot.data as List<dynamic>;
              return Container(
                  margin: const EdgeInsets.all(5),
                  child: ListView(children: [
                    for (var artistIndex = 0;
                        artistIndex < searchResults.length;
                        artistIndex++)
                      GestureDetector(
                          onTap: () {
                            close(context, searchResults[artistIndex]);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 1),
                            height: size,
                            child: Row(children: [
                              SizedBox(
                                  height: size,
                                  width: size,
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4)),
                                      child: Image.network(
                                          searchResults[artistIndex][0],
                                          fit: BoxFit.cover))),
                              Container(
                                  width: MediaQuery.of(context).size.width -
                                      size -
                                      18,
                                  margin: const EdgeInsets.only(left: 6),
                                  child: Text(searchResults[artistIndex][1],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.sourceSans3(
                                          fontSize: size * 0.4)))
                            ]),
                          ))
                  ]));
            }
          }
          return Center(
              child: SizedBox(
                  height: size,
                  width: size,
                  child: const CircularProgressIndicator()));
        });
  }
}

Future<List> getSpotifyArtists(searchQuery) async {
  List<dynamic> spotifyArtists = [];
  if (searchQuery.isEmpty) {
    return spotifyArtists;
  }
  var clientId = "2b72b242cdf34a3baa265d280967dd36";
  var clientSecret = "02bc504e06904f44a534679e6898ba2a";
  var responseForAccessToken = await http
      .post(Uri.https('accounts.spotify.com', '/api/token'), headers: {
    'Authorization':
        'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}'
  }, body: {
    "grant_type": "client_credentials",
  });
  var accessToken = jsonDecode(responseForAccessToken.body)["access_token"];
  var next =
      'https://api.spotify.com/v1/search?q=$searchQuery&type=artist&limit=50';
  while (next != 'null') {
    var responseForArtists = await http.get(Uri.parse(next),
        headers: {'Authorization': 'Bearer $accessToken'});
    var jsonArtists = jsonDecode(responseForArtists.body)["artists"];
    for (var artistItem in jsonArtists["items"]) {
      var artistPicture = artistItem["images"].isEmpty
          ? "https://e-cdns-images.dzcdn.net/images/misc//1000x1000-000000-80-0-0.jpg"
          : artistItem["images"][0]["url"];
      var artistName = artistItem["name"];
      var artistFollowerCount = artistItem["followers"]["total"];
      spotifyArtists.add([artistPicture, artistName, artistFollowerCount]);
    }
    next = jsonArtists["next"].toString();
  }
  return spotifyArtists;
}
