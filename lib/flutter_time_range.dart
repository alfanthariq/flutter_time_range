library flutter_time_range;

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

typedef onSelectCallback = void Function(TimeOfDay from, TimeOfDay to);
typedef onCancelCallback = void Function();

class TimeRangePicker extends StatefulWidget {
  final int? initialFromHour,
      initialToHour,
      initialFromMinutes,
      initialToMinutes;
  final onSelectCallback? onSelect;
  final onCancelCallback? onCancel;
  final String tabFromText,
      tabToText,
      cancelText,
      nextText,
      backText,
      selectText;
  final TextStyle selectedTimeStyle, unselectedTimeStyle;
  final BorderRadiusGeometry? boxRadius;
  final BoxBorder? boxBorder;

  TimeRangePicker(
      {Key? key,
      @required this.initialFromHour,
      @required this.initialToHour,
      @required this.initialFromMinutes,
      @required this.initialToMinutes,
      this.onSelect,
      this.onCancel,
      this.tabFromText = "From",
      this.tabToText = "To",
      this.cancelText = "Cancel",
      this.nextText = "Next",
      this.backText = "Back",
      this.selectText = "Select",
      this.selectedTimeStyle =
          const TextStyle(color: Colors.blueAccent, fontSize: 30),
      this.unselectedTimeStyle =
          const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
      this.boxRadius,
      this.boxBorder})
      : super(key: key);

  @override
  _TimeRangePickerState createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _jamFrom = 0;
  int _menitFrom = 0;
  int _jamTo = 0;
  int _menitTo = 0;
  int _selectedTab = 0;
  BorderRadiusGeometry defaultRadius = BorderRadius.circular(7);
  BoxBorder defaultBorder = Border.all(color: Colors.grey[500]!);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    _jamFrom = widget.initialFromHour!;
    _jamTo = widget.initialToHour!;
    _menitFrom = widget.initialFromMinutes!;
    _menitTo = widget.initialToMinutes!;
  }

  @override
  Widget build(BuildContext context) {
    return buildContainer();
  }

  Widget buildContainer() {
    return Container(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  child: Text(
                widget.tabFromText,
                style: TextStyle(color: Colors.blueAccent),
              )),
              Tab(
                  child: Text(widget.tabToText,
                      style: TextStyle(color: Colors.blueAccent)))
            ],
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(10),
            child: TabBarView(
              controller: _tabController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: widget.boxRadius == null
                              ? defaultRadius
                              : widget.boxRadius,
                          border: widget.boxBorder == null
                              ? defaultBorder
                              : widget.boxBorder),
                      child: NumberPicker(
                          minValue: 0,
                          maxValue: 23,
                          value: _jamFrom,
                          zeroPad: true,
                          textStyle: widget.unselectedTimeStyle,
                          selectedTextStyle: widget.selectedTimeStyle,
                          infiniteLoop: true,
                          onChanged: (value) {
                            setState(() {
                              _jamFrom = value;
                            });
                          }),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          ":",
                          style: TextStyle(fontSize: 30),
                        )),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: widget.boxRadius == null
                              ? defaultRadius
                              : widget.boxRadius,
                          border: widget.boxBorder == null
                              ? defaultBorder
                              : widget.boxBorder),
                      child: NumberPicker(
                          minValue: 0,
                          maxValue: 59,
                          value: _menitFrom,
                          zeroPad: true,
                          textStyle: widget.unselectedTimeStyle,
                          selectedTextStyle: widget.selectedTimeStyle,
                          infiniteLoop: true,
                          onChanged: (value) {
                            setState(() {
                              _menitFrom = value;
                            });
                          }),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: Colors.grey[500]!)),
                      child: NumberPicker(
                          minValue: 0,
                          maxValue: 23,
                          value: _jamTo,
                          zeroPad: true,
                          textStyle: widget.unselectedTimeStyle,
                          selectedTextStyle: widget.selectedTimeStyle,
                          infiniteLoop: true,
                          onChanged: (value) {
                            setState(() {
                              _jamTo = value;
                            });
                          }),
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(":", style: TextStyle(fontSize: 30))),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: Colors.grey[500]!)),
                      child: NumberPicker(
                          minValue: 0,
                          maxValue: 59,
                          value: _menitTo,
                          zeroPad: true,
                          textStyle: widget.unselectedTimeStyle,
                          selectedTextStyle: widget.selectedTimeStyle,
                          infiniteLoop: true,
                          onChanged: (value) {
                            setState(() {
                              _menitTo = value;
                            });
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextButton(
                    onPressed: () {
                      if (_selectedTab == 1) {
                        _tabController.animateTo(0);
                      } else {
                        if (widget.onCancel != null) {
                          widget.onCancel!();
                        }
                      }
                    },
                    child: Text(_selectedTab == 0
                        ? widget.cancelText
                        : widget.backText)),
                TextButton(
                    onPressed: () {
                      if (_selectedTab == 0) {
                        _tabController.animateTo(1);
                      } else {
                        if (widget.onSelect != null) {
                          widget.onSelect!(
                              TimeOfDay(hour: _jamFrom, minute: _menitFrom),
                              TimeOfDay(hour: _jamTo, minute: _menitTo));
                        }
                      }
                    },
                    child: Text(_selectedTab == 0
                        ? widget.nextText
                        : widget.selectText))
              ],
            ),
          )
        ],
      ),
    );
  }
}
