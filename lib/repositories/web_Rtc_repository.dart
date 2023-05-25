import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../blocs/web_rtc_bloc/getRenders.dart';
import '../providers/web_Rtc_provider.dart';
import 'base_repository.dart';

class WebRtcRepository extends BaseRepository{
  WebRtcProvider webRtcProvider = WebRtcProvider();

  Future<bool>initRenderers(bool audioEnable, bool videoEnable) =>webRtcProvider.initRenderers(audioEnable, videoEnable);
  Future<RTCVideoRenderer> getUserMedia(bool audioEnable,bool videoEnable)=>webRtcProvider.getUserMedia(audioEnable, videoEnable);
  Future<RTCPeerConnection>createPeerConnectionprovider(bool audioEnable,bool videoEnable)=>webRtcProvider.createPeerConnectionprovider( audioEnable, videoEnable);
  Future<bool> setCandidateOffer(String AppAppointmentsId)=>webRtcProvider.setCandidateOffer(AppAppointmentsId);
 void setCandidateAnswer(String AppAppointmentsId)=>webRtcProvider.setCandidateAnswer(AppAppointmentsId);
  Future<bool>createOffer(bool audioEnable,bool videoEnable,String AppAppointmentsId,String? userid,String? callerid)=>webRtcProvider.createOffer(audioEnable, videoEnable, AppAppointmentsId, userid,callerid);
  Future<bool>createAnswer(bool audioEnable,bool videoEnable,String AppAppointmentsId, String? userid,callerid)=>webRtcProvider.createAnswer(audioEnable, videoEnable, AppAppointmentsId,userid,callerid);
  void getCandidateOffer(String AppAppointmentsId)=>webRtcProvider.getCandidateOffer(AppAppointmentsId);
  void getCandidateAnswer(String AppAppointmentsId)=>webRtcProvider.getCandidateAnswer(AppAppointmentsId);
  void getOffer(String AppAppointmentsId,String callerid,String userid)=>webRtcProvider.getOffer(AppAppointmentsId,callerid,userid);
  void getAnswer(String AppAppointmentsId,String callerid,String userid)=>webRtcProvider.getAnswer(AppAppointmentsId, callerid, userid);
  Future<bool> dactiveCall(String AppAppointmentsId)=>webRtcProvider.dactiveCall( AppAppointmentsId);
  Future<bool> cancelCall(String AppAppointmentsId)=>webRtcProvider.cancelCall( AppAppointmentsId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> getInomingCall()=>webRtcProvider.getInomingCall();
  Stream<RTCVideoRenderer>getremoteRender()=>webRtcProvider.getremoteRender();
  Stream<RTCVideoRenderer>getlocalRender()=>webRtcProvider.getlocalRender();
  void  setrenderState(getrenders getrenders)=>webRtcProvider.setrenderState(getrenders);
/////

  @override
  void dispose() {
    webRtcProvider.dispose();
  }

}