import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class DatePickerDropdown extends StatefulWidget {
  final void Function(DateTime)? onDateSelected; // Add this

  const DatePickerDropdown({Key? key, this.onDateSelected}) : super(key: key);

  @override
  State<DatePickerDropdown> createState() => _DatePickerDropdownState();
}

class _DatePickerDropdownState extends State<DatePickerDropdown> {
  DateTime? selectedDate;

  String get _buttonText {
    final date = selectedDate ?? DateTime.now();
    return DateFormat.yMMMMd().format(date);
  }

  void _showDatePicker() async {
    DateTime tempDate = selectedDate ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: 20,
                  right: 20,
                  top: 24,
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Select Date',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: tempDate,
                          maximumDate: DateTime.now(),
                          onDateTimeChanged: (value) {
                            tempDate = value;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6246EA),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          minimumSize: Size(double.infinity, 48),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedDate = tempDate;
                          });
                          if (widget.onDateSelected != null) {
                            widget.onDateSelected!(tempDate);
                          }
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: _showDatePicker,
child: Container(
  width: 360,
  height: 40, // <-- Forces the height
  padding: EdgeInsets.symmetric(horizontal: 16), // Only horizontal padding now
  decoration: BoxDecoration(
    color: Color(0xFFF3F3F3),
    borderRadius: BorderRadius.circular(32),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
    children: [
      Icon(Icons.calendar_today_outlined, color: Color(0xFF6246EA), size: 20),
      SizedBox(width: 10),
      Text(
        _buttonText,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      Spacer(),
      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54, size: 22),
    ],
  ),
),
      ),
    );
  }
}
