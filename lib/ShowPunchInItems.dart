import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'ProjectData.dart';

class ShowpPunchInItems extends StatelessWidget {
  List<ProjectData> datas;
  String showtimetype;

  ShowpPunchInItems({this.datas, this.showtimetype});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 3)],
      ),
      child: Column(
        children: [
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: datas.length,
              itemExtent: 71,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: SvgPicture.asset(
                                'assets/${datas[index].svgurl}.svg'),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Text('${datas[index].projectname}',
                                style: TextStyle(fontSize: 18)),
                          ),
                          Text(
                            showtimetype == '打卡时间'
                                ? datas[index].dakatime.substring(11, 16)
                                : datas[index].starttime.substring(0, 2) +
                                    ':' +
                                    datas[index].starttime.substring(2, 4) +
                                    '~' +
                                    datas[index].endtime.substring(0, 2) +
                                    ':' +
                                    datas[index].endtime.substring(2, 4),
                          ),
                        ],
                      ),
                    ),
                    index == datas.length - 1
                        ? Container()
                        : Container(
                            height: 1,
                            color: Colors.grey[200],
                          )
                  ],
                );
              })
        ],
      ),
    );
  }
}
