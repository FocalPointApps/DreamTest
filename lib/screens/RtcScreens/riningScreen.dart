import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wakelock/wakelock.dart';

import '../../blocs/web_rtc_bloc/initCall.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import 'call_sample.dart';

class RiningScreen extends StatefulWidget {
  static String tag = 'call_sample';

  final String host;
  bool  ?iscaller=false;
  bool ?acceptNotfi=false;
  AppAppointments ? appointment;
  GroceryUser  ? loggedUser ;

  String ? CallerId ="";
  String ? ReciverId="";

  bool ? isVideo=true;
  bool ? normalCall=true;





  RiningScreen({required this.host,this.iscaller,this
      .acceptNotfi,this.appointment,this.loggedUser,this.isVideo,this.normalCall,this.CallerId,this.ReciverId});

  @override
  RiningScreenState createState() => RiningScreenState();
}

class RiningScreenState extends State<RiningScreen> {
  List<dynamic> _peers = [];
  String? _selfId;
  bool ? isVideoRemoteSignaling=true;
  bool ? isVideolocalSignaling=true;
  bool  cameraGranted=false;
  bool  micGranted=false;
  bool anotherCall=false;
  bool refused=false;
  bool closed=false;
  bool calling=false;




  bool startRecord=false;
  String micStateIcon='assets/icons/mute.png';
  String cameraStateIcon='assets/icons/videoon.png';

  late Size size;
  bool mic=true,camera=true,share=true,toggle=true;
  int minutes = 0, seconds = 0;

  bool _inCalling = false;

  bool _waitAccept = true;
  AudioPlayer audioPlayer=  AudioPlayer()..setReleaseMode(ReleaseMode.loop);



  // ignore: unused_element
  InintCall ? inintCall;

  bool fristload=true;


  @override
  void dispose() {
    super.dispose();
//    FirebaseDatabase.instance.ref('userCallState').child(widget.CallerId!).child('callState').set('closed');

  }

  @override
  initState() {
    super.initState();


    inintCall=  InintCall(widget.normalCall!,widget.CallerId!,widget.ReciverId!,widget.appointment!.appointmentId!);

    inintCall!.requstCallPermissions();

    inintCall?.checkCallPermissions=(checkpermission) async{
      switch (checkpermission){

        case call_permision.cameraGranted:
          cameraGranted=true;
          break;
        case call_permision.micGranted:
          micGranted=true;

          break;
        case call_permision.cameradined:
          cameraGranted=false;
          break;
        case call_permision.micdined:
          micGranted=false;
          break;
      }



      if(widget.normalCall!){
        print("callStateresss$micGranted}");

        if(cameraGranted&&micGranted)
          {

            var res=await  inintCall?.checkuserCallState();

            if(res['code']==101){

              anotherCall=true;

              //   Fluttertoast.showToast(msg:  res.data['message']);

              //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: res.data['message']));


            }
            else if(res['code']==200){
              anotherCall=false;
              inintCall!.trigerCallState();

              // Future(() =>
              //     Navigator.of(context).push(MaterialPageRoute(builder: (con) =>
              //         CallSample(host: widget.appointment.appointmentId, iscaller: true,
              //           loggedUser: widget.loggedUser,appointment: widget.appointment, isVideo: true,normalCall: true,CallerId: FirebaseAuth.instance.currentUser!.uid!
              //           ,ReciverId: widget.appointment.user.uid,))));

            }



          }


      }else if(!widget.normalCall!){
        if(micGranted)
        {
          var res=await  inintCall?.checkuserCallState();


          if(res['code']==101){

            anotherCall=true;
            //   Fluttertoast.showToast(msg:  res.data['message']);

            //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: res.data['message']));


          }
          else if(res['code']==200){
            anotherCall=false;

            FirebaseDatabase.instance.ref('userCallState').child( FirebaseAuth.instance.currentUser!.uid).child('callState').set('calling').then((value) =>  inintCall!.trigerCallState());



            // Future(() =>
            //     Navigator.of(context).push(MaterialPageRoute(builder: (con) =>
            //         CallSample(host: widget.appointment.appointmentId, iscaller: true,
            //           loggedUser: widget.loggedUser,appointment: widget.appointment, isVideo: true,normalCall: true,CallerId: FirebaseAuth.instance.currentUser!.uid!
            //           ,ReciverId: widget.appointment.user.uid,))));

          }



          print("callStateress${res}");

        }

      }
      fristload=false;
      setState(() {

      });

    };




    inintCall?.checkCallState=(callStat){
      switch (callStat){


        case call_State.anotherCall:


          break;
        case call_State.calling:
          // TODO: Handle this case.
          break;
        case call_State.refusd:
          refused=true;
          break;
        case call_State.closed:
          closed=true;
          break;
        case call_State.inCall:

          FirebaseDatabase.instance.ref('userCallState').child( FirebaseAuth.instance.currentUser!.uid).child('callState').set('oncall').then((value) =>    Future(() =>
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (con) =>
                  CallSample(host: widget.host, iscaller: true,
                    loggedUser: widget.loggedUser,appointment: widget.appointment, isVideo: true,normalCall: false,CallerId: FirebaseAuth.instance.currentUser!.uid!
                    ,ReciverId: widget.appointment?.user.uid,))))
          );



          break;
      }

