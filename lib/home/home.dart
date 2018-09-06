import 'dart:io';
import 'dart:async';
import '../list/list.dart';
import '../search/selector.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatelessWidget {
  static const navigateToListPageKey = Key('navigateToListPage');

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'HomePage',
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new Scaffold(
        body: new WeatherHome(),
      ),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/select_city': (BuildContext context) => new SelectorPage(),
      },
    );
  }
}

class WeatherHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new WeatherHomeState();
}

class WeatherHomeState extends State<WeatherHome> {
  var temp = 0;

  String city = "上海";

  var updateTime = "更新时间获取中...";

  var weather = "数据获取中...";

  var weatherImage = "res/backgrounds/sunny-bg.webp";

  var weatherMap = {
    '晴': 'sunny',
    '多云': 'cloudy',
    '阴': 'overcast',
    '雨': 'lightrain',
    '小雨': 'lightrain',
    '中雨': 'lightrain',
    '大雨': 'heavyrain',
    '阵雨': 'heavyrain',
    '雷阵雨': 'heavyrain',
    '雪': 'snow'
  };

  var todayWeather;

  List forecast;

  Completer<Null> completer;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return homeBody();
  }

  Widget homeBody() {
    return new RefreshIndicator(
        child: new CustomScrollView(
          primary: true,
          slivers: <Widget>[
            new SliverList(
              delegate: new SliverChildListDelegate(<Widget>[
                weatherBody(),
                timeTips(),
                buildForeCast(),
                updateInfo(),
              ]),
            )
          ],
        ),
        onRefresh: _refreshHandler);
  }

  Widget weatherBody() {
    return new Container(
      alignment: Alignment.bottomCenter,
      height: 380.0,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          alignment: Alignment.topCenter,
          fit: BoxFit.fitWidth,
          image: new AssetImage(weatherImage),
        ),
      ),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          citySelectDetails(),
          new Text(
            "$temp°",
            style: new TextStyle(fontSize: 64.0),
          ),
          new Text(
            weather,
            style: new TextStyle(fontSize: 18.0, color: Colors.black38),
          ),
          new Padding(
            padding: new EdgeInsets.symmetric(vertical: 40.0),
          ),
          todayWeatherDetails(),
        ],
      ),
    );
  }

  Widget citySelectDetails() {
    return new Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(32.0),
      child: new Column(
        children: <Widget>[
          new FloatingActionButton(
              tooltip: '城市选择',
              child: new Text("$city"),
              onPressed: () {
                _goCitySelectPage();
              }),
        ],
      ),
    );
  }

  Widget todayWeatherDetails() {
    DateTime dateTime = new DateTime.now();
    String todayTime = "${dateTime.year}-${dateTime.month}-${dateTime.day} 今天";
    String todayWeatherDetails = "0° ~ 0°";
    if (todayWeather != null) {
      todayWeatherDetails = "${todayWeather[
          'low_temperature']}° ~ ${todayWeather['high_temperature']}°";
    }
    return new GestureDetector(
      key: HomePage.navigateToListPageKey,
      onTap: _goWeatherListPage,
      child: new Container(
        height: 49.0,
        padding: new EdgeInsets.symmetric(vertical: 14.0),
        margin: new EdgeInsets.symmetric(horizontal: 16.0),
        decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(
            color: Colors.black38,
            style: BorderStyle.solid,
            width: 0.3,
          )),
        ),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(
              todayTime,
              style: new TextStyle(color: Colors.black45),
            ),
            new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Text(
                  todayWeatherDetails,
                  style: new TextStyle(color: Colors.black45),
                ),
                new Padding(padding: new EdgeInsets.symmetric(horizontal: 2.0)),
                new Image.asset(
                  'res/icons/arrow-icon.webp',
                  height: 12.0,
                  fit: BoxFit.contain,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget timeTips() {
    return new Container(
      alignment: Alignment.center,
      padding: new EdgeInsets.only(top: 6.0, bottom: 6.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Image.asset(
            'res/icons/time-icon.webp',
            width: 16.0,
            fit: BoxFit.contain,
          ),
          new Text(
            "未来24小时天气预测",
            style: new TextStyle(
              color: Colors.black45,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildForeCast() {
    return new Container(
      height: 160.0,
      child: new ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast == null ? 0 : forecast.length,
        itemBuilder: (BuildContext context, int index) {
          var forecastItem = forecast[index];
          return buildForeCastItem(forecastItem);
        },
      ),
    );
  }

  Widget buildForeCastItem(forecastItem) {
    String forecastWeather = forecastItem['weather_icon_id'];
    String forecastTemp = forecastItem['temperature'];
    var itemTime = forecastItem["hour"];
    return new Container(
      padding: new EdgeInsets.only(left: 6.0, right: 6.0),
      margin: new EdgeInsets.only(left: 8.0, right: 8.0),
      alignment: Alignment.topCenter,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Padding(
            child: new Text("$itemTime时",
                style: new TextStyle(
                  color: Colors.black38,
                  fontSize: 16.0,
                )),
            padding: new EdgeInsets.only(top: 12.0, bottom: 12.0),
          ),
          new Image.asset(
            "res/icons/$forecastWeather-icon.webp",
            width: 32.0,
            fit: BoxFit.contain,
          ),
          new Padding(
            padding: new EdgeInsets.only(top: 12.0, bottom: 12.0),
            child: new Text(
              "$forecastTemp°",
              style: new TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          )
        ],
      ),
    );
  }

  Widget updateInfo() {
    return new Container(
      alignment: Alignment.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            "更新时间: $updateTime",
            style: new TextStyle(
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  void getWeather() async {
    Dio dio = new Dio();
    Response response;
    response = await dio.get(
        "https://www.toutiao.com/stream/widget/local_weather/data/?city=$city");
    if (response.statusCode == HttpStatus.ok) {
      var data = response.data;

      if (this.mounted) {
        setState(() {
          temp = data['data']['weather']['current_temperature'];
          updateTime = data['data']['weather']['update_time'];
          String tempWeather = data['data']['weather']["current_condition"];
          weather = tempWeather;
          String currentWeatherIcon = weatherMap[tempWeather];
          weatherImage = 'res/backgrounds/$currentWeatherIcon-bg.webp';
          todayWeather = data['data']['weather'];
          forecast = data['data']['weather']["hourly_forecast"];
        });
      }
    }

    if (completer != null && !completer.isCompleted) {
      completer.complete(null);
    }
  }

  Future<Null> _refreshHandler() async {
    completer = new Completer<Null>();
    getWeather();
    return completer.future;
  }

  void _goWeatherListPage() async {
    print("_goWeatherListPage");
    await Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
      return new ListPage(city: '$city');
    }));
  }

  void _goCitySelectPage() async {
    print("_goCitySelectPage");
    var result = await Navigator.pushNamed(context, '/select_city');
    if (this.mounted && result != null) {
      setState(() {
        city = result;
        _refreshHandler();
      });
    }
  }
}
