import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:learn_hiragana_app/model/model_factories.dart';

import '../services/api_services.dart';

// Events
abstract class HiraganaEvent extends Equatable {
  const HiraganaEvent();

  @override
  List<Object> get props => [];
}

class FetchHiraganaEvent extends HiraganaEvent {}

// States
abstract class HiraganaState extends Equatable {
  const HiraganaState();

  @override
  List<Object> get props => [];
}

class HiraganaInitial extends HiraganaState {}
class HiraganaLoading extends HiraganaState {}
class HiraganaLoaded extends HiraganaState {
  final List<HiraganaCharacters> hiraganaCharacters;

  const HiraganaLoaded(this.hiraganaCharacters);

  @override
  List<Object> get props => [hiraganaCharacters];
}
class HiraganaError extends HiraganaState {
  final String message;

  const HiraganaError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class HiraganaBloc extends Bloc<HiraganaEvent, HiraganaState> {
  final ApiService apiService;

  HiraganaBloc(this.apiService) : super(HiraganaInitial()) {
    on<FetchHiraganaEvent>(_onFetchHiraganaEvent);
  }

  void _onFetchHiraganaEvent(
      FetchHiraganaEvent event,
      Emitter<HiraganaState> emit
      ) async {
    emit(HiraganaLoading());
    try {
      final characters = await apiService.fetchHuruf();
      emit(HiraganaLoaded(characters));
    } catch (e) {
      emit(HiraganaError(e.toString()));
    }
  }
}
