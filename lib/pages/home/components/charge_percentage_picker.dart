import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../providers/charging_provider.dart';
import '../../../services/foreground_battery_service.dart';

class ChargePercentagePicker extends StatefulWidget {
  const ChargePercentagePicker({Key? key}) : super(key: key);

  @override
  State<ChargePercentagePicker> createState() => _ChargePercentagePickerState();
}

class _ChargePercentagePickerState extends State<ChargePercentagePicker> {
  late int _initialValue;

  @override
  void initState() {
    super.initState();
    _initialValue = Provider.of<ChargingProvider>(context, listen: false).chargingPreferences.chargePercentage;
  }

  @override
  Widget build(BuildContext context) {
    return SleekCircularSlider(
      initialValue: _initialValue.toDouble(),
      min: 0,
      max: 100,
      innerWidget: (percentage) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (percentage.round() != 0) const Text('Charge to:'),
            Text(
              percentage.round() == 0 ? 'OFF' : '${percentage.round()}%',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      appearance: CircularSliderAppearance(
        customColors: CustomSliderColors(
          dotColor: Colors.green.shade900,
          dynamicGradient: false,
          hideShadow: true,
          trackColor: Colors.green.shade100,
          progressBarColors: [Colors.green.shade200, Colors.green.shade800],
        ),
      ),
      onChangeEnd: (double value) {
        final cp = Provider.of<ChargingProvider>(context, listen: false);
        cp.chargingPreferences.chargePercentage = value.round();
        cp.chargingPreferences.chargeOff ? stopBatteryService() : startBatteryService();
        cp.save();
      },
    );
  }
}
