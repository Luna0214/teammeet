import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({
    super.key,
    required this.iconOn,
    required this.iconOff,
    required this.onFunction,
    required this.offFunction,
  });
  final IconData iconOn;
  final IconData iconOff;
  final Function() onFunction;
  final Function() offFunction;

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool isActive = false;

  @override
  void initState() {
    super.initState();
  }

  void toggle() {
    setState(() {
      isActive = !isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? Colors.green : Colors.white),
      ),
      child: IconButton(
        onPressed: () {
          toggle();
          if (isActive) {
            widget.onFunction();
          } else {
            widget.offFunction();
          }
        },
        icon: Icon(isActive ? widget.iconOn : widget.iconOff),
        color: isActive ? Colors.green : Colors.red,
      ),
    );
  }
}
