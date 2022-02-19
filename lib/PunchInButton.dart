import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PunchInButton extends StatelessWidget {
  Widget buttonsvg;
  String tabtext;
  String punchintext;
  LinearGradient linearGradient;
  Color color;
  PunchInButton({this.buttonsvg,this.tabtext,this.punchintext,this.linearGradient,this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        gradient: linearGradient,
        color: color,
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 3.0)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height:100,
            width: 100,
            child: buttonsvg
          ),
          Text(
              tabtext,
            style: TextStyle(fontSize: 16),
          ),
          // Text('07:00-09:00')
          Text(
            punchintext,
            style: TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }
}