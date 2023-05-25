


import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';

enum call_permision{
  cameraGranted,
  micGranted,
  cameradined,
  micdined

}
enum call_State{
  anotherCall,
  calling,
  refusd,
  closed,
  inCall

}

class InintCall {


  bool isVideoCall;
  String callerId='';
  String reciverId="";
  String appointmentId='';
  InintCall(this.isVideoCall,this.callerId,this.reciverId,this.appointmentId);

  Function (call_permision) ? checkCallPermissions ;

  Function (call_State)? checkCallState ;

trigerCallState(){

  FirebaseDatabase.instance.ref('userCallState').child(reciverId).child('callState').onValue.listen((event) {
    print("sasasasavcvc${event.snapshot.value}");
    if(event.snapshot!=null){

      if(event.snapshot.value=='calling'){
        checkCallState!.call(call_State.calling);
      }
      else if(event.snapshot.value=='refused'){
        checkCallState!.call(call_State.refusd);

      }else if(event.snapshot.value=='closed'){
        checkCallState!.call(call_State.closed);

      }else if(event.snapshot.value=='oncall'){
        checkCallState!.call(call_State.inCall);

      }



    }



  });
}
 Future<void> requstCallPermissions() async {



   if(isVideoCall){
     var cameraStatus=  await  Permission.camera.request();
   var  MicStatus=   await  Permission.microphone.request();


     if (cameraStatus.isGranted) {
       print("permisssingmmmgg");
       checkCallPermissions?.call(call_permision.cameraGranted);

     }
     if(MicStatus.isGranted){

       checkCallPermissions?.call(call_permision.micGranted);



     }
     if(!cameraStatus.isGranted){
       print("permisssingmmmggg");
       checkCallPermissions?.call(call_permision.cameradined);

     }
      if(!MicStatus.isGranted){
       checkCallPermissions?.call(call_permision.micdined);

     }


   }else{
     await  Permission.microphone.request();
     var MicStatus = await Permission.microphone.status;


    if(MicStatus.isGranted){

       checkCallPermissions?.call(call_permision.micGranted);



     } else if(!MicStatus.isGranted){
      checkCallPermissions?.call(call_permision.micdined);

    }
   }




 }

 checkuserCallState() async {

   try{
     FirebaseFunctions functions = FirebaseFunctions.instance;
    // functions.useFunctionsEmulator('127.0.0.1', 5001);
     //functions("10.0.2.2", 5001);

//
     HttpsCallable callable =   functions.httpsCallable("checkUserCallState");

     final res  = await callable.call({
       'appointmentId':appointmentId,
       'reciverId':reciverId,
       'isNormal':isVideoCall

     });


     print('rescall${res.data['code']}');


     if(res.data['code']==101){


    //   Fluttertoast.showToast(msg:  res.data['message']);

     //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: res.data['message']));


     }
     else if(res.data['code']==200){

       // Future(() =>
       //     Navigator.of(context).push(MaterialPageRoute(builder: (con) =>
       //         CallSample(host: widget.appointment.appointmentId, iscaller: true,
       //           loggedUser: widget.loggedUser,appointment: widget.appointment, isVideo: true,normalCall: true,CallerId: FirebaseAuth.instance.currentUser!.uid!
       //           ,ReciverId: widget.appointment.user.uid,))));

     }




     print('rescall${res.data['code']}');


     return res.data;


   }catch(e){
    throw 'internal error';

   }

 }



}