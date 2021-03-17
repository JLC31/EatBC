import 'dart:async';
import 'dart:convert';

import 'package:EatBC/Globals.dart';
import 'package:EatBC/Location%20Menus/cafemenu.dart';
import 'package:EatBC/Location%20Menus/carneysmenu.dart';
import 'package:EatBC/Location%20Menus/stumenu.dart';
import 'package:EatBC/user_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:intl/intl.dart';

import 'Location Menus/lowermenu.dart';
import 'Location Menus/lyonsmenu.dart';

import 'package:email_launcher/email_launcher.dart';
import 'ad_manager.dart';

const String testDevice = 'Mobile_id';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences().init();
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
  String dropdownValue = "";
  List<String> ddl = [];

  List<String> locationNames = [];

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

    DateTime now = new DateTime.now();
    DateTime date1 = new DateTime(now.year, now.month, now.day);
    DateTime date2 = new DateTime(now.year, now.month, now.day+1);
    DateTime date3 = new DateTime(now.year, now.month, now.day+2);
    DateTime date4 = new DateTime(now.year, now.month, now.day+3);
    DateTime date5 = new DateTime(now.year, now.month, now.day+4);
    final f = new DateFormat('MM/dd/yyyy');


    setState(() {
      Globals.locations = locationNames;
      _locations = locationNames;
      menu = menumenu.sublist(1);
      dropdownValue = f.format(date1);
      for (int i=0; i< 5; i++){
        ddl.add(f.format(DateTime(now.year, now.month, now.day +i)));
      }
    });
  }

  List<List<dynamic>> futureMenu = [[]];

  Future<void> getFutureMenu() async {
    final response = await http.get(
    'https://web.bc.edu/dining/menu/futureMenu_PROD.json'
  );
  final futureData = jsonDecode(response.body);

  Globals.futureData = futureData;

  // var dates = <String>{};

  // for (int j = 0; j<futureData.length; j++){
  //   //print(futureData[j]['Serve_Date']);
  //   dates.add(futureData[j]['Serve_Date']);
  // }

  // List<String> dateList = List<String>();

  // for (String _date in dates){
  //   dateList.add(_date);
  // }

  List<Map<String, dynamic>> first = List<Map<String, dynamic>>();
  List<Map<String, dynamic>> second = List<Map<String, dynamic>>();
  List<Map<String, dynamic>> third = List<Map<String, dynamic>>();
  List<Map<String, dynamic>> fourth = List<Map<String, dynamic>>();

  for (int k = 0; k<futureData.length; k++){
    if (futureData[k]['Serve_Date'] == ddl[1]){
      first.add(futureData[k]);
    }
    if (futureData[k]['Serve_Date'] == ddl[2]){
      second.add(futureData[k]);
    }
    if (futureData[k]['Serve_Date'] == ddl[3]){
      third.add(futureData[k]);
    }
    if (futureData[k]['Serve_Date'] == ddl[4]){
      fourth.add(futureData[k]);
    }
  }

  List<List<dynamic>> futureMenuMenu = [[]];


  futureMenuMenu.add(first);
  futureMenuMenu.add(second);
  futureMenuMenu.add(third);
  futureMenuMenu.add(fourth);

  setState(() {
    futureMenu = futureMenuMenu.sublist(1);
  });
  // futureMenu[# of days into the future][item index]

  }

  void setMenu(int index) {
    if (index == 0)
    {
      setState(() {
        Globals.futureData = Globals.data;
      });
    }
    else{
      setState(() {
        Globals.futureData = futureMenu[index-1];
      });
    }

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

  // DateTime now = new DateTime.now();
  // DateTime date = new DateTime(now.year, now.month, now.day);

  // String dropdownValue = DateTime(now.year, now.month, now.day);

  List<DropdownMenuItem<String>> _dropDownItem() {

    return ddl.map(
      (value) =>
      DropdownMenuItem(
        value: value,
        child: Center(child: Text(value, style: TextStyle(fontSize: 30,fontFamily: "Montserrat"), textAlign: TextAlign.center,)),
      )
    ).toList();
  }

  Timer _timer;

  Future<void> doNothing () async{
    
  }


  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _checkConnectivity();
    //getTodayMenu();
    getFutureMenu();
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
            // title: Text(
            //   'EatBC',
            //   style: TextStyle(
                // fontSize: 36,
                // fontFamily: 'Utopia',
                // color: Color(0xFF8a100b)
            //   ),
            // ),
            title: Container(
              width: MediaQuery.of(context).size.width/2,
              child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 34,
                        color: Color(0xFF8a100b),
                      ),
                      elevation: 0,
                      style: TextStyle(
                        // color: Color(0xFF2A7FC5),
                        // fontSize: 20,
                        // fontFamily: "Poppins"
                        fontSize: 36,
                        fontFamily: 'Utopia',
                        color: Color(0xFF8a100b),
                      ),
                      value: dropdownValue,
                      items: _dropDownItem(),
                      onChanged: (value){
                        print(value);
                        setState(() {
                          dropdownValue=value;
                          if (value == ddl[0])
                          {
                            setMenu(ddl.indexOf(value));
                          }
                          else if (value == ddl[1])
                          {
                            setMenu(ddl.indexOf(value));
                          }
                          else if (value == ddl[2])
                          {
                            setMenu(ddl.indexOf(value));
                          }
                          else if (value == ddl[3])
                          {
                            setMenu(ddl.indexOf(value));
                          }
                          else if (value == ddl[4])
                          {
                            setMenu(ddl.indexOf(value));
                          }
                        //   switch (value) {
                        //     case "1 Month":
                        //       getHistory(
                        //         DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().add(Duration(days: -30, hours: 5))).toString() + "Z",
                        //         DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().add(Duration(hours: 5))).toString() + "Z"
                        //       );
                        //       break;
                        //     case "3 Months":
                        //       getHistory(
                        //         DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().add(Duration(days: -90, hours: 5))).toString() + "Z",
                        //         DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().add(Duration(hours: 5))).toString() + "Z"
                        //       );
                        //       break;
                        //     case "6 Months":
                        //       getHistory(
                        //         DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().add(Duration(days: -180, hours: 5))).toString() + "Z",
                        //         DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().add(Duration(hours: 5))).toString() + "Z"
                        //       );
                        //       break;
                        //     case "1 Year":
                        //       getHistory(
                        //         DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().add(Duration(days: -365, hours: 5))).toString() + "Z",
                        //         DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now().add(Duration(hours: 5))).toString() + "Z"
                        //       );
                        //       break;
                        //     case "All Sessions":
                        //       getHistory(null, null);
                        //       break;
                        //   }
                          
                        });
                        
                        
                      },
                    ),
                  ),
            ),
          ),
        body: RefreshIndicator(
          color: Color(0xFF8a100b),
          displacement: 10,
          onRefresh: doNothing,
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
                            margin: index != 0 ? EdgeInsets.only(left: 24, right: 24, top: 24,) : EdgeInsets.only(left: 24, right: 24, top: 16),
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

