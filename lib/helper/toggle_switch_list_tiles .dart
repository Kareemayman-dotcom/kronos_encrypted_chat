import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ToggleSwitchListTiles extends StatefulWidget {
  const ToggleSwitchListTiles({Key? key}) : super(key: key);

  @override
  State<ToggleSwitchListTiles> createState() => _ToggleSwitchListTilesState();
}

class _ToggleSwitchListTilesState extends State<ToggleSwitchListTiles> {
  int _selectedSwitch = 0; // Index of the currently selected switch

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15.h,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Option 1'),
            value: _selectedSwitch == 0,
            onChanged: (value) {
              setState(() {
                _selectedSwitch = 0;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Option 2'),
            value: _selectedSwitch == 1,
            onChanged: (value) {
              setState(() {
                _selectedSwitch = 1;
              });
            },
          ),
        ],
      ),
    );
  }
}
