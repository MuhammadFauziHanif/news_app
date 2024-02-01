import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/widgets/news_web_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> newsList = [];
  List<dynamic> favoriteList = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<List> fetchNews() async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?q=keyword&apiKey=4b397c0b925c48649a61b00c6ab69622'));

    if (response.statusCode == 200) {
      newsList = jsonDecode(response.body)['articles'];
      return newsList;
    } else {
      throw Exception('Failed to load news');
    }
  }

  void addToFavorites(int index) {
    setState(() {
      favoriteList.add(newsList[index]);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Added to favorites'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('BSI News App'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildNewsTab(),
            buildFavoritesTab(),
          ],
        ),
      ),
    );
  }

  Widget buildNewsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await fetchNews();
      },
      child: FutureBuilder(
        future: fetchNews(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                var news = snapshot.data[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsWebView(news['url']),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.network(news['urlToImage'] ?? ''),
                            IconButton(
                              icon: Icon(Icons.favorite),
                              onPressed: () => addToFavorites(index),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            news['title'] ?? 'No Title',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildFavoritesTab() {
    return ListView.builder(
      itemCount: favoriteList.length,
      itemBuilder: (context, index) {
        var news = favoriteList[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsWebView(news['url']),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(news['urlToImage'] ?? ''),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    news['title'] ?? 'No Title',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
