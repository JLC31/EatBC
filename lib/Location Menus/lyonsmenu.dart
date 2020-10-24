import 'package:EatBC/Globals.dart';
import 'package:flutter/material.dart';

import 'package:flutter_circular_chart/flutter_circular_chart.dart';

import 'dart:math';

import 'package:sliding_sheet/sliding_sheet.dart';

import '../ad_manager.dart';

class LyonsMenu extends StatefulWidget {
  @override
  _LyonsMenuState createState() => _LyonsMenuState();
}

class _LyonsMenuState extends State<LyonsMenu> {

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

    // @override
    // void initState() {
    //   _scrollController = ScrollController();
    //   _scrollController.addListener(_scrollListener);
    //   super.initState();
    // }

    @override
    void dispose() {
      _scrollController.removeListener(_scrollListener);
      super.dispose();
    }

  List lyonsBMenu = [];
  List lyonsLMenu = [];

  List lyonsBNut = [];
  List lyonsLNut = [];

  void getLyonsItems() {

    List data = Globals.data;

    List lyonsBItems = [];
    List lyonsLItems = [];

    List lyonsBFacts = [];
    List lyonsLFacts = [];
    
    for (int i = 0; i<data.length; i++)
    {
      if (data[i]['Location_Name'] == 'Lyons Hall' && data[i]['Meal_Name'] == 'BREAKFAST' && data[i]['Menu_Category_Name'] != 'GET Offerings (as available)')
      {
        lyonsBItems.add(data[i]['Recipe_Print_As_Name']);
        lyonsBFacts.add(data[i]);
      }
      else if (data[i]['Location_Name'] == 'Lyons Hall' && data[i]['Meal_Name'] == 'LUNCH' && data[i]['Menu_Category_Name'] != 'GET Offerings (as available)'){
        lyonsLItems.add(data[i]['Recipe_Print_As_Name']);
        lyonsLFacts.add(data[i]);
      }

    }

    setState(() {
      lyonsBMenu = lyonsBItems;
      lyonsLMenu = lyonsLItems;

      lyonsBNut = lyonsBFacts;
      lyonsLNut = lyonsLFacts;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    getLyonsItems();
    Ads.hideBannerAd();
    _sheetController = SheetController();
    super.initState();
  }

  ValueNotifier<SheetState> sheetState = ValueNotifier(SheetState.inital());
  SheetState get state => sheetState.value;
  set state(SheetState value) => sheetState.value = value;


  SheetController _sheetController;
  int _pageState = 0;

  void _showDialog(String foodItem, int index, int itemIndex) {
    final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();
    List menu = [];
    if (itemIndex == 0){
      menu = lyonsBNut;
    }
    else if (itemIndex == 1){
      menu = lyonsLNut;
    }

    String carb = '';
    if (menu[index]['Total_Carb'] != null && menu[index]['Total_Carb'].length > 0) {
      carb = menu[index]['Total_Carb'].substring(0, menu[index]['Total_Carb'].length - 1);
    }
    var carbDouble = double.parse(carb);
    assert(carbDouble is double);

    String fat = '';
    if (menu[index]['Total_Fat'] != null && menu[index]['Total_Fat'].length > 0) {
      fat = menu[index]['Total_Fat'].substring(0, menu[index]['Total_Fat'].length - 1);
    }
    var fatDouble = double.parse(fat);
    assert(fatDouble is double);

    String pro = '';
    if (menu[index]['Protein'] != null && menu[index]['Protein'].length > 0) {
      pro = menu[index]['Protein'].substring(0, menu[index]['Protein'].length - 1);
    }
    var proDouble = double.parse(pro);
    assert(proDouble is double);

    double total = carbDouble + fatDouble + proDouble;

    List<double> snaps = [0.3, 1.0];

    showSlidingBottomSheet(
      context, 
      builder: (context) {
        return SlidingSheetDialog(
          duration: Duration(milliseconds: 600),
          //backdropColor: Colors.grey[700].withOpacity(0.7),
          controller: _sheetController,
          elevation: 8,
          cornerRadius: 15,
          snapSpec: SnapSpec(
            snap: true,
            snappings: snaps,
            positioning: SnapPositioning.relativeToAvailableSpace,
          ),
          builder: (context, state) {
            try {
              return Material(
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height/1.45,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height/80,
                      ),
                      Container(
                        height: 7,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey[300]
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height/60,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        child: Center(
                          child: Text(
                            menu[index]['Recipe_Print_As_Name'],
                            style: TextStyle(
                              fontSize: menu[index]['Recipe_Print_As_Name'].length > 58 ? (MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 28 : MediaQuery.of(context).size.height / 32) : (MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 28 : MediaQuery.of(context).size.height / 30),
                              fontFamily: 'Arabic',
                              color: Colors.black
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 0),
                      Center(
                        child: Text(
                          menu[index]['Menu_Category_Name'].replaceAll("&amp;", "&"),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: 'Montserrat',
                            fontSize: MediaQuery.of(context).size.height / 56,
                          ),
                        ),
                      ),
                      menu[index]['Recipe_Web_Codes'].trim() == "" ? SizedBox(height: 0) : SizedBox(height: MediaQuery.of(context).size.height/80,),
                      Text(
                        menu[index]['Recipe_Web_Codes'],
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 38 : MediaQuery.of(context).size.height / 45,
                          fontWeight: FontWeight.w600,
                          color: Colors.black
                        ),
                        textAlign: TextAlign.center,
                      ),
                      menu[index]['Recipe_Web_Codes'].trim() == "" ? SizedBox(height: 0) : SizedBox(height: MediaQuery.of(context).size.height/80,),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          'Allergens: ' + menu[index]['Allergens'],
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 38 : MediaQuery.of(context).size.height / 45,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      new AnimatedCircularChart(
                        key: _chartKey,
                        size: Size(
                          MediaQuery.of(context).size.height / 3,
                          MediaQuery.of(context).size.height / 3
                        ),
                        initialChartData: <CircularStackEntry>[
                          new CircularStackEntry(
                            <CircularSegmentEntry>[
                              new CircularSegmentEntry(
                                (((carbDouble/total) * (pow(10.0, 2))).round().toDouble() / (pow(10.0, 2)))*100,
                                Colors.blue[300],
                                rankKey: 'completed',
                              ),
                              new CircularSegmentEntry(
                                (((fatDouble/total) * (pow(10.0, 2))).round().toDouble() / (pow(10.0, 2)))*100,
                                Colors.red[300],
                                rankKey: 'remaining',
                              ),
                              new CircularSegmentEntry(
                                (((proDouble/total) * (pow(10.0, 2))).round().toDouble() / (pow(10.0, 2)))*100 + 5,
                                Colors.purple[300],
                                rankKey: 'completed',
                              ),
                            ],
                            rankKey: 'progress',
                          ),
                        ],
                        chartType: CircularChartType.Radial,
                        percentageValues: true,
                        holeLabel: menu[index]['Calories'] + ' cal',
                        labelStyle: new TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 36,
              
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height/80,),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Carbs: ',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 38 : MediaQuery.of(context).size.height / 45,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: menu[index]['Total_Carb'],
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 38 : MediaQuery.of(context).size.height / 45,
                                      color: Colors.blue[300],
                                    ),
                                  )
                                ]
                                
                                //textAlign: TextAlign.center,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: '  Fats: ',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 38 : MediaQuery.of(context).size.height / 45,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: menu[index]['Total_Fat'],
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 38 : MediaQuery.of(context).size.height / 45,
                                      color: Colors.red[300],
                                    ),
                                  )
                                ]
                                
                                //textAlign: TextAlign.center,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: '  Protein: ',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 38 : MediaQuery.of(context).size.height / 45,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: menu[index]['Protein'],
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 38 : MediaQuery.of(context).size.height / 45,
                                      color: Colors.purple[300],
                                    ),
                                  )
                                ]
                                //textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } catch (e) {
              return Material(
                child: Container(
                  height: MediaQuery.of(context).size.height / 5,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height/80,
                      ),
                      Container(
                        height: 7,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey[300]
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height/25,
                      ),
                      Center(
                        child: Text(
                          //menu[index]['Recipe_Print_As_Name'],
                          'No nutritional information available',
                          style: TextStyle(
                            fontSize: menu[index]['Recipe_Print_As_Name'].length > 58 ? (MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 28 : MediaQuery.of(context).size.height / 32) : (MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height / 28 : MediaQuery.of(context).size.height / 30),
                            fontFamily: 'Arabic',
                            color: Colors.black
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        );
      }
    );
  }

