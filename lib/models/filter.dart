
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

import 'order.dart';

class Filter {
  dynamic price;
  dynamic day;
  dynamic month;
  dynamic year;
  //AppointmentDate date;
  Filter({
    this.price,
    this.day,
    this.month,
    this.year,
  });

  factory Filter.fromMap(Map  data) {
    return Filter(
      price: data['price'],
      day: data['day'],
      month: data['month'],
      year: data['year'],


    );
  }
}
class AppointmentDate {
  int day;
  int month;
  int year;

  AppointmentDate({
    required this.day,
    required this.month,
    required this.year,
  });

  factory AppointmentDate.fromHashmap(Map<String, dynamic> Details) {
    return AppointmentDate(
      day: Details['day'],
      month: Details['month'],
      year: Details['year'],
    );
  }
}
class AppointmentTime {
  int hour;
  int minute;

  AppointmentTime({
    required this.hour,
    required this.minute,
  });

  factory AppointmentTime.fromHashmap(Map<String, dynamic> Details) {
    return AppointmentTime(
      hour: Details['hour'],
      minute: Details['minute'],
    );
  }
}


