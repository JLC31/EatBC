import 'dart:convert';

import 'package:EatBC/Globals.dart';
import 'package:EatBC/Location%20Menus/cafemenu.dart';
import 'package:EatBC/Location%20Menus/carneysmenu.dart';
import 'package:EatBC/Location%20Menus/stumenu.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:splashscreen/splashscreen.dart';

import 'Location Menus/lowermenu.dart';
import 'Location Menus/lyonsmenu.dart';

import 'package:email_launcher/email_launcher.dart';
import 'ad_manager.dart';

const String testDevice = 'Mobile_id';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EatBC',
      home: Splash(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  ScrollController _scrollController;

    bool lastStatus = true;

    _scrollListener() {
      if (isShrink != lastStatus) {
        setState(() {
          lastStatus = isShrink;
        });
      }
    }

    bool get isShrink {
      return _scrollController.hasClients &&
          _scrollController.offset > (200 - kToolbarHeight);
    }

  List _locations = [];

  List<List<dynamic>> menu = [[]];

  Future<void> getTodayMenu() async {
    final response = await http.get(
      'https://web.bc.edu/dining/menu/todayMenu_PROD.json'
    );
    final data = jsonDecode(response.body);

    Globals.data = data;

    var locations = <String>{};

    for (int i = 0; i < data.length; i++) {
      locations.add(data[i]['Location_Name'].trim());
    }

    List<String> locationNames = [];

    for (String name in locations){
      locationNames.add(name);
    }

    List<dynamic> lower = [LowerMenu(), 'loweroutside.jpg', 'Lower Live/Heights Room'];
    List<dynamic> upper = [CarneysMenu(), 'mac.jpeg', "Carney's"];
    List<dynamic> lyons = [LyonsMenu(), 'insidelyons.jpeg', "Lyons Hall"];
    List<dynamic> cafe = [CafeMenu(), 'cafe129.jpg', "Cafe 129"];
    List<dynamic> stuart = [StuMenu(), 'stu.jpg', "Stuart Hall"];

    List<List<dynamic>> menumenu = [[]];

    for (int i = 0; i < locationNames.length; i++)
    {
      if (locationNames[i]=="Lower Live/Heights Room"){
        menumenu.add(lower);
      }
      else if (locationNames[i]=="Carney's"){
        menumenu.add(upper);
      }
      else if (locationNames[i]=="Lyons Hall"){
        menumenu.add(lyons);
      }
      else if (locationNames[i]=="Cafe 129"){
        menumenu.add(cafe);
      }
      else if (locationNames[i]=="Stuart Hall"){
        menumenu.add(stuart);
      }
    }


    setState(() {
      Globals.locations = locationNames;
      _locations = locationNames;
      menu = menumenu.sublist(1);
    });
  }

  // _showErrorDialog() {
  //   errorDialog(
  //     context: context,
  //     builder: (context){
  //       return Center(
  //         child: Container(
  //           child: Text(
  //             "Connection error"
  //           ),
  //         ),
  //       );
  //     }
  //   )
  // }

  _checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none){
      Alert(
        context: context,
        title: "Connection error",
        desc: "Check your internet connection and try again",
      ).show();
    }
    else{
      getTodayMenu();
    }
  }


  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _checkConnectivity();
    //getTodayMenu();
    Ads.initialize();
    Ads.showBannerAd();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    Ads.hideBannerAd();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShowAboutPage()),
              ).then((value) {
                Ads.showBannerAd();
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(right: 16),
              child: Icon(Icons.info_outline, color: Color(0xFF8a100b))
            ),
          ),
        ],
        automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              'EatBC',
              style: TextStyle(
                fontSize: 36,
                fontFamily: 'Utopia',
                color: Color(0xFF8a100b)
              ),
            ),
          ),
        body: RefreshIndicator(
          color: Color(0xFF8a100b),
          displacement: 10,
          onRefresh: getTodayMenu,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  padding: const EdgeInsets.all(0),
                  itemCount: menu.length,
                  itemBuilder: (BuildContext context, int index) {
                    try {
                      return GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            margin: index != 0 ? EdgeInsets.only(left: 16, right: 16, top: 16,) : EdgeInsets.only(left: 16, right: 16, top: 8),
                            height: 240,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(3), topRight: Radius.circular(3), bottomLeft: Radius.circular(3), bottomRight: Radius.circular(3)),
                                  child: Image.asset(
                                    'assets/images/${menu[index][1]}',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                Container(
                                  height: 30,
                                  width: MediaQuery.of(context).size.width,
                                  //margin: EdgeInsets.only(left: 0),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      '${menu[index][2]}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Montserrat',
                                        fontSize: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 38 : MediaQuery.of(context).size.height / 47.5,
                                        fontWeight: FontWeight.w700
                                      ),
                                    ),
                                ),
                              ],
                            )
                          ),
                          Divider(
                            thickness: .5,
                            color: Colors.grey[500],
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => menu[index][0]
                        ),
                      ).then((value) {
                        Ads.showBannerAd();
                      },
                      ),
                    );
                    }
                    catch (e) {
                      return Container(
                        height: 100,
                        child: Center(
                          child: Container(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8a100b)),
                            ),
                          ),
                        ),
                      );
                    }
                    
                  }
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit, color: Colors.white), label: '', activeIcon: Icon(Icons.ac_unit, color: Colors.white)),
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit, color: Colors.white), label: '', activeIcon: Icon(Icons.ac_unit, color: Colors.white)),
        ],
        backgroundColor: Colors.white,
      ),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: MyHomePage(),
      image: Image.asset('assets/images/EatBCApp.JPG'),
      photoSize: 100,
      loaderColor: Color(0xFF8a100b),
      title: Text(
        'EatBC',
        style: TextStyle(
          color: Color(0xFF8a100b),
          fontSize: 40,
          fontFamily: 'Utopia'
        ),
      ),
    );
  }
}

void _launchEmail() async {
    List<String> to = ['lacavajo@bc.edu'];
    String subject = 'EatBC App';

    Email email = Email(to: to, subject: subject);
    await EmailLauncher.launch(email);
  }

class ShowAboutPage extends StatefulWidget {
  @override
  _ShowAboutPageState createState() => _ShowAboutPageState();
}

class _ShowAboutPageState extends State<ShowAboutPage> {

  @override
  void initState() {  
    Ads.hideBannerAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back, color: Color(0xFF8a100b),),
          onTap: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '',
          style: TextStyle(
            fontSize: 36,
            fontFamily: 'Utopia',
            color: Color(0xFF8a100b)
          ),
        ),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Center(child: Image.asset('assets/images/EatBCApp.JPG', height: 150,)),
              SizedBox(
                height: 10,
              ),
              Text(
                'EatBC',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Montserrat',
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Copyright © John LaCava, 2020',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  color: Colors.grey[600]
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Questions? Problems? Suggestions?\nSend me an email!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () => _launchEmail,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline, color: Colors.black, size: 30,),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'lacavajo@bc.edu',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "There may be items that appear on this menu that are not available in the dining location. If a dining location is not appearing, that may mean that the location is closed.",
                style: TextStyle(
                  fontSize: 18
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

