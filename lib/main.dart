import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Dock(
            itemsLabel: const ["Person", "Message", "Call", "Camera", "Photo"],
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, label, isHovered) {
              return AnimatedIconWidget(
                icon: icon,
                label: label,
                isHovered: isHovered,
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.itemsLabel,
    required this.builder,
  });

  final List<T> items;
  final List<String> itemsLabel;
  final Widget Function(T, String, bool) builder; // Updated to include isHovered

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late List<T> _items;
  late List<String> _itemsLabels;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
    _itemsLabels = widget.itemsLabel.toList();
  }

  void onDragCompleted(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex != oldIndex) {
        final item = _items.removeAt(oldIndex);
        final itemsLabel = _itemsLabels.removeAt(oldIndex);

        _items.insert(newIndex, item);
        _itemsLabels.insert(newIndex, itemsLabel);
      }
    });
  }
final RxInt hoveredIndex = (-1).obs;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black12,
      ),
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _items.length,
            (index) {
              final item = _items[index];
              return DraggableItem<T>(
                item: item,
                index: index,
                builder: widget.builder,
                onDragCompleted: onDragCompleted,
                label: widget.itemsLabel[index],
                hoveredIndex: hoveredIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}

class DraggableItem<T> extends StatefulWidget {
  final T item;
  final int index;
  final Widget Function(T, String, bool) builder;
  final Function(int, int) onDragCompleted;
  final String label;
  final RxInt hoveredIndex; // Global hovered index

  const DraggableItem({
    super.key,
    required this.item,
    required this.index,
    required this.builder,
    required this.onDragCompleted,
    required this.label,
    required this.hoveredIndex,
  });

  @override
  _DraggableItemState<T> createState() => _DraggableItemState<T>();
}

class _DraggableItemState<T> extends State<DraggableItem<T>> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.hoveredIndex.value = widget.index,
      onExit: (_) => widget.hoveredIndex.value = -1,
      child: Draggable<int>(
        data: widget.index,
        feedback: widget.builder(widget.item, widget.label, true),
        childWhenDragging: const SizedBox.shrink(),
        onDragCompleted: () => widget.onDragCompleted(widget.index, widget.index),
        child: DragTarget<int>(
          onAccept: (int fromIndex) {
            widget.onDragCompleted(fromIndex, widget.index);
          },
          builder: (context, candidateData, rejectedData) {
            return Obx(() {
              int distance = (widget.hoveredIndex.value - widget.index).abs();
              double alignmentY = 0.0;

              // Apply different alignment shifts based on distance
              if (distance == 0) {
                alignmentY = -1.0; // Main hovered item
              } else if (distance == 1) {
                alignmentY = -0.5; // Adjacent items
              } else if (distance == 2) {
                alignmentY = -0.25; // Second adjacent items
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: distance <= 0 ? 13 : 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment(0, widget.hoveredIndex.value == -1 ? 0 : alignmentY),
                  child: widget.builder(widget.item, widget.label, distance == 0),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}


class AnimatedIconWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHovered; // Hover state passed in

  const AnimatedIconWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(isHovered ? 13 : 10), // Enlarge on hover
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
