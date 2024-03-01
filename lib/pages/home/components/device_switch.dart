import 'package:flutter/material.dart';

class DeviceSwitch extends StatefulWidget {
  const DeviceSwitch({
    Key? key,
    required this.initialValue,
    required this.toggle,
  }) : super(key: key);

  final bool initialValue;
  final Function(bool state) toggle;

  @override
  _DeviceSwitchState createState() => _DeviceSwitchState();
}

class _DeviceSwitchState extends State<DeviceSwitch> {
  late bool on;
  late Function(bool state) toggle;

  @override
  void initState() {
    super.initState();
    on = widget.initialValue;
    toggle = widget.toggle;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: 56,
      child: OutlinedButton(
        onPressed: () => setState(() {
          on = !on;
          toggle(on);
        }),
        style: OutlinedButton.styleFrom(
          foregroundColor: on ? Colors.green : Colors.black,
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: on ? Colors.green : Colors.black,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(64),
            ),
          ),
        ),
        child: Text(
          on ? 'On' : 'Off',
          softWrap: false,
        ),
      ),
    );
  }
}
