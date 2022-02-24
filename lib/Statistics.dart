import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/ProjectData.dart';
import 'package:todo/ShowPunchInItems.dart';
import 'calendar.dart' as CustomCalendar;

class Statistics extends StatefulWidget {
  StatisticsState createState() => StatisticsState();
}

class StatisticsState extends State<Statistics> {

  List<int> checkings = [];
  Map<String,List<ProjectData>> daysMap = {};
  List<ProjectData> todaydata;

  getdakatime(int year,int month) async {

    //获取当前月份有多少天
    var dayCount = DateTime(year, month + 1, 0).day;
    //当前日历所在的年月
    String nowyearmonth = year.toString()+month.toString();
    //生产当前月份天数得数组
    for (int j = 0; j < dayCount; j++) {
      checkings.add(0);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

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
        if(daysMap.keys.contains(item.dakatime.substring(8, 10))){
          //map的key有打卡记录中的那一天时,增加value的数据到对应的key中
          List<ProjectData> days =  daysMap[item.dakatime.substring(8, 10)];
          days.add(item);
        }else{
          //map的key没有打卡记录中的那一天时,增加key为数据中的day value为数据
          List<ProjectData> days =[];
          days.add(item);
          daysMap[item.dakatime.substring(8, 10)] = days;
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
    getdakatime(DateTime.now().year,DateTime.now().month);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
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
                  boxShadow: [
                    BoxShadow(color: Colors.grey[300], blurRadius: 3)
                  ],
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
                    //清除dayMap中存储的当月数据
                    daysMap.clear();
                    //清楚checkings中存储的当月打卡状态
                    checkings.clear();
                    //重新获取改变的月份的数据和状态
                    getdakatime(value.year,value.month);
                  },
                  checking: checkings,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              todaydata != null
                  ? ShowpPunchInItems(datas:todaydata,showtimetype:'打卡时间',)
                  : Container(
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
