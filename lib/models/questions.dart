
import 'package:cloud_firestore/cloud_firestore.dart';

class Questions {
  String id;
  String arQuestion;
  String enQuestion;
  String arAnswer;
  String enAnswer;
  int order;
  String? link;
  bool status;
  List<dynamic> searchIndexAr;
  List<dynamic> searchIndexEn;

  Questions({
    required this.id,
    required this.arQuestion,
    required this.enQuestion,
    required this.arAnswer,
    required this.enAnswer,
    required this.order,
    required this.status,
    this.link,
    required this.searchIndexAr,
    required this.searchIndexEn,
  });

  factory Questions.fromMap(Map  data) {

    return Questions(
      id: data['id'],
      arQuestion: data['arQuestion'],
      enQuestion: data['enQuestion'],
      arAnswer: data['arAnswer'],
      enAnswer: data['enAnswer'],
      order: data['order'],
      status:data['status'],
      link:data['link'],
      searchIndexEn:data['searchIndexEn'],
      searchIndexAr:data['searchIndexAr'],
    );
  }
}


