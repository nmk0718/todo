import 'package:flutter/material.dart';

class ChoiceTimeItem extends StatelessWidget {
  List date;
  int initialItem;
  String TimeUnit;
  Function onSelectedItemChanged;
  ChoiceTimeItem({this.date,this.initialItem,this.TimeUnit,this.onSelectedItemChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      child:
      ListWheelScrollView(
        controller:
        FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 40,
        physics:
        FixedExtentScrollPhysics(
          parent:
          BouncingScrollPhysics(),
        ),
        useMagnifier:
        true,
        magnification:
        1.5,
        children: date
            .map(
                (item) {
              return Container(
                height: 60,
                alignment:
                Alignment
                    .center,
                child: Text(
                  item +
                      TimeUnit,
                  // style: TextStyleConstant().normal_2_20,//自定义style
                ),
              );
            }).toList(),
        onSelectedItemChanged:onSelectedItemChanged,
      ),
    );
  }
}