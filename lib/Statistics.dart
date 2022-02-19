import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/ProjectData.dart';
import 'calendar.dart' as CustomCalendar;

class Statistics extends StatefulWidget {
  StatisticsState createState() => StatisticsState();
}

class StatisticsState extends State<Statistics> {

  List<int> checkings = [];
  String nowyearmonth =
  (DateTime.now().year.toString() + DateTime.now().month.toString());
  Map<String,List<ProjectData>> daysMap = {};
  List<ProjectData> todaydata;

  getdakatime() async {

    //获取当前月份有多少天
    var dayCount = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    //生产当前月份天数得数组
    for (int j = 0; j < dayCount; j++) {
      checkings.add(0);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // print(nowyearmonth);
    //本地缓存中有当前月得打卡记录进入
    if (prefs.getStringList(nowyearmonth) != null) {
      List<String> localdakadatas = prefs.getStringList(nowyearmonth);
      //建立一个空的数组
      List<ProjectData> projectDataList = [];

      //遍历数组把数据塞到数组中
      for (int i = 0; i < localdakadatas.length; i++) {
        ProjectData dakadatas =
        ProjectData.fromJson(json.decode(localdakadatas[i]));
        projectDataList.add(dakadatas);
      }

      //遍历数组把数据塞到map里
      for(var item in projectDataList){
        //判断map的key中是否含有打卡记录那一天
        if(daysMap.keys.contains(item.day)){
          //map的key有打卡记录中的那一天时,增加value的数据到对应的key中
          List<ProjectData> days =  daysMap[item.day];
          days.add(item);
        }else{
          //map的key没有打卡记录中的那一天时,增加key为数据中的day value为数据
          List<ProjectData> days =[];
          days.add(item);
          daysMap[item.day] = days;
        }
      }

      //遍历map,判断map的value的长度是否跟打卡项目相等,==渲染为绿色 !=渲染为橙色
      //var item in daysMap.entries 获取到map中的key value项
      for(var item in daysMap.entries){
        setState(() {
          if(item.value.length == prefs.getStringList('1').length){
            checkings[int.parse(item.key)-1]=1;
          }else{
            checkings[int.parse(item.key)-1]=2;
          }
          //把当前天的数据塞入到todaydat 进行渲染
          todaydata = daysMap[DateTime.now().day.toString()];
        });
      }

    } else {
      print('没有本地数据');
    }

  }

  @override
  void initState() {
    super.initState();
    getdakatime();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0xFFeef2f3),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.white,
                ),
                child: CustomCalendar.CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2021),
                  lastDate: DateTime(2030),
                  onDateChanged: (DateTime value) {
                    setState(() {
                      todaydata =  daysMap[value.day.toString()];
                    });
                  },
                  onDisplayedMonthChanged:(DateTime value) {
                    // getdakatime();
                    print(
                        '${value.year}' + '${value.month}' + '${value.day}');
                  },
                  checking: checkings,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              todaydata != null
                  ? Container(
                      padding: EdgeInsets.only(top: 15, bottom: 15, left: 15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: todaydata.length,
                              itemExtent: 65,
                              itemBuilder: (BuildContext context, int index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: SvgPicture.asset(
                                          'assets/${todaydata[index].svgurl}.svg'),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${todaydata[index].projectname}',
                                            style: TextStyle(fontSize: 18)),
                                        //已打卡${dakadatas.time.substring(11, 16)}
                                        Text('已打卡',
                                            style: TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                );
                              })
                        ],
                      ),
                    )
                  : Container(
              ),
            ],
          ),
        ),
      ),
    ));
  }
}