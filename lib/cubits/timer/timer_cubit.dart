import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eschool/utils/constants.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  Timer? _timer;
  bool isFirstTimer = false;

  TimerCubit() : super(TimerInitial());

  void startTimer(int minutes) {
    _timer?.cancel(); // Cancel any existing timers

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      emit(TimerRunning(minutes * 60 - timer.tick));
      if (timer.tick >= minutes * 60) {
        timer.cancel();
        emit(TimerComplete());
        logger.i(isFirstTimer);

        if (isFirstTimer) {
          _startNextTimer(20); // Start the second timer
        } else {
          _startNextTimer(5); // Start the first timer
        }
        isFirstTimer = !isFirstTimer; // Switch between timers
      }
    });
  }

  void _startNextTimer(int minutes) {
    emit(TimerReset());
    startTimer(minutes);
  }

  void disposeTimer() {
    _timer?.cancel(); // Cancel the timer when leaving the page
    isFirstTimer = false;
    emit(TimerReset());
  }
}
