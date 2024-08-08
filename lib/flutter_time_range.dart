library flutter_time_range;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:toggle_switch/toggle_switch.dart';

typedef onSelectCallback = void Function(TimeOfDay from, TimeOfDay to);
typedef onCancelCallback = void Function();

class TimeRangePicker extends StatefulWidget {
  /// Initial value for first hour
  final int? initialFromHour;

  /// Initial value for second hour
  final int? initialToHour;

  /// Initial value for first minutes
  final int? initialFromMinutes;

  /// Initial value for second minutes
  final int? initialToMinutes;

  /// Callback which called when select button clicked / tapped
  final onSelectCallback? onSelect;

  /// Callback which called when cancel button clicked / tapped
  final onCancelCallback? onCancel;

  /// Caption for first tab
  /// default was "From"
  final String tabFromText;

  /// Caption for second tab
  /// default was "To"
  final String tabToText;

  /// Cancel button caption
  /// default was "Cancel"
  final String cancelText;

  /// Next button caption
  /// default was "Next"
  final String nextText;

  /// Back button caption
  /// default was "Back"
  final String backText;

  /// Select button caption
  /// default was select
  final String selectText;

  /// TextStyle for selected time
  final TextStyle selectedTimeStyle;

  /// TextStyle for nselected time
  final TextStyle unselectedTimeStyle;

  /// Style decoration for time container
  final BoxDecoration? timeContainerStyle;

  /// If true, user can change value of time manually with textfield
  final bool editable;

  /// If true, user choose invalid time

  /// If false, AM-PM toggle will show.
  /// initial time is normal DateTime and will convert into 12 hours format.
  /// output time is normal TimeOfDay
  final bool is24Format;

  /// Background color for active AM-PM toggle
  /// default was blue accent
  final Color activeBgColor;

  /// Background color for inactive AM-PM toggle
  /// default was grey
  final Color inactiveBgColor;

  /// Foreground color for active AM-PM toggle
  /// default was white
  final Color activeFgColor;

  /// Foreground color for inactive AM-PM toggle
  /// default was white
  final Color inactiveFgColor;

  /// Icon for cancel button
  final Icon? iconCancel;

  /// Icon for next button
  final Icon? iconNext;

  /// Icon for back button
  final Icon? iconBack;

  /// Icon for select button
  final Icon? iconSelect;

  /// If true, tab interaction e.g click and slide on tab will be disable
  /// default was true
  final bool disableTabInteraction;

  /// TextStyle of separator ":" in middle between hour and minutes
  final TextStyle separatorStyle;

  /// TextStyle of active tab bar
  final TextStyle activeTabStyle;

  /// TextStyle of inactive tab bar
  final TextStyle inactiveTabStyle;

  /// Color of active tab label
  final Color activeLabelColor;

  /// Color of inactive tab label
  final Color inactiveLabelColor;

  /// Color of indicator active tab
  final Color indicatorColor;

  TimeRangePicker(
      {Key? key,
      required this.initialFromHour,
      required this.initialToHour,
      required this.initialFromMinutes,
      required this.initialToMinutes,
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
      this.timeContainerStyle,
      this.editable = true,
      this.is24Format = true,
      this.activeBgColor = Colors.blueAccent,
      this.activeFgColor = Colors.white,
      this.inactiveBgColor = Colors.grey,
      this.inactiveFgColor = Colors.white,
      this.iconBack,
      this.iconNext,
      this.iconCancel,
      this.iconSelect,
      this.disableTabInteraction = true,
      this.separatorStyle = const TextStyle(color: Colors.black, fontSize: 30),
      this.activeTabStyle =
          const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      this.inactiveTabStyle =
          const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      this.activeLabelColor = Colors.blueAccent,
      this.inactiveLabelColor = Colors.grey,
      this.indicatorColor = Colors.blueAccent})
      : super(key: key);

