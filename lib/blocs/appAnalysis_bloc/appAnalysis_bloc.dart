

import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../models/appAnalysis.dart';
import '../../repositories/user_data_repository.dart';
import 'package:meta/meta.dart';

part 'appAnalysis_event.dart';
part 'appAnalysis_state.dart';

class AppAnalysisBloc extends Bloc<AppAnalysisEvent, AppAnalysisState> {
  final UserDataRepository userDataRepository;
  StreamSubscription? appAnalysisSubscription;

  AppAnalysisBloc({required this.userDataRepository}) : super(AppAnalysisInitialState());

  @override
  AppAnalysisState get initialState => AppAnalysisInitialState();

  @override
  Future<void> close() {
    print('Closing appAnalysisSubscription BLOC');
    appAnalysisSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<AppAnalysisState> mapEventToState(
      AppAnalysisEvent event,
      ) async* {

    if (event is UpdateAppAnalysisEvent) {
      yield* mapUpdateProductAnalyticsEventToState(event.appAnalysis);
    }

  }



  Stream<AppAnalysisState> mapUpdateProductAnalyticsEventToState(
      AppAnalysis appAnalysis) async* {
    yield GetAppAnalysisCompletedState(appAnalysis: appAnalysis);
  }

}