      setState(() {
        fristload=false;
      });
    };

    if(!widget.iscaller!){
      setupAudio();
    }else{



      if(widget.iscaller!){

      }



    }


  }


  setupAudio() async {
    var audioByteData;
    // if(ifcaller){
    //    audioByteData = await rootBundle.load("assets/sound/jeraston.mp3");
    //
    // }
    // audioByteData = await rootBundle.load("sound/jeraston.mp3");

    //  Uint8List audioUint8List = audioByteData.buffer.asUint8List(audioByteData.offsetInBytes, audioByteData.lengthInBytes);
    //List<int> audioListInt = audioUint8List.map((eachUint8) => eachUint8.toInt()).toList();
    // audioPlayer.setSourceAsset('');
    audioPlayer.play(AssetSource('sound/jeraston.mp3'));

  }



  @override
  deactivate() {
    super.deactivate();

    audioPlayer.release();




  }









  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(onWillPop: ()async => true,
    child:
    Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247,1),
      extendBodyBehindAppBar: true,



      body: fristload?ShimmerLoad():
            widget.normalCall!&&!micGranted &&!cameraGranted?
            endWidget("camera_micPermissions")
           :!widget.normalCall!?!micGranted?
            endWidget("camera_micPermissions"):
            anotherCall?  endWidget("anotherCall"):
            refused? endWidget("userRefuse"):
            closed? endWidget("userClose"):
               FutureBuilder(
            future: FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.ReciverId).withConverter(
              fromFirestore: GroceryUser.fromFirestore,
              toFirestore: (GroceryUser user, _) => user.toFirestore(), ).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<GroceryUser>> snapshot) {

              if(snapshot.hasError){

                return endWidget('failed');
              }else if(snapshot.connectionState==ConnectionState.waiting){


                return ShimmerLoad();

              }else  {

                return   Stack(
                  children: [
                    // Positioned(
                    //     left: 10,
                    //     top: 10,
                    //     child:
                    //     Container(
                    //       width: 150,
                    //       height: 150,
                    //       child: RTCVideoView( _localRenderer!),
                    //     )
                    // ),
                    Align(child:
                    Container(padding: EdgeInsets.symmetric(vertical: 50),
                      child:Column( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                            children: [
                              Stack(children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Lottie.asset('assets/lotifile/callinganim.json'),
                                ),
                                Positioned(
                                  bottom: 60,
                                  left: MediaQuery.of(context).size.width/2-50,
                                  child: ClipRRect( borderRadius: BorderRadius.circular(80.0),
                                    child: FadeInImage.assetNetwork(
                                      width: 80,
                                      height: 80,
                                      placeholder: 'assets/call/bxs-user-circle@3x.png',
                                      placeholderScale: 0.5,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) =>
                                          Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey,
                                            child:  Image.asset(
                                              'assets/call/bxs-user-circle@3x.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                      image:snapshot.data!.data()!.photoUrl!,
                                      fit: BoxFit.cover,
                                      fadeInDuration:
                                      Duration(milliseconds: 250),
                                      fadeInCurve: Curves.easeInOut,
                                      fadeOutDuration:
                                      Duration(milliseconds: 150),
                                      fadeOutCurve: Curves.easeInOut,
                                    ),
                                  ),

                                )

                              ],),
                              text(snapshot.data!.data()!.name!,28,Color.fromRGBO(32, 32 ,32,1),FontWeight.w600),
                              text(getTranslated(context, "callingNow"),15,Color.fromRGBO(147, 147 ,147,1),FontWeight.normal),
                            ],
                          ),
                          SizedBox(),
                          !widget.iscaller!? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              refuseWidget(),
                              SizedBox(width:size.width*.20 ,),
                              acceptWidget(),
                            ],
                          ):widget.iscaller!? refuseWidget():Container(),

                        ],) ,)






                      ,)

                  ],
                );

              }




          },):
               FutureBuilder(
    future: FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.ReciverId).withConverter(
    fromFirestore: GroceryUser.fromFirestore,
    toFirestore: (GroceryUser user, _) => user.toFirestore(), ).get(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<GroceryUser>> snapshot) {

    if(snapshot.hasError){

    return endWidget('failed');
    }else if(snapshot.connectionState==ConnectionState.waiting){


    return ShimmerLoad();

    }else  {

    return   Stack(
    children: [
    // Positioned(
    //     left: 10,
    //     top: 10,
    //     child:
    //     Container(
    //       width: 150,
    //       height: 150,
    //       child: RTCVideoView( _localRenderer!),
    //     )
    // ),
    Align(child:
    Container(padding: EdgeInsets.symmetric(vertical: 50),
    child:Column( mainAxisAlignment: MainAxisAlignment.spaceBetween,
    mainAxisSize: MainAxisSize.max,
    children: [
    Column(
    children: [
    Stack(children: [
    Align(
    alignment: Alignment.center,
    child: Lottie.asset('assets/lotifile/callinganim.json'),
    ),
    Positioned(
    bottom: 60,
    left: MediaQuery.of(context).size.width/2-50,
    child: ClipRRect( borderRadius: BorderRadius.circular(80.0),
    child: FadeInImage.assetNetwork(
    width: 80,
    height: 80,
    placeholder: 'assets/call/bxs-user-circle@3x.png',
    placeholderScale: 0.5,
    imageErrorBuilder:
    (context, error, stackTrace) =>
    Container(
    width: 100,
    height: 100,
    color: Colors.grey,
    child:  Image.asset(
    'assets/call/bxs-user-circle@3x.png',
    width: 30,
    height: 30,
    ),
    ),
    image:snapshot.data!.data()!.photoUrl!,
    fit: BoxFit.cover,
    fadeInDuration:
    Duration(milliseconds: 250),
    fadeInCurve: Curves.easeInOut,
    fadeOutDuration:
    Duration(milliseconds: 150),
    fadeOutCurve: Curves.easeInOut,
    ),
    ),

    )

    ],),
    text(snapshot.data!.data()!.name!,28,Color.fromRGBO(32, 32 ,32,1),FontWeight.w600),
    text(getTranslated(context, "callingNow"),15,Color.fromRGBO(147, 147 ,147,1),FontWeight.normal),
    ],
    ),
    SizedBox(),
    !widget.iscaller!? Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    refuseWidget(),
    SizedBox(width:size.width*.20 ,),
    acceptWidget(),
    ],
    ):widget.iscaller!? refuseWidget():Container(),

    ],) ,)






    ,)

    ],
    );

    }




    },)







    ));


  }
  
  
  Widget ShimmerLoad(){
    return  Stack(
      children: [
        // Positioned(
        //     left: 10,
        //     top: 10,
        //     child:
        //     Container(
        //       width: 150,
        //       height: 150,
        //       child: RTCVideoView( _localRenderer!),
        //     )
        // ),
        Align(child:
        Container(padding: EdgeInsets.symmetric(vertical: 50),
          child:Column( mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  Stack(children: [
                    Shimmer.fromColors(
                        period: Duration(milliseconds: 800),
                        baseColor: Colors.grey.withOpacity(0.6),
                        highlightColor: Colors.black.withOpacity(0.6),
                        child: Container(
                          height: 100,
                          width: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ))


                  ],),
                  SizedBox(width:size.width*.20 ,height: 10,),

                  Shimmer.fromColors(
                      period: Duration(milliseconds: 800),
                      baseColor: Colors.grey.withOpacity(0.6),
                      highlightColor: Colors.black.withOpacity(0.6),
                      child: Container(
                        height: 50,
                        width: kIsWeb && MediaQuery.of(context).size.width > 400
                            ? MediaQuery.of(context).size.width * .3
                            : MediaQuery.of(context).size.width * .8,
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      )),
                  SizedBox(width:size.width*.20 ,height: 10,),

                  Shimmer.fromColors(
                      period: Duration(milliseconds: 800),
                      baseColor: Colors.grey.withOpacity(0.6),
                      highlightColor: Colors.black.withOpacity(0.6),
                      child: Container(
                        height: 50,
                        width: kIsWeb && MediaQuery.of(context).size.width > 400
                            ? MediaQuery.of(context).size.width * .3
                            : MediaQuery.of(context).size.width * .8,
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ))                ],
              ),
              SizedBox(),
              !widget.iscaller!? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Shimmer.fromColors(
                      period: Duration(milliseconds: 800),
                      baseColor: Colors.grey.withOpacity(0.6),
                      highlightColor: Colors.black.withOpacity(0.6),
                      child:  Container(
                        height: 60,width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30.0),

                        ),
                      ))

                ,

                  SizedBox(width:size.width*.20 ,height: 10,),
                  Shimmer.fromColors(
                      period: Duration(milliseconds: 800),
                      baseColor: Colors.grey.withOpacity(0.6),
                      highlightColor: Colors.black.withOpacity(0.6),
                      child:  Container(
                        height: 60,width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30.0),

                        ),
                      )),
                  SizedBox(width:size.width*.20 ,height: 10,),

                ],
              ):widget.iscaller!?                   Shimmer.fromColors(
                  period: Duration(milliseconds: 800),
                  baseColor: Colors.grey.withOpacity(0.6),
                  highlightColor: Colors.black.withOpacity(0.6),
                  child:  Container(
                    height: 60,width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30.0),

                    ),
                  )) :Container(),

            ],) ,)






          ,)

      ],

    ) ;
  }
  
  Widget refuseWidget(){
    return  InkWell(onTap: (){
      print("kkkkkkkkkkkkkk");
      audioPlayer.stop();
      Navigator.pop(context);

    }, child:
    Container(
      height: 60,width: 100,
      decoration: BoxDecoration(
        color: Color.fromRGBO(234, 33, 33,1),
        borderRadius: BorderRadius.circular(30.0),

      ),
      child: Center(
        child: Image.asset(
          'assets/call/md-call@3x.png',
          width: 40,
          height: 40,
        ),
      ),
    ),
    );
  }
  Widget acceptWidget(){
    return  InkWell(onTap: (){
     // _accept();
      setState(() {
        _inCalling = true;
      });
    },
      child: Container(
        height: 60,width: 100,
        decoration: BoxDecoration(
          color: Color.fromRGBO( 1 ,199 ,21,1),
          borderRadius: BorderRadius.circular(30.0),

        ),
        child: Center(
          child: Image.asset(
            'assets/call/md-call1@3x.png',
            width: 25,
            height: 25,
          ),
        ),
      ),
    );
  }
  Widget closeWidget(){
    return  InkWell(onTap: (){
      print("kkkkkkkkkkkkkk");
      audioPlayer.stop();

      Wakelock.disable();
      Navigator.pop(context);

    }, child:
    Container(
      height: 40,width: 200,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20.0),

      ),
      child: Center(
        child: text(getTranslated(context, "Ok"),15,Colors.white,FontWeight.w300),
      ),
    ),
    );
  }
  endWidget(String _text){return
    Container(
      child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x33ae9cce),
                      offset: Offset(0, 6),
                      blurRadius: 12,
                      spreadRadius: 0)
                ],
                color: Colors.white,
                border: Border.all(
                  width: 6,
                  color: Colors.white,
                ),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/applicationIcons/whiteLogo.png',
                width: 65,
                height: 65,
              )
          ),
          SizedBox(height: size.height*.15,),
          Center(child: text(getTranslated(context, _text),13,Color.fromRGBO(32, 32 ,32,1),FontWeight.w500)),
          SizedBox(height: size.height*.15,),
          Center(child: closeWidget())
        ],
      ),
    );}



  Widget text(String text,double size,Color color,FontWeight weight){
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily:"Ithra",// 'Montserrat',
          fontSize: size,
          color: color,
          fontWeight: weight),
    );
  }


  BoxDecoration decoration(){
    return  BoxDecoration(
        shape: BoxShape.circle,
        //color: Color.fromRGBO(255, 255, 255,.42),
        border: Border.all(color: Color.fromRGBO(211, 211 ,211,1), width: .5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(255, 255, 255, 0),
            Color.fromRGBO(0, 0, 0, 1),
          ],
        )
    );
  }
}