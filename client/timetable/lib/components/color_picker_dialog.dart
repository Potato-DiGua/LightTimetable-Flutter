import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:light_timetable_flutter_app/data/values.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initColor;

  ColorPickerDialog({required this.initColor});

  static Future<Color?> show(BuildContext context,
      {Color initColor = Values.bgWhite}) {
    // raise the [showDialog] widget
    return showDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          initColor: initColor,
        );
      },
    );
  }

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.initColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorPicker(
            pickerColor: _color,
            onColorChanged: _changeColor,
            pickerAreaHeightPercent: 0.6,
            pickerAreaBorderRadius: const BorderRadius.only(
              topLeft: const Radius.circular(2.0),
              topRight: const Radius.circular(2.0),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, _color);
            },
            child: Text("确定"))
      ],
    );
  }

  void _changeColor(Color color) {
    setState(() {
      _color = color;
    });
  }
}
