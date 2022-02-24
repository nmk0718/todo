import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChoiceTimeItem.dart';
import 'ProjectData.dart';
import 'PunchInButton.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  ProjectData timeframe;
  String starthour = '00';
  String startmin = '00';
  String endhour = '23';
  String endmin = '59';
  List hours = [
    '00',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23'
  ];
  List mins = [
    '00',
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '50',
    '51',
    '52',
    '53',
    '54',
    '55',
    '56',
    '57',
    '58',
    '59'
  ];
  List svglist = [
    'morning',
    'noon',
    'night',
    'rice',
    'bodybuilding',
    'professionalskills',
    'smile',
    'financing',
    'diary',
    'moive',
    'water',
    'sleep',
    'photography',
    'painting'
  ];
  List defaulttext = [
    '早晨',
    '中午',
    '夜晚',
    '吃饭',
    '健身',
    '技能学习',
    '微笑',
    '存钱',
    '日记',
    '电影',
    '喝水',
    '睡觉',
    '摄影',
    '绘画'
  ];
  List svgselected = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  int selectedindex;

  String input_text;
  String nowyearmonth =
      (DateTime.now().year.toString() + DateTime.now().month.toString());

  Future<void> getdatetime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int nowhourmin = int.parse(DateTime.now().hour.toString() +
        DateTime.now().toString().substring(14, 16));

    if (prefs.getStringList(nowyearmonth) != null) {
      //本地有当前月打卡记录时进入
      //获取当前是否有打卡数据. 如果有打卡数据 遍历打卡数据 判断当前时间是否在打卡数据的时间内,如果在打卡时间则显示已经打卡.
      List<String> localdakadatas = prefs.getStringList(nowyearmonth);
      for (int i = 0; i < localdakadatas.length; i++) {
        ProjectData dakadatas =
            ProjectData.fromJson(json.decode(localdakadatas[i]));
        if (dakadatas.dakatime.substring(8, 10) ==
                DateTime.now().day.toString() &&
            int.parse(dakadatas.starttime) <= nowhourmin &&
            nowhourmin <= int.parse(dakadatas.endtime)) {
          setState(() {
            timeframe = dakadatas;
          });
        } else {
          List<String> localdakadatas = prefs.getStringList('1');
          for (int i = 0; i < localdakadatas.length; i++) {
            ProjectData dakadatas =
                ProjectData.fromJson(json.decode(localdakadatas[i]));

            if (int.parse(dakadatas.starttime) <= nowhourmin &&
                nowhourmin <= int.parse(dakadatas.endtime)) {
              setState(() {
                timeframe = dakadatas;
              });
            }
            ;
          }
        }
      }
    } else {
      //本地没有当前月打卡记录时进入
      //获取当前是否有打卡项. 如果有打卡项目 遍历打卡项 判断当前时间是否在打卡项的时间内,如果在打卡时间则显示打卡项目.
      if (prefs.getStringList('1') != null) {
        List<String> localdakadatas = prefs.getStringList('1');
        for (int i = 0; i < localdakadatas.length; i++) {
          ProjectData dakadatas =
              ProjectData.fromJson(json.decode(localdakadatas[i]));

          if (int.parse(dakadatas.starttime) <= nowhourmin &&
              nowhourmin <= int.parse(dakadatas.endtime)) {
            setState(() {
              timeframe = dakadatas;
            });
          }
          ;
        }
      }
    }
  }

  Widget PunchInWidget() {
    if (timeframe != null) {
      return FlipCard(
        flipOnTouch: timeframe.status == true ? false : true,
        direction: FlipDirection.HORIZONTAL,
        onFlipDone: (status) async {
          if (status = true) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            List<String> dakalist = [];
            if (prefs.getStringList(nowyearmonth) != null) {
              dakalist = prefs.getStringList(nowyearmonth);
            } else {
              dakalist = [];
            }
            String time = DateTime.now().toString().substring(0, 19);
            dakalist.add(JsonEncoder().convert({
              "projectname": timeframe.projectname,
              "svgurl": timeframe.svgurl,
              "starttime": timeframe.starttime,
              "endtime": timeframe.endtime,
              "status": true,
              "dakatime": time
            }).toString());
            prefs.setStringList(nowyearmonth, dakalist);
          }
        },
        front: PunchInButton(
          buttonsvg: SvgPicture.asset(
            'assets/${timeframe.svgurl}.svg',
          ),
          tabtext: '${timeframe.projectname}',
          punchintext: timeframe.status == true
              ? '已打卡'
              : '${timeframe.starttime.toString().substring(0, 2)}:${timeframe.starttime.toString().substring(2, 4)}-${timeframe.endtime.toString().substring(0, 2)}:${timeframe.endtime.toString().substring(2, 4)}',
          color: timeframe.status == true ? null : Colors.white,
          linearGradient: timeframe.status == true
              ? LinearGradient(colors: [Color(0xFFFFCC80), Colors.orangeAccent])
              : null,
        ),
        back: PunchInButton(
          buttonsvg: SvgPicture.asset(
            'assets/${timeframe.svgurl}.svg',
          ),
          tabtext: '${timeframe.projectname}',
          punchintext: '已打卡',
          linearGradient: LinearGradient(
            colors: [Color(0xFFFFCC80), Colors.orangeAccent],
          ),
        ),
      );
    } else {
      return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Color(0xffd6d6d6),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3.0)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.cancel,
                size: 100,
                color: Colors.white,
              ),
              Text(
                '无法打卡',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ));
    }
  }

  @override
  initState() {
    super.initState();
    getdatetime();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFeef2f3),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          '打卡',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () {
                //新建打卡弹出框
                showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (BuildContext context,
                          void Function(void Function()) setState) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          title: Text('新建打卡'),
                          content: Container(
                            height: 170,
                            width: 200,
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: 60,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: svglist.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Stack(
                                          children: [
                                            GestureDetector(
                                              child: Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    child: SvgPicture.asset(
                                                        'assets/${svglist[index]}.svg'),
                                                  )),
                                              onTap: () {
                                                setState(() {
                                                  svgselected.remove(true);
                                                  svgselected.add(false);
                                                  svgselected[index] = true;
                                                  print(
                                                      '当前选中的图标为${svglist[index]}');
                                                  selectedindex = index;
                                                  input_text =
                                                      defaulttext[index];
                                                });
                                              },
                                            ),
                                            Positioned(
                                              child: svgselected[index] == true
                                                  ? Container(
                                                      child: Icon(
                                                        Icons.done,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .lightGreenAccent,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    7.0)),
                                                      ),
                                                    )
                                                  : Container(),
                                              right: 0,
                                              bottom: 0,
                                            )
                                          ],
                                        );
                                      }),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 40,
                                  ),
                                  child: TextField(
                                    onChanged: (text) {
                                      //输入框内容变化回调
                                      // setState(() {
                                      input_text = text;
                                      // });
                                    },
                                    controller:
                                        TextEditingController(text: input_text),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 15),
                                      fillColor: Colors.blueGrey[50],
                                      hintText: "请输入打卡项",
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        /*边角*/
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10), //边角为5
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.white, //边线颜色为白色
                                          width: 1, //边线宽度为2
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white, //边框颜色为白色
                                          width: 1, //宽度为5
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10), //边角为30
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('打卡时间'),
                                    GestureDetector(
                                      child: Text(starthour +
                                          ':' +
                                          startmin +
                                          '-' +
                                          endhour +
                                          ':' +
                                          endmin),
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            builder: (BuildContext context) {
                                              return Container(
                                                  height: 250,
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          FlatButton(
                                                              onPressed: () {
                                                                print(
                                                                    '取消了时间选择');
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                '取消',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .grey),
                                                              )),
                                                          Text(
                                                            '打卡时间',
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                          FlatButton(
                                                              onPressed:
                                                                  () async {
                                                                if (int.parse(
                                                                        starthour) >
                                                                    int.parse(
                                                                        endhour)) {
                                                                  print(
                                                                      '开始时间不能大于结束时间');
                                                                } else {
                                                                  setState(() {
                                                                    print('$starthour'
                                                                            '点' +
                                                                        '$startmin'
                                                                            '分' +
                                                                        '$endhour'
                                                                            '点' +
                                                                        '$endmin'
                                                                            '分');
                                                                  });
                                                                }
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                '确定',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .blueAccent),
                                                              )),
                                                        ],
                                                      ),
                                                      Expanded(
                                                          child: Stack(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 80,
                                                                    left: 20,
                                                                    right: 20),
                                                            child: Container(
                                                              width: 420,
                                                              height: 45,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10.0)),
                                                                color: Colors
                                                                    .blueGrey[50],
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                ChoiceTimeItem(
                                                                  date: hours,
                                                                  initialItem:
                                                                      0,
                                                                  TimeUnit: '点',
                                                                  onSelectedItemChanged:
                                                                      (index) {
                                                                    if (index <
                                                                        10) {
                                                                      starthour =
                                                                          '0' +
                                                                              index.toString();
                                                                    } else {
                                                                      starthour =
                                                                          index
                                                                              .toString();
                                                                    }
                                                                  },
                                                                ),
                                                                ChoiceTimeItem(
                                                                  date: mins,
                                                                  initialItem:
                                                                      0,
                                                                  TimeUnit: '分',
                                                                  onSelectedItemChanged:
                                                                      (index) {
                                                                    if (index <
                                                                        10) {
                                                                      startmin =
                                                                          '0' +
                                                                              index.toString();
                                                                    } else {
                                                                      startmin =
                                                                          index
                                                                              .toString();
                                                                    }
                                                                  },
                                                                ),
                                                                Container(
                                                                    width: 10,
                                                                    child:
                                                                        Container(
                                                                      child: Text(
                                                                          '至'),
                                                                    )),
                                                                ChoiceTimeItem(
                                                                  date: hours,
                                                                  initialItem:
                                                                      23,
                                                                  TimeUnit: '点',
                                                                  onSelectedItemChanged:
                                                                      (index) {
                                                                    if (index <
                                                                        10) {
                                                                      endhour =
                                                                          '0' +
                                                                              index.toString();
                                                                    } else {
                                                                      endhour =
                                                                          index
                                                                              .toString();
                                                                    }
                                                                  },
                                                                ),
                                                                ChoiceTimeItem(
                                                                  date: mins,
                                                                  initialItem:
                                                                      59,
                                                                  TimeUnit: '分',
                                                                  onSelectedItemChanged:
                                                                      (index) {
                                                                    if (index <
                                                                        10) {
                                                                      endmin = '0' +
                                                                          index
                                                                              .toString();
                                                                    } else {
                                                                      endmin = index
                                                                          .toString();
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ))
                                                    ],
                                                  ));
                                            });
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          actions: [
                            FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('取消')),
                            FlatButton(
                                onPressed: () async {
                                  if (input_text.isNotEmpty &&
                                      svgselected.contains(true) == true) {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();

                                    if (prefs.getStringList('1') != null) {
                                      //判断当前选中的时间是否再打卡项目的时间内,如果不在则创建新的打卡项目,在则提示当前时间与其他打卡项目冲突
                                      List<String> projectdata =
                                          prefs.getStringList('1');
                                      projectdata.add(JsonEncoder().convert({
                                        "projectname": "${input_text}",
                                        "svgurl": "${svglist[selectedindex]}",
                                        "starttime": starthour + startmin,
                                        "endtime": endhour + endmin,
                                      }).toString());
                                      prefs.setStringList('1', projectdata);
                                    } else {
                                      List<String> projectdata = [
                                        JsonEncoder().convert({
                                          "projectname": "${input_text}",
                                          "svgurl": "${svglist[selectedindex]}",
                                          "starttime": starthour + startmin,
                                          "endtime": endhour + endmin,
                                        }).toString()
                                      ];
                                      prefs.setStringList('1', projectdata);
                                    }
                                    Navigator.pop(context);
                                    // getdatetime();
                                  } else {
                                    print(input_text);
                                  }
                                },
                                child: Text('确定')),
                          ],
                        );
                      });
                    });
              },
              icon: Icon(
                Icons.add,
                color: Colors.black,
                size: 30,
              ))
        ],
      ),
      body: Center(
        child: Container(
          height: 300,
          width: 200,
          child: PunchInWidget(),
        ),
      ),
    );
  }
}