  _onPageViewChange(int page){
    setState(() {
      _pageState = page;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    List mealItems = [lyonsBMenu, lyonsLMenu];
    String mealName = '';

    switch(_pageState){
      case 0:
        mealName = 'Breakfast';
        break;
      case 1:
        mealName = 'Lunch';
        break;
      case 2:
        mealName = 'Dinner';
        break;
      case 3:
        mealName = 'Late Night';
        break;
      default:
        mealName = 'Breakfast';
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              expandedHeight: MediaQuery.of(context).size.height <= 750 ? MediaQuery.of(context).size.height/3.8 : MediaQuery.of(context).size.height/4.5,
              backgroundColor: Colors.white,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Center(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      isShrink ? '$mealName' : 'Lyons Hall',
                      style: TextStyle(
                        fontSize: isShrink ? 28 : 28,
                        fontFamily: 'Utopia',
                        color: isShrink ? Color(0xFF8a100b) : Colors.white,
                        shadows: <Shadow>[
                          Shadow(
                            offset: isShrink ? Offset(0, 0): Offset(0.0, 2.0),
                            blurRadius: isShrink ? 0 : 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          // Shadow(
                          //   offset: Offset(10.0, 10.0),
                          //   blurRadius: 8.0,
                          //   color: Color.fromARGB(125, 0, 0, 255),
                          // ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                background: Image.asset(
                  'assets/images/insidelyons.jpeg',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ];
        },
      body: Container(
        child: PageView.builder(
          itemCount: 2,
          onPageChanged: _onPageViewChange,
          controller: PageController(viewportFraction: 1),
          itemBuilder: (BuildContext context, int itemIndex){
            // if (itemIndex == 0){
            //   mealName = 'Breakfast';
            // }
            // else if (itemIndex == 1){
            //     mealName = 'Lunch';
            // }
            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    padding: const EdgeInsets.only(top: 0),
                    itemCount: mealItems[itemIndex].length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => _showDialog('${mealItems[itemIndex][index]}', index, itemIndex),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          //margin: EdgeInsets.only(top: 2),
                          height: 50,
                          child: Container(
                            margin: EdgeInsets.only(left: 2),
                            child: Text(
                              ' ${mealItems[itemIndex][index]}',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                                fontSize: MediaQuery.of(context).size.height <= 750 ? 18 : 19,
                                fontWeight: FontWeight.w400
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(.075)), top: index == 0 ? BorderSide(color: Colors.black.withOpacity(.075)) : BorderSide(color: Colors.black.withOpacity(.0))),
                          ),
                        ),
                      );
                    }
                    ), 
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}