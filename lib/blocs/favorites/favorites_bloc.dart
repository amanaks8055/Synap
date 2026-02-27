import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(const FavoritesState()) {
    on<LoadFavorites>(_onLoad);
    on<ToggleFavorite>(_onToggle);
    on<RemoveFavorite>(_onRemove);
  }

  void _onLoad(LoadFavorites event, Emitter<FavoritesState> emit) {
    // In future: load from SharedPreferences/Hive
    emit(state);
  }

  void _onToggle(ToggleFavorite event, Emitter<FavoritesState> emit) {
    final ids = List<String>.from(state.favoriteIds);
    if (ids.contains(event.toolId)) {
      ids.remove(event.toolId);
    } else {
      ids.add(event.toolId);
    }
    emit(state.copyWith(favoriteIds: ids));
  }

  void _onRemove(RemoveFavorite event, Emitter<FavoritesState> emit) {
    final ids = List<String>.from(state.favoriteIds)..remove(event.toolId);
    emit(state.copyWith(favoriteIds: ids));
  }
}
