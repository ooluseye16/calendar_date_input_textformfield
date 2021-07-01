import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(child: CalendarDateInputField(),),
      ),
    );
  }
}

class CalendarDateInputField extends StatefulWidget {
  const CalendarDateInputField({Key? key}) : super(key: key);

  @override
  _CalendarDateInputFieldState createState() => _CalendarDateInputFieldState();
}

class _CalendarDateInputFieldState extends State<CalendarDateInputField> {
  DateTime? _selectedDay;
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  DateTime _focusedDay = DateTime.now();
  
  final TextEditingController? controller = TextEditingController();
  // TextEditingController _textController = TextEditingController();

  void showOverlay() {
    if (overlayEntry != null && overlayEntry!.mounted) {
      overlayEntry!.remove();
    } else
      overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: 0.0,
            left: 0.0,
            child: CompositedTransformFollower(
              showWhenUnlinked: false,
              offset: Offset(-10, -220),
              link: layerLink,
              child: Material(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.grey.shade100,
                    ),
                  ]),
                  width: 180.0,
                  child: TableCalendar(
                    rowHeight: 30.0,
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontSize: 12),
                      weekendStyle: TextStyle(fontSize: 12),
                    ),
                    headerStyle: HeaderStyle(
                      leftChevronPadding: EdgeInsets.all(2),
                      rightChevronPadding: EdgeInsets.all(2),
                      leftChevronMargin: EdgeInsets.all(2),
                      rightChevronMargin: EdgeInsets.all(2),
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(fontSize: 12.0),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(fontSize: 10),
                      weekendTextStyle: TextStyle(fontSize: 10),
                    ),
                    firstDay: DateTime.utc(2010, 10, 16),
                    calendarBuilders: CalendarBuilders(
                      selectedBuilder: (context, day, day2) => Center(
                        child: Container(
                          padding: EdgeInsets.all(3),
                          child: Text(
                            "${day.day}",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                        ),
                      ),
                      todayBuilder: (context, day, day2) => Center(
                        child: Container(
                          padding: EdgeInsets.all(3),
                          child: Text("${day.day}",
                              style: TextStyle(color: Colors.white)),
                          decoration: BoxDecoration(
                              color: Colors.grey, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                         controller!.text =
                              DateFormat("dd-MM-yyy").format(selectedDay);
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    Overlay.of(context)!.insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    String reArrange(String s) {
      if (s.length == 10) {
        String result;
        List<String> seperatedString;
        seperatedString = s.split('-');
        result = seperatedString.reversed.join("-");
        print(result);
        return result;
      } else {
        return s;
      }
    }

    return CompositedTransformTarget(
      link: layerLink,
      child: Container(
        height: 30,
        width: 200.0,
        child: TextFormField(
          keyboardType: TextInputType.number,
          onTap: () {
            showOverlay();
          },
          onEditingComplete: () {
            overlayEntry!.remove();

            FocusScope.of(context).unfocus();
          },
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 1),
            ),
          ),
          onChanged: (value) {
            if (value.length == 10) {
              String newValue = reArrange(value);
              setState(() {
                _selectedDay = DateTime.parse(newValue);
                _focusedDay = _selectedDay!;
              });
            }
          },
          onFieldSubmitted: (value) {
            print(_selectedDay.toString());
          },
          inputFormatters: [
            //  FilteringTextInputFormatter.digitsOnly,
            DateFormatter(),
          ],
        ),
      ),
    );
  }
}

class DateFormatter extends TextInputFormatter {
  final String mask = 'xx-xx-xxxx';
  final String separator = '-';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 0) {
      if (newValue.text.length > oldValue.text.length) {
        String lastEnteredChar =
            newValue.text.substring(newValue.text.length - 1);
        if (!_isNumeric(lastEnteredChar)) return oldValue;

        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          String value = oldValue.text; //_validateValue(
          print(value);

          return TextEditingValue(
            text: '$value$separator$lastEnteredChar',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }

        if (newValue.text.length == mask.length) {
          return TextEditingValue(
            text: '${newValue.text}', //_validateValue(
            selection: TextSelection.collapsed(
              offset: newValue.selection.end,
            ),
          );
        }
      }
    }
    return newValue;
  }

  bool _isNumeric(String? s) {
    if (s == null) return false;
    return double.tryParse(
          s,
        ) !=
        null;
  }
}
