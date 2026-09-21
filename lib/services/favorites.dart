import 'package:flutter/material.dart';

/// Favorit global berbasis id produk.
/// Dipakai Home, Products, Detail, dan Favorites agar konsisten.
final ValueNotifier<Set<int>> favoriteProductIds =
    ValueNotifier<Set<int>>({});

bool isFavorite(int id) => favoriteProductIds.value.contains(id);

void toggleFavoriteId(int id) {
  final updated = Set<int>.from(favoriteProductIds.value);
  if (updated.contains(id)) {
    updated.remove(id);
  } else {
    updated.add(id);
  }
  favoriteProductIds.value = updated;
}
