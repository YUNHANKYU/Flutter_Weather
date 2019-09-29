import 'package:flutter/material.dart';
import 'util/utils.dart' as util;
import 'dart:convert';

import 'util/dfs_xy_conv.dart';

import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity, util.numOfResult);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu), onPressed: _showStuff,
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              color: Colors.black,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: Text(
              'Spokane',
              style: cityStyle(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Icon(Icons.thumb_up, color: Colors.red,),
          ),

          Container(
            margin: const EdgeInsets.fromLTRB(30.0, 290.0, 0.0, 0.0),
            child: updateTempWidget(""),
          )
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city, int numOfResult) async{
    LatXLngY point = convertGRID_GPS(0, 36.078776, 129.374873);

    print("Point X : ${point.x}");
    print("Point Y : ${point.y}");

    String apiUrl = 'http://newsky2.kma.go.kr/service/SecndSrtpdFrcstInfoService2/ForecastSpaceData?'
        'serviceKey=$appId'
        '&base_date=${util.dateConvert(DateTime.now().toIso8601String().substring(0,10))}'
        '&base_time=0500'
        '&nx=60'
        '&ny=127'
        '&numOfRows=$numOfResult'
        '&pageNo=1'
        '&_type=json';

//    print(apiUrl);

    http.Response response = await http.get(apiUrl);

    return jsonDecode(response.body);
  }

  Widget updateTempWidget(String s){
    return FutureBuilder(
      future: getWeather(util.appId, util.defaultCity, util.numOfResult),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot){
        if(snapshot.hasData){
          Map content = snapshot.data;
          return Container(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(content['response']['body']['items']['item'][0]['category'], style: TextStyle(color: Colors.white),),
                )
              ],
            ),
          );
        }else{
          return Container();
        }
      },
    );
  }

}

TextStyle cityStyle(){
  return TextStyle(
    color: Colors.white, fontSize: 22.9, fontStyle: FontStyle.italic
  );
}


TextStyle tempStyle(){
  return TextStyle(
      color: Colors.white, fontSize: 49.9, fontStyle: FontStyle.normal,fontWeight: FontWeight.w500
  );
}