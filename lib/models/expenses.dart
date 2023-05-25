

import 'package:cloud_firestore/cloud_firestore.dart';

import 'AppAppointments.dart';
class Expenses {
  String id;
  String title;
  String desc;
  String platform;
  dynamic amount;
  Timestamp paidDate;
  AppointmentDate date;

  Expenses({
    required this.id,
    required this.title,
    required this.desc,
    required this.platform,
    this.amount,
    required this.paidDate,
    required this.date,

  });

  factory Expenses.fromMap(Map  data) {
    return Expenses(
      id: data['id'],
      title: data['title'],
      desc: data['desc'],
      platform: data['des'],
      amount: data['amount'],
      paidDate: data['paidDate'],
      date: AppointmentDate.fromHashmap(data['date']),
    );
  }
}
