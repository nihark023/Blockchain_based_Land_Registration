import 'package:flutter/material.dart';

class MenuItemTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final onTap;

  const MenuItemTile({
    Key? key,
    required this.title,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  _MenuItemTileState createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<MenuItemTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.isSelected
              ? Colors.transparent.withOpacity(0.3)
              : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: 70, //_animation.value,
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              widget.icon,
              color: widget.isSelected ? Colors.green : Colors.black,
              size: 28,
            ),
            const SizedBox(width: 5),
            Text(widget.title,
                style: widget.isSelected
                    ? const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)
                    : const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
