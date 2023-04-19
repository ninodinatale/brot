import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef BrotListBuilder<T> = Widget Function(BuildContext, T, bool isSelected);

class AnimatedListOf<T> extends StatefulWidget {
  final BrotListBuilder<T> itemBuilder;
  final void Function(T item, int index)? onTap;

  const AnimatedListOf({Key? key, required this.itemBuilder, this.onTap})
      : super(key: key);

  @override
  AnimatedListStateOf<T> createState() => AnimatedListStateOf<T>();
}

/// Keeps a Dart [List] in sync with an [AnimatedList].
///
/// The [insert] and [removeAt] methods apply to both the internal list and
/// the animated list that belongs to [listKey].
///
/// This class only exposes as much of the Dart List API as is needed by the
/// sample app. More list methods are easily added, however methods that
/// mutate the list must make the same changes to the animated list in terms
/// of [AnimatedListState.insertItem] and [AnimatedList.removeItem].
class AnimatedListStateOf<T> extends State<AnimatedListOf<T>> {
  AnimatedListStateOf({
    Iterable<T>? initialItems,
  }) : _items = List<T>.from(initialItems ?? <T>[]);

  final _animatedListKey = GlobalKey<AnimatedListState>();
  final List<T> _items;
  int _selectedIndex = -1;

  AnimatedListState? get _animatedList => _animatedListKey.currentState;

  Duration _insertDebounceTime = Duration.zero;
  Duration _removeDebounceTime = Duration.zero;
  static const _DEBOUNCE_TIME_INCREMENT_MS = 250;

  void insert(T item) {
    Timer(_insertDebounceTime + Duration.zero, () async {
      _items.add(item);
      _animatedList?.insertItem(_items.length - 1);
      if (_insertDebounceTime.inMilliseconds > _DEBOUNCE_TIME_INCREMENT_MS) {
        _insertDebounceTime = _insertDebounceTime -
            const Duration(milliseconds: _DEBOUNCE_TIME_INCREMENT_MS);
      } else {
        _insertDebounceTime = Duration.zero;
      }
    });
    _insertDebounceTime = _insertDebounceTime +
        const Duration(milliseconds: _DEBOUNCE_TIME_INCREMENT_MS);
  }

  void removeAt(int index) {
    Timer(_removeDebounceTime + Duration.zero, () async {
      final T removedItem = _items.removeAt(index);
      _selectedIndex = index == _selectedIndex ? -1 : _selectedIndex;
      if (removedItem != null) {
        _animatedList!.removeItem(
          index,
          (BuildContext context, Animation<double> animation) {
            return _itemBuilderWrapper(
                item: removedItem,
                animation: animation,
                context: context,
                itemBuilderChild: widget.itemBuilder,
                isSelected: index == _selectedIndex);
          },
        );
      }
      if (_removeDebounceTime.inMilliseconds > _DEBOUNCE_TIME_INCREMENT_MS) {
        _removeDebounceTime = _removeDebounceTime -
            const Duration(milliseconds: _DEBOUNCE_TIME_INCREMENT_MS);
      } else {
        _removeDebounceTime = Duration.zero;
      }
    });
    _removeDebounceTime = _removeDebounceTime +
        const Duration(milliseconds: _DEBOUNCE_TIME_INCREMENT_MS);
  }

  void selectItem(T item) {
    selectIndex(_items.indexOf(item));
  }

  void selectIndex(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? -1 : index;
    });
  }

  void deselect() {
    setState(() {
      _selectedIndex = -1;
    });
  }

  int get length => _items.length;

  List<T> get items => _items;

  T operator [](int index) => _items[index];

  int indexOf(T item) => _items.indexOf(item);

  Widget _itemBuilderWrapper(
      {required BuildContext context,
      required BrotListBuilder<T> itemBuilderChild,
      required Animation<double> animation,
      required T item,
      required bool isSelected,
      void Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: const Offset(0, 0),
        ).animate(animation),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: itemBuilderChild(context, item, isSelected),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _animatedListKey,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) => _itemBuilderWrapper(
          itemBuilderChild: widget.itemBuilder,
          animation: animation,
          onTap: () => widget.onTap?.call(_items[index], index),
          context: context,
          isSelected: index == _selectedIndex,
          item: _items[index]),
    );
  }
}
