import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProjectData.dart';

class PunchInItem extends StatefulWidget {
  PunchInItemState createState() => PunchInItemState();
}

class PunchInItemState extends State<PunchInItem> {
  List<ProjectData> punchinitem = [];
  int itemlength = 0;

  Future<void> GetPunchInItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('1') != null) {
      List<String> localdakadatas = prefs.getStringList('1');

      for (int i = 0; i < localdakadatas.length; i++) {
        ProjectData dakadatas =
            ProjectData.fromJson(json.decode(localdakadatas[i]));
        setState(() {
          punchinitem.add(dakadatas);
          itemlength = localdakadatas.length;
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 3)],
            ),
            child:ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: itemlength,
                itemExtent: 75,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 15,right: 15,top:10,bottom: 10),child: Row(
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: SvgPicture.asset(
                                'assets/${punchinitem[index].svgurl}.svg'),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text('${punchinitem[index].projectname}',
                                style: TextStyle(fontSize: 18)),
                          ),
                          Text('${punchinitem[index].starthour}' +
                              ':' +
                              '${punchinitem[index].startmin}' +
                              '~' +
                              '${punchinitem[index].endhour}' +
                              ':' +
                              '${punchinitem[index].endmin}'),
                        ],
                      ),),
                      index == itemlength-1?Container() :Container(height: 1,color: Colors.grey[200],)
                    ],
                  );
                }),),
        ]),
      ),
    ));
  }
}
