import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProjectData.dart';
import 'ShowPunchInItems.dart';

class PunchInItem extends StatefulWidget {
  PunchInItemState createState() => PunchInItemState();
}

class PunchInItemState extends State<PunchInItem> {
  List<ProjectData> punchinitem = [];

  Future<void> GetPunchInItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('1') != null) {
      List<String> localdakadatas = prefs.getStringList('1');

      for (int i = 0; i < localdakadatas.length; i++) {
        ProjectData dakadatas =
            ProjectData.fromJson(json.decode(localdakadatas[i]));
        setState(() {
          punchinitem.add(dakadatas);
        });
      }
    }
  }

  @override
  initState() {
    super.initState();
    GetPunchInItem();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(children: [
          ShowpPunchInItems(datas:punchinitem,showtimetype:'打卡范围',),
        ]),
      ),
    ));
  }
}
