import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ListPage extends StatelessWidget {
  ListPage({@required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "List Page",
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new Scaffold(
        appBar: new AppBar(
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: new Text("$city未来15天的天气"),
          centerTitle: true,
        ),
        body: new WeatherListBody(
          city: "$city",
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherListBody extends StatefulWidget {
  WeatherListBody({this.city});

  final String city;

  @override
  State<StatefulWidget> createState() => new WeatherListBodyState();
}

class WeatherListBodyState extends State<WeatherListBody> {
  Completer<Null> completer;

  List weekWeather;

  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    getWeekWeather();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady)
      return new Container(
          child: SpinKitCircle(
        color: Colors.blue,
        width: 50.0,
        height: 50.0,
      ));
    return new RefreshIndicator(
      child: new ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: weekWeather == null ? 0 : weekWeather.length,
          itemBuilder: (BuildContext context, int index) {
            return buildWeekWeatherItem(weekWeather[index]);
          }),
      onRefresh: _onRefresh,
    );
  }

  Widget buildWeekWeatherItem(weatherItem) {
    var weatherCondition = weatherItem['condition'];
    var lowTemp = weatherItem['low_temperature'];
    var highTemp = weatherItem['high_temperature'];
    var weatherIcon = weatherItem["weather_icon_id"];

    var weekday = weatherItem["date"];
    var dayTime = '$weekday';
    var itemWeatherIcon = 'res/icons/$weatherIcon-icon.webp';

    return new Container(
      padding: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(
                  color: Colors.grey, width: 0.2, style: BorderStyle.solid))),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "$weatherCondition",
                style: new TextStyle(fontSize: 20.0),
              ),
              new Text(
                "$dayTime",
                style: new TextStyle(color: Colors.black45),
              ),
            ],
          ),
          new Text("$lowTemp°C ~ $highTemp°C"),
          new Image.asset(
            itemWeatherIcon,
            width: 32.0,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Future<Null> _onRefresh() async {
    completer = new Completer<Null>();
    getWeekWeather();
    return completer.future;
  }

  void getWeekWeather() async {
    Dio dio = new Dio();
    Response response;
    response = await dio.get(
        "https://www.toutiao.com/stream/widget/local_weather/data/?city=${widget
            .city}");
    if (response.statusCode == HttpStatus.ok) {
      if (this.mounted &&
          response.data["data"] != null &&
          response.data["data"]["weather"] != null) {
        setState(() {
          weekWeather = response.data["data"]["weather"]["forecast_list"];
          _isReady = true;
        });
      }
    }
    if (completer != null && !completer.isCompleted) {
      completer.complete(null);
    }
  }
}
