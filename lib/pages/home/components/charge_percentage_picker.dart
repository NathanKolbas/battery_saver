import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/charging_provider.dart';
import '../../../services/foreground_battery_service.dart';

class ChargePercentagePicker extends StatefulWidget {
  const ChargePercentagePicker({Key? key}) : super(key: key);

  @override
  State<ChargePercentagePicker> createState() => _ChargePercentagePickerState();
}

class _ChargePercentagePickerState extends State<ChargePercentagePicker> {
  @override
  Widget build(BuildContext context) {
    final chargePercentage = context.select<ChargingProvider, int>((v) => v.chargingPreferences.chargePercentage);
    final chargePercentageTurnOn = context.select<ChargingProvider, int>((v) => v.chargingPreferences.chargePercentageTurnOn);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8,),
        Text.rich(
          TextSpan(
            text: 'Charge to: ',
            children: [
              TextSpan(
                text: chargePercentage.round() != 0 ? '${chargePercentage.round()}%' : 'OFF',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Slider(
          value: chargePercentage.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: chargePercentage.round() == 0 ? 'OFF' : '${chargePercentage.round()}%',
          onChanged: (double value) {
            // Should move the logic into the provider but whatever
            final cp = Provider.of<ChargingProvider>(context, listen: false);
            cp.chargingPreferences.chargePercentage = value.round();
            cp.chargingPreferences.chargePercentageTurnOn = max(0, min(
              cp.chargingPreferences.chargePercentageTurnOn,
              cp.chargingPreferences.chargePercentage - 1,
            ));
            cp.chargingPreferences.chargeOff ? stopBatteryService() : startBatteryService();
            cp.save();
          },
        ),
        const SizedBox(height: 8,),
        Text.rich(
          TextSpan(
            text: 'Start charging again at: ',
            children: [
              TextSpan(
                text: chargePercentageTurnOn.round() != 0 ? '${chargePercentageTurnOn.round()}%' : 'OFF',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Slider(
          value: chargePercentageTurnOn.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: chargePercentageTurnOn.round() == 0 ? 'OFF' : '${chargePercentageTurnOn.round()}%',
          onChanged: (double value) {
            // Should move the logic into the provider but whatever
            final cp = Provider.of<ChargingProvider>(context, listen: false);
            cp.chargingPreferences.chargePercentageTurnOn = max(0, min(value.round(), cp.chargingPreferences.chargePercentage - 1));
            cp.save();
          },
          activeColor: Colors.blue,
          inactiveColor: Colors.blue.shade100,
        ),
      ],
    );
  }
}
