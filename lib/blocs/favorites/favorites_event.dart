abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final String toolId;
  ToggleFavorite(this.toolId);
}

class RemoveFavorite extends FavoritesEvent {
  final String toolId;
  RemoveFavorite(this.toolId);
}
