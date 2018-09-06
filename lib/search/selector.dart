import 'dart:async';
import '../data/data.dart';
import 'dart:collection';
import 'search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SelectorPage extends StatefulWidget {
  SelectorPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SelectorPageState createState() => new _SelectorPageState();
}

class _SelectorPageState extends State<SelectorPage> {
  Map<String, dynamic> cityUpWordStartIndex = new HashMap();
  List<String> cityUpWordArr = new List();

  ScrollController scrollController = new ScrollController();
  double tileTileHeight = 32.0;
  double selectUpWordTileHeight = 24.0;
  int hotCityHeightScale = 1;
  String selectedUpWord = "", curSelectedUpWord = "";

  bool isSearchResultPage = false;
  List<Map> searchMap = new List();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < china_cities_data.length; i++) {
      String currentFLetter = getFirstLetter(china_cities_data[i]["pinyin"]);
      String preFLetter =
          i >= 1 ? getFirstLetter(china_cities_data[i - 1]["pinyin"]) : "";

      if (currentFLetter != preFLetter) {
        cityUpWordStartIndex[currentFLetter] = i;
        cityUpWordArr.add(currentFLetter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: _getTopSearchWidget(),
      ),
      body: _getContentWidget(),
    );
  }

  Widget _getContentWidget() {
    if (isSearchResultPage) {
      return new SearchResult(searchMap);
    } else {
      return new Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          _getCityList(),
          _getWordSelectWidget(),
          _getShowSelectedCenterWidget()
        ],
      );
    }
  }

  Widget _getTopSearchWidget() {
    return new Row(
      children: <Widget>[
        new Expanded(
            child: new Container(
          alignment: Alignment.centerLeft,
          height: 32.0,
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          margin: const EdgeInsets.only(right: 20.0),
          child: new TextField(
            onChanged: _search,
            style: new TextStyle(fontSize: 14.0, color: Colors.black),
            decoration: new InputDecoration.collapsed(
                hintText: Strings.SEARCH_HINT_TEXT),
          ),
          decoration: new BoxDecoration(color: Colors.grey[200]),
        )),
      ],
    );
  }

  void _search(String name) {
    if (name != null && name.length > 0) {
      if (name.contains(new RegExp("^[\u4e00-\u9fff]"))) {
        _startSearch(name, "name");
      } else {
        _startSearch(name, "pinyin");
      }
    } else {
      _setListState();
    }
  }

  void _startSearch(String name, String key) {
    searchWord(name, key).then((List<Map> map) {
      searchMap = map;
      _setSearchResultState();
    });
  }

  Future<List<Map>> searchWord(String name, String key) async {
    List<Map> result = new List();
    for (int i = 0; i < china_cities_data.length; i++) {
      if (china_cities_data[i][key].toString().contains(name)) {
        result.add(china_cities_data[i]);
      }
    }
    return result;
  }

  _setSearchResultState() {
    setState(() {
      isSearchResultPage = true;
      selectedUpWord = "";
    });
  }

  _setListState() {
    setState(() {
      isSearchResultPage = false;
      selectedUpWord = "";
    });
  }

  Widget _getCityList() {
    return new ListView(
      children: _getCityItem(),
      controller: scrollController,
    );
  }

  Widget _getHotCityList() {
    return new Container(
        padding: const EdgeInsets.only(right: 20.0),
        child: new Column(
          children: _getHotCityItem(),
        ));
  }

  List<Widget> _getHotCityItem() {
    int rowNum = 3;
    int columnNum = 1;
    columnNum = (china_cities_hot_data.length % rowNum > 0)
        ? (china_cities_hot_data.length / rowNum + 1).toInt()
        : (china_cities_hot_data.length / rowNum).toInt();
    if (columnNum >= 1) {
      hotCityHeightScale = columnNum;
    }
    List<Widget> arr = new List();
    for (int i = 0; i < columnNum; i++) {
      List<Widget> row = new List();
      for (int j = 0; j < rowNum; j++) {
        if ((i * rowNum + j) <= (china_cities_hot_data.length - 1)) {
          row.add(new GestureDetector(
            child: new Container(
              alignment: Alignment.center,
              color: Colors.grey[200],
              child: new Text(china_cities_hot_data[i * rowNum + j]["name"]),
              width: 76.0,
              height: 32.0,
            ),
            onTap: () {
              _onTileClick(china_cities_hot_data[i * rowNum + j]["name"]);
            },
          ));
        } else {
          row.add(new Container(
            width: 76.0,
            height: 32.0,
          ));
        }
      }
      arr.add(new Container(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row,
        ),
        height: Values.TILE_HEIGHT,
      ));
    }

    return arr;
  }

  List<Widget> _getCityItem() {
    List<Widget> arr = new List();
    for (int i = 0; i < china_cities_data.length; i++) {
      String currentFLetter = getFirstLetter(china_cities_data[i]["pinyin"]);
      String preFLetter =
          i >= 1 ? getFirstLetter(china_cities_data[i - 1]["pinyin"]) : "";

      if (currentFLetter != preFLetter) {
        String tempTitle = currentFLetter;
        if (_isHotCityDes(tempTitle)) {
          tempTitle = Strings.HOT_CITY_TITLE;
        } else if (_isLocationCityDes(tempTitle)) {
          tempTitle = Strings.LOCATION_CITY_TITLE;
        }
        arr.add(new Container(
          alignment: Alignment.centerLeft,
          color: Colors.grey[200],
          height: tileTileHeight,
          padding: const EdgeInsets.only(left: 24.0),
          child: new Text(tempTitle),
        ));
      }

      if (_isHotCityDes(currentFLetter)) {
        arr.add(_getHotCityList());
      } else {
        arr.add(new GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: new Container(
            height: Values.TILE_HEIGHT,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24.0),
            child: new Text(china_cities_data[i]["name"]),
          ),
          onTap: () {
            _onTileClick(china_cities_data[i]["name"]);
          },
        ));
      }
    }
    return arr;
  }

  Widget _getWordSelectWidget() {
    return new SizedBox(
      child: new ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          return new GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (TapUpDetails detail) {
              _setUpWordUpState();
            },
            onTapDown: (TapDownDetails detail) {
              _setUpWordDownState(cityUpWordArr[index]);
            },
            onVerticalDragUpdate: (DragUpdateDetails detail) {
              RenderSliverList sliverList = c.findRenderObject();
              RenderBox getBox = sliverList.firstChild;
              var local = getBox.globalToLocal(detail.globalPosition);
              debugPrint(
                  local.toString() + "|" + detail.globalPosition.toString());

              _setSlideState(local.dy);
            },
            onVerticalDragEnd: (DragEndDetails detail) {
              _setUpWordUpState();
            },
            child: new Container(
              height: selectUpWordTileHeight,
              alignment: Alignment.center,
              child: new Text(_isHotCityDes(cityUpWordArr[index])
                  ? Strings.HOT_CITY_UP_WORD
                  : (_isLocationCityDes(cityUpWordArr[index])
                      ? Strings.LOCATION_CITY_UP_WORD
                      : cityUpWordArr[index])),
            ),
          );
        },
        itemCount: cityUpWordArr.length,
      ),
      width: 44.0,
    );
  }

  Widget _getShowSelectedCenterWidget() {
    if (selectedUpWord.length > 0) {
      return new Center(
        child: new Container(
          color: Colors.grey,
          child: new SizedBox(
            width: 100.0,
            height: 100.0,
            child: new Center(
              child: new Text(
                selectedUpWord,
                style: new TextStyle(color: Colors.white, fontSize: 44.0),
              ),
            ),
          ),
        ),
      );
    }
    return new Container();
  }

  _setUpWordDownState(String word) {
    setState(() {
      selectedUpWord = _isHotCityDes(word)
          ? Strings.HOT_CITY_UP_WORD
          : (_isLocationCityDes(word) ? Strings.LOCATION_CITY_UP_WORD : word);
    });

    _setScrollToWord(word);
  }

  _setUpWordUpState() {
    setState(() {
      selectedUpWord = "";
    });
  }

  _setSlideState(double localPosition) {
    double minHeight = 0.0;
    double maxHeight = cityUpWordArr.length * selectUpWordTileHeight;
    if (localPosition >= minHeight && localPosition <= maxHeight) {
      double index = localPosition / selectUpWordTileHeight;
      if (index >= 0) {
        String slideToWord = cityUpWordArr[index.toInt()];

        if (curSelectedUpWord != slideToWord) {
          setState(() {
            selectedUpWord = _isHotCityDes(slideToWord)
                ? Strings.HOT_CITY_UP_WORD
                : (_isLocationCityDes(slideToWord)
                    ? Strings.LOCATION_CITY_UP_WORD
                    : slideToWord);
          });
          _setScrollToWord(slideToWord);
          curSelectedUpWord = slideToWord;
        }
      }
    }
  }

  _setScrollToWord(String word) {
    double value = 0.0;
    if (cityUpWordArr.indexOf(word) == 0) {
    } else {
      value = (cityUpWordStartIndex[word] +
                  (hotCityHeightScale - 1) * (_isHotCityDes(word) ? 0 : 1)) *
              Values.TILE_HEIGHT +
          cityUpWordArr.indexOf(word) * tileTileHeight;
    }
    scrollController.animateTo(value,
        duration: new Duration(milliseconds: 10), curve: Curves.ease);
  }

  _onTileClick(String name) {
    Navigator.of(context).pop(name);
  }

  String getFirstLetter(String pinyin) {
    return pinyin.substring(0, 1).toUpperCase();
  }

  bool _isHotCityDes(String pinyin) {
    return pinyin == "0";
  }

  bool _isLocationCityDes(String pinyin) {
    return pinyin == "1";
  }
}
