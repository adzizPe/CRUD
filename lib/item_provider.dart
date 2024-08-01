import 'package:flutter/material.dart';
import 'item.dart';
import 'dart:math';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];
  Item? _lastRemovedItem;
  int? _lastRemovedItemIndex;

  List<Item> get items => _items;

  void addItem(String name) {
    final newItem = Item(id: Random().nextDouble().toString(), name: name);
    _items.add(newItem);
    notifyListeners();
  }

  void updateItem(String id, String newName) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = Item(id: id, name: newName);
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _lastRemovedItem = _items[index];
      _lastRemovedItemIndex = index;
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void undoDelete() {
    if (_lastRemovedItem != null && _lastRemovedItemIndex != null) {
      _items.insert(_lastRemovedItemIndex!, _lastRemovedItem!);
      _lastRemovedItem = null;
      _lastRemovedItemIndex = null;
      notifyListeners();
    }
  }

  List<Item> searchItems(String query) {
    if (query.isEmpty) {
      return _items;
    }
    return _items.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
