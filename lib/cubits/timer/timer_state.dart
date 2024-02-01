part of 'timer_cubit.dart';


abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object> get props => [];
}

class TimerInitial extends TimerState {}

class TimerRunning extends TimerState {
  final int secondsRemaining;

  const TimerRunning(this.secondsRemaining);

  @override
  List<Object> get props => [secondsRemaining];
}

class TimerComplete extends TimerState {}

class TimerReset extends TimerState {}
