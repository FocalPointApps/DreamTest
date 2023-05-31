
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/models/appAnalysis.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/providers/base_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class UserDataProvider extends BaseUserDataProvider {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late GroceryUser user;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  static FirebaseDatabase database =  FirebaseDatabase.instanceFor(app:Firebase.app(),databaseURL: 'https://dream-43bb8-f2c7f.europe-west1.firebasedatabase.app');
  static final realtimeDbRef = database.ref();
  @override
  void dispose() {}

  @override
  Future<GroceryUser> getUser(String uid) async {
    DocumentReference docRef = db.collection(Paths.usersPath).doc(uid);
    final DocumentSnapshot documentSnapshot = await docRef.get();

    return GroceryUser.fromMap(documentSnapshot.data() as Map);
  }

  @override
  Future<GroceryUser> getUserByphoneNumber(String phoneNumber) async {
    DocumentReference docRef = db.collection(Paths.usersPath).doc("3JWofqSKSsTTxWGKiplPT0hAiVr1");
    final DocumentSnapshot documentSnapshot = await docRef.get();

    return GroceryUser.fromMap(documentSnapshot.data() as Map);
  }

  @override
  Future<GroceryUser?> saveUserDetails({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    String? tokenId,
    String? loggedInVia,
    String? userType,
    String? countryCode,
    String? countryISOCode,
  }) async {
    try {
      List<GroceryUser> users = [];
      DocumentReference ref = db.collection(Paths.usersPath).doc(uid);
      QuerySnapshot querySnapshot = await db
          .collection(Paths.usersPath)
          .where( 'phoneNumber', isEqualTo: phoneNumber, ).get();

      for (var doc in querySnapshot.docs) {
        print("testaaaaa");
        users.add(GroceryUser.fromMap(doc.data() as Map));
      }
      if(users.length==0){
        print("userfound111 false");
        var data = {
          'accountStatus': 'NotActive',
          'userLang':'ar',
          'profileCompleted':false,
          'isBlocked': false,
          'uid': uid,
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'photoUrl': photoUrl != null ? photoUrl : '',
          'tokenId': tokenId,
          'loggedInVia': loggedInVia,
          "userType":userType,
          "languages":[],
          "rating":0.0,
          "reviewsCount":0,
          "balance":0.0,
          "payedBalance":0.0,
          "ordersNumbers":0,
          "chat":false,
          "voice":false,
          "price":"0",
          "userConsultIds":null,
          "order":0,
          "countryCode":countryCode,
          "countryISOCode":countryISOCode,
          "createdDate": Timestamp.now(),
          "createdDateValue":DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day ).millisecondsSinceEpoch,


        };
        ref.set(data, SetOptions(merge: true));
        final DocumentSnapshot currentDoc = await ref.get();
        user = GroceryUser.fromMap(currentDoc.data() as Map);
        return user;
      }
      else
        {
          final DocumentSnapshot currentDoc = await ref.get();
          print("countryCodekkkkkkkk");
          print(countryCode);
          print(countryISOCode);
          user = GroceryUser.fromMap(currentDoc.data() as Map);
          return user;
        }
    } catch (e) {
      return null;
    }


  }

  @override
  Stream<AppAnalysis>? getAppAnalysis() {
    AppAnalysis appAnalysis;

    try {
      DocumentReference documentReference = db.doc(Paths.appAnalysisDocPath);
      return documentReference.snapshots().transform(StreamTransformer<
          DocumentSnapshot<Map<String, dynamic>>, AppAnalysis>.fromHandlers(
        handleData: (DocumentSnapshot snap, EventSink<AppAnalysis> sink) {
          if (snap.data != null) {
            appAnalysis = AppAnalysis.fromMap(snap.data() as Map);
            sink.add(appAnalysis);
          }
        },
        handleError: (error, stackTrace, sink) {
          sink.addError(error);
        },
      ));
    } catch (e) {
      print("appanalysissssss" + e.toString());
      return null;
    }
  }

  @override
  Future<GroceryUser?> getAccountDetails(String uid) async {
    try {
      print("GetAccountDetails12");

      DocumentSnapshot documentSnapshot = await db.collection(Paths.usersPath).doc(uid).get();
      print("GetAccountDetails13");

      GroceryUser currentUser = GroceryUser.fromMap(documentSnapshot.data() as Map);
      print("GetAccountDetails14");

      return currentUser;
    } catch (e) {
      print(e);
      print("GetAccountDetails16");

      return null;
    }
  }


  @override
  Future<bool> updateAccountDetails(GroceryUser user, File? profileImage) async {
    try {
      print("hhhh3");

      List<Map> intrList = [];
      for (var add in user.workTimes!) {
        Map firsttime = new Map();
        Map secondtime = Map();

        //first schedule
        firsttime.putIfAbsent('from', () => add.from);
        firsttime.putIfAbsent('to', () => add.to);
        //second schedule
        secondtime.putIfAbsent('from', () => add.fromtime);
        secondtime.putIfAbsent('to', () => add.totime);
        intrList.add(firsttime);
        intrList.add(secondtime);
      }
      print("hhhh4");
      if (profileImage != null) {
        //upload profile image first
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('profileImages/$uuid');
        await storageReference.putFile(profileImage);

        var url = await storageReference.getDownloadURL();

        await db.collection(Paths.usersPath).doc(user.uid).set({
          'name': user.name,
          'consultName': {
            'nameAr': user.consultName!.nameAr!,
            'nameEn': user.consultName!.nameEn!,
            'nameFr': user.consultName!.nameFr!,
            'nameIn': user.consultName!.nameIn!,
            'searchIndexAr': user.consultName!.searchIndexAr!,
            'searchIndexEn': user.consultName!.searchIndexEn!,
            'searchIndexFr': user.consultName!.searchIndexFr!,
            'searchIndexIn': user.consultName!.searchIndexIn!,
          },
          'consultBio': {
            'bioAr': user.consultBio!.bioAr!,
            'bioEn': user.consultBio!.bioEn!,
            'bioFr': user.consultBio!.bioFr!,
            'bioIn': user.consultBio!.bioIn!,
          },
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'photoUrl': url,
          'bio':user.bio,
          'price':user.price,
          'chatPrice':user.chatPrice,
          'languages':user.languages,
          'workDays':user.workDays,
          'workTimes':intrList,
          'voice':user.voice,
          'chat':user.chat,
          'userLang':user.userLang,
          'searchIndex':user.searchIndex,
          'fromUtc':user.fromUtc,
          'toUtc':user.toUtc,
         'profileCompleted': user.profileCompleted,
        }, SetOptions(merge: true));
      } else {
        //just update details

        await db.collection(Paths.usersPath).doc(user.uid).set({
          'name': user.name,
          'consultName': {
            'nameAr': user.consultName!.nameAr!,
            'nameEn': user.consultName!.nameEn!,
            'nameFr': user.consultName!.nameFr!,
            'nameIn': user.consultName!.nameIn!,
            'searchIndexAr': user.consultName!.searchIndexAr!,
            'searchIndexEn': user.consultName!.searchIndexEn!,
            'searchIndexFr': user.consultName!.searchIndexFr!,
            'searchIndexIn': user.consultName!.searchIndexIn!,
          },
          'consultBio': {
            'bioAr': user.consultBio!.bioAr!,
            'bioEn': user.consultBio!.bioEn!,
            'bioFr': user.consultBio!.bioFr!,
            'bioIn': user.consultBio!.bioIn!,
          },
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'photoUrl': user.photoUrl,
          'bio':user.bio,
          'price':user.price,
          'chatPrice':user.chatPrice,
          'languages':user.languages,
          'workDays':user.workDays,
          'workTimes':intrList,
          'voice':user.voice,
          'chat':user.chat,
          'userLang':user.userLang,
          'searchIndex':user.searchIndex,
          'fromUtc':user.fromUtc,
          'toUtc':user.toUtc,
          'profileCompleted': user.profileCompleted,
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      print("hhhh5");
      print(e);
      return false;
    }
  }

  @override
  Stream<UserNotification>? getNotifications(String uid) {
    try{
      //uid=FirebaseAuth.instance.currentUser.uid;
      print("loggedUId3 "+uid);
      DocumentReference documentReference = db.collection(Paths.noticationsPath).doc(uid);
      if(documentReference!=null)
      { print("loggedUId1 "+uid);}
      else
      { print("loggedUId2 "+uid);}
      print('inside notifications');
      return documentReference.snapshots().transform(
        StreamTransformer<DocumentSnapshot<Map<String, dynamic>> , UserNotification>.fromHandlers(
          handleData: (DocumentSnapshot docSnap, EventSink<UserNotification> sink) {
            UserNotification userNotification =UserNotification.fromMap(docSnap.data() as Map);
            print('UIDdddddd :: ${userNotification.uid}');
            sink.add(userNotification);
          },
          handleError: (error, stackTrace, sink) {
            print('ERRORdddddd: $error');
            print(stackTrace);
            sink.addError(error);
          },
        ),
      );
    }catch(e){print("error1111"+e.toString());}
  }

  @override
  Future<void> markNotificationRead(String uid) async {
    try {
      await db.collection(Paths.noticationsPath).doc(uid).set({
        'unread': false,
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
      return null;
    }
  }

}
