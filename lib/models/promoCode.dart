
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/consultPackage.dart';

class PromoCode {
  String promoCodeId;
  bool promoCodeStatus;
  Timestamp promoCodeTimestamp;
  String ownerName;
  String code;
  dynamic usedNumber;
  dynamic discount;
  String? type;

  PromoCode({
    required this.promoCodeId,
    required this.promoCodeStatus,
    required this.promoCodeTimestamp,
    this.type,
   
    required this.ownerName,
    required this.code,
    this.usedNumber,
    this.discount,



  });

  factory PromoCode.fromMap(Map  data) {
    return PromoCode(
      promoCodeId: data['promoCodeId'],
      promoCodeStatus: data['promoCodeStatus']==null?false:data['promoCodeStatus'],
      promoCodeTimestamp: data['promoCodeTimestamp'],
      type: data['type']==null?"default":data['type'],
      ownerName: data['ownerName'],
      code: data['code'],
      usedNumber: data['usedNumber']==null?0:data['usedNumber'],
      discount: data['discount'],

    );
  }
}