  @override
  _TimeRangePickerState createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker>
    with SingleTickerProviderStateMixin {
  bool isInvalidTime = false;

  late TabController _tabController;
  int _jamFrom = 0;
  int _menitFrom = 0;
  int _jamTo = 0;
  int _menitTo = 0;
  int _selectedTab = 0;
  int _maxJamValue = 23;
  int _minJamValue = 0;
  BoxDecoration defaultDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: Colors.grey[500]!));
  var isEdit = List<bool>.empty(growable: true);
  var textControllers = List<TextEditingController>.empty(growable: true);
  var textFocus = List<FocusNode>.empty(growable: true);
  var fromIndex = 0;
  var toIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    _jamFrom = widget.is24Format
        ? widget.initialFromHour!
        : widget.initialFromHour! > 12
            ? (widget.initialFromHour! - 12)
            : widget.initialFromHour!;

    _jamTo = widget.is24Format
        ? widget.initialToHour!
        : widget.initialToHour! > 12
            ? (widget.initialToHour! - 12)
            : widget.initialToHour!;

    _menitFrom = widget.initialFromMinutes!;
    _menitTo = widget.initialToMinutes!;

    if (!widget.is24Format) {
      _maxJamValue = 12;
      _minJamValue = 1;
      if (widget.initialFromHour! > 12) {
        fromIndex = 1;
      }
      if (widget.initialToHour! > 12) {
        toIndex = 1;
      }
    }

    for (int i = 0; i < 4; i++) {
      isEdit.add(false);
      textControllers.add(TextEditingController());
      textFocus.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < 4; i++) {
      textControllers[i].dispose();
      textFocus[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildContainer();
  }

  Widget buildContainer() {
    return Container(
      width: double.maxFinite,
      height: 330,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.disableTabInteraction
              ? IgnorePointer(
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: widget.activeTabStyle,
                    labelColor: widget.activeLabelColor,
                    indicatorColor: widget.indicatorColor,
                    unselectedLabelColor: widget.inactiveLabelColor,
                    unselectedLabelStyle: widget.inactiveTabStyle,
                    tabs: [
                      Tab(text: widget.tabFromText),
                      Tab(text: widget.tabToText)
                    ],
                  ),
                )
              : TabBar(
                  controller: _tabController,
                  labelStyle: widget.activeTabStyle,
                  unselectedLabelStyle: widget.inactiveTabStyle,
                  indicatorColor: widget.indicatorColor,
                  labelColor: widget.activeLabelColor,
                  unselectedLabelColor: widget.inactiveLabelColor,
                  tabs: [
                    Tab(text: widget.tabFromText),
                    Tab(text: widget.tabToText)
                  ],
                ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 20),
              child: TabBarView(
                physics: widget.disableTabInteraction
                    ? NeverScrollableScrollPhysics()
                    : null,
                controller: _tabController,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 7, right: 7),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.is24Format
                              ? Container(
                                  height: 30,
                                )
                              : Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: ToggleSwitch(
                                    minWidth: 90.0,
                                    minHeight: 30,
                                    cornerRadius: 20.0,
                                    activeBgColor: [widget.activeBgColor],
                                    activeFgColor: widget.activeFgColor,
                                    inactiveBgColor: widget.inactiveBgColor,
                                    inactiveFgColor: widget.inactiveFgColor,
                                    labels: ['AM', 'PM'],
                                    initialLabelIndex: fromIndex,
                                    onToggle: (index) {
                                      fromIndex = index ?? 0;
                                    },
                                  ),
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: widget.timeContainerStyle ??
                                      defaultDecoration,
                                  child: isEdit[0]
                                      ? TextField(
                                          controller: textControllers[0],
                                          focusNode: textFocus[0],
                                          textAlign: TextAlign.center,
                                          style: widget.selectedTimeStyle,
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                          onSubmitted: (value) {
                                            setState(() {
                                              if (value.isNotEmpty) {
                                                if (int.parse(value) >
                                                    _maxJamValue) {
                                                  _jamFrom = _maxJamValue;
                                                } else {
                                                  _jamFrom = int.parse(value);
                                                }
                                              }

                                              isEdit[0] = false;
                                            });
                                          },
                                        )
                                      : InkWell(
                                          onTap: () {
                                            if (widget.editable) {
                                              setState(() {
                                                isEdit[0] = true;
                                                textFocus[0].requestFocus();
                                              });
                                            }
                                          },
                                          child: NumberPicker(
                                              minValue: _minJamValue,
                                              maxValue: _maxJamValue,
                                              value: _jamFrom,
                                              zeroPad: true,
                                              textStyle:
                                                  widget.unselectedTimeStyle,
                                              selectedTextStyle:
                                                  widget.selectedTimeStyle,
                                              infiniteLoop: true,
                                              onChanged: (value) {
                                                setState(() {
                                                  _jamFrom = value;
                                                });
                                              }),
                                        ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child:
                                      Text(":", style: widget.separatorStyle)),
                              Expanded(
                                child: Container(
                                  decoration: widget.timeContainerStyle ??
                                      defaultDecoration,
                                  child: isEdit[1]
                                      ? TextField(
                                          controller: textControllers[1],
                                          focusNode: textFocus[1],
                                          textAlign: TextAlign.center,
                                          style: widget.selectedTimeStyle,
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                          onSubmitted: (value) {
                                            setState(() {
                                              if (value.isNotEmpty) {
                                                if (int.parse(value) > 59) {
                                                  _menitFrom = 59;
                                                } else {
                                                  _menitFrom = int.parse(value);
                                                }
                                              }

                                              isEdit[1] = false;
                                            });
                                          },
                                        )
                                      : InkWell(
                                          onTap: () {
                                            if (widget.editable) {
                                              setState(() {
                                                isEdit[1] = true;
                                                textFocus[1].requestFocus();
                                              });
                                            }
                                          },
                                          child: NumberPicker(
                                              minValue: 0,
                                              maxValue: 59,
                                              value: _menitFrom,
                                              zeroPad: true,
                                              textStyle:
                                                  widget.unselectedTimeStyle,
                                              selectedTextStyle:
                                                  widget.selectedTimeStyle,
                                              infiniteLoop: true,
                                              onChanged: (value) {
                                                setState(() {
                                                  _menitFrom = value;
                                                });
                                              }),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          if (isInvalidTime)
                            Text(
                              'Invalid time values',
                              style: TextStyle(color: Colors.red),
                            )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 7, right: 7),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.is24Format
                              ? Container(
                                  height: 30,
                                )
                              : Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: ToggleSwitch(
                                    minWidth: 90.0,
                                    minHeight: 30,
                                    cornerRadius: 20.0,
                                    activeBgColor: [widget.activeBgColor],
                                    activeFgColor: widget.activeFgColor,
                                    inactiveBgColor: widget.inactiveBgColor,
                                    inactiveFgColor: widget.inactiveFgColor,
                                    labels: ['AM', 'PM'],
                                    initialLabelIndex: toIndex,
                                    onToggle: (index) {
                                      toIndex = index ?? 0;
                                    },
                                  ),
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: widget.timeContainerStyle ??
                                      defaultDecoration,
                                  child: isEdit[2]
                                      ? TextField(
                                          controller: textControllers[2],
                                          focusNode: textFocus[2],
                                          textAlign: TextAlign.center,
                                          style: widget.selectedTimeStyle,
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                          onSubmitted: (value) {
                                            setState(() {
                                              if (value.isNotEmpty) {
                                                if (int.parse(value) >
                                                    _maxJamValue) {
                                                  _jamTo = _maxJamValue;
                                                } else {
                                                  _jamTo = int.parse(value);
                                                }
                                              }

                                              isEdit[2] = false;
                                            });
                                          },
                                        )
                                      : InkWell(
                                          onTap: () {
                                            if (widget.editable) {
                                              setState(() {
                                                isEdit[2] = true;
                                                textFocus[2].requestFocus();
                                              });
                                            }
                                          },
                                          child: NumberPicker(
                                              minValue: _minJamValue,
                                              maxValue: _maxJamValue,
                                              value: _jamTo,
                                              zeroPad: true,
                                              textStyle:
                                                  widget.unselectedTimeStyle,
                                              selectedTextStyle:
                                                  widget.selectedTimeStyle,
                                              infiniteLoop: true,
                                              onChanged: (value) {
                                                setState(() {
                                                  _jamTo = value;
                                                });
                                              }),
                                        ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child:
                                      Text(":", style: widget.separatorStyle)),
                              Expanded(
                                child: Container(
                                  decoration: widget.timeContainerStyle ??
                                      defaultDecoration,
                                  child: isEdit[3]
                                      ? TextField(
                                          controller: textControllers[3],
                                          focusNode: textFocus[3],
                                          textAlign: TextAlign.center,
                                          style: widget.selectedTimeStyle,
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  signed: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                          onSubmitted: (value) {
                                            setState(() {
                                              if (value.isNotEmpty) {
                                                if (int.parse(value) > 59) {
                                                  _menitTo = 59;
                                                } else {
                                                  _menitTo = int.parse(value);
                                                }
                                              }

                                              isEdit[3] = false;
                                            });
                                          },
                                        )
                                      : InkWell(
                                          onTap: () {
                                            if (widget.editable) {
                                              setState(() {
                                                isEdit[3] = true;
                                                textFocus[3].requestFocus();
                                              });
                                            }
                                          },
                                          child: NumberPicker(
                                              minValue: 0,
                                              maxValue: 59,
                                              value: _menitTo,
                                              zeroPad: true,
                                              textStyle:
                                                  widget.unselectedTimeStyle,
                                              selectedTextStyle:
                                                  widget.selectedTimeStyle,
                                              infiniteLoop: true,
                                              onChanged: (value) {
                                                setState(() {
                                                  _menitTo = value;
                                                });
                                              }),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextButton(
                    onPressed: () {
                      if (_selectedTab == 1) {
                        _tabController.animateTo(0);
                      } else {
                        widget.onCancel?.call();
                      }
                    },
                    child: Row(
                      children: [
                        _selectedTab == 0
                            ? widget.iconCancel ?? Container()
                            : widget.iconBack ?? Container(),
                        Padding(padding: EdgeInsets.only(right: 5)),
                        Text(_selectedTab == 0
                            ? widget.cancelText
                            : widget.backText)
                      ],
                    )),
                TextButton(
                    onPressed: () {
                      if (_selectedTab == 0) {
                        _tabController.animateTo(1);
                      } else {
                        if (isEdit[0]) {
                          if (textControllers[0].text.isNotEmpty) {
                            if (int.parse(textControllers[0].text) >
                                _maxJamValue) {
                              _jamFrom = _maxJamValue;
                            } else {
                              _jamFrom = int.parse(textControllers[0].text);
                            }
                          }
                        }

                        if (isEdit[2]) {
                          if (textControllers[2].text.isNotEmpty) {
                            if (int.parse(textControllers[2].text) >
                                _maxJamValue) {
                              _jamTo = _maxJamValue;
                            } else {
                              _jamTo = int.parse(textControllers[2].text);
                            }
                          }
                        }

                        if (isEdit[1]) {
                          if (textControllers[1].text.isNotEmpty) {
                            if (int.parse(textControllers[1].text) > 59) {
                              _menitFrom = 59;
                            } else {
                              _menitFrom = int.parse(textControllers[1].text);
                            }
                          }
                        }

                        if (isEdit[3]) {
                          if (textControllers[3].text.isNotEmpty) {
                            if (int.parse(textControllers[3].text) > 59) {
                              _menitTo = 59;
                            } else {
                              _menitTo = int.parse(textControllers[3].text);
                            }
                          }
                        }

                        var jamFr = widget.is24Format
                            ? _jamFrom
                            : fromIndex == 1
                                ? (_jamFrom + 12)
                                : _jamFrom;

                        var jamTo = widget.is24Format
                            ? _jamTo
                            : toIndex == 1
                                ? (_jamTo + 12)
                                : _jamTo;
                        var from = TimeOfDay(hour: jamFr, minute: _menitFrom);
                        var to = TimeOfDay(hour: jamTo, minute: _menitTo);
                        if (to.hour < from.hour ||
                            (to.hour == from.hour && to.minute < from.minute)) {
                          print(isInvalidTime.toString());
                          setState(() {
                            isInvalidTime = true;
                          });
                          print(isInvalidTime.toString());
                        } else {
                          widget.onSelect?.call(from, to);
                        }
                      }
                    },
                    child: Row(
                      children: [
                        _selectedTab == 0
                            ? widget.iconNext ?? Container()
                            : widget.iconSelect ?? Container(),
                        Padding(padding: EdgeInsets.only(right: 5)),
                        Text(_selectedTab == 0
                            ? widget.nextText
                            : widget.selectText),
                      ],
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
