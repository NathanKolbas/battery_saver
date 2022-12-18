import 'package:battery_saver/hive/preferences/device_preference.dart';
import 'package:battery_saver/wyze/models/devices/plugs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/charging_provider.dart';
import '../../../providers/wyze_client_provider.dart';
import '../../../wyze/models/devices/base.dart';
import 'device_switch.dart';

class Devices extends StatelessWidget {
  final List<Device> devices;

  const Devices({Key? key, required this.devices}) : super(key: key);

  String parseMac(String mac) {
    mac = mac.replaceAll(' ', '').trim();
    RegExp exp = RegExp(r"([\S]{2})");
    Iterable<Match> matches = exp.allMatches(mac);
    final list = matches.map((m) => m.group(0));
    return list.join(':');
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        // print(device.product?.logoUrl);
        if (device is! Plug) return const SizedBox.shrink();
        if (device.mac == null) return const SizedBox.shrink();
        if (device.product == null) return const SizedBox.shrink();
        if (device.product?.model == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: Provider.of<ChargingProvider>(context).chargingPreferences.selectedDevices.any((d) => d.mac == device.mac),
                    onChanged: (b) {
                      final chargingProvider = Provider.of<ChargingProvider>(context, listen: false);
                      final cp = chargingProvider.chargingPreferences;
                      if (b ?? true) {
                        // selected
                        cp.selectedDevices.add(DevicePreferences(mac: device.mac!, model: device.product!.model!));
                      } else {
                        // unselected
                        cp.selectedDevices.removeWhere((d) => d.mac == device.mac);
                      }
                      chargingProvider.save();
                    },
                  ),
                  // if (device.product?.logoUrl?.isNotEmpty == true) Image.network(device.product!.logoUrl!),
                  const SizedBox(width: 4,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.nickname ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('Mac: ${parseMac(device.mac ?? '')}'),
                    ],
                  ),
                ],
              ),
              DeviceSwitch(
                toggle: (b) {
                  final client = Provider.of<WyzeClientProvider>(context, listen: false);
                  b ?
                    client.turnOnPlug(device.mac!, device.product!.model!) :
                    client.turnOffPlug(device.mac!, device.product!.model!);
                },
                initialValue: device.isOn,
              ),
            ],
          ),
        );
      },
    );
  }
}
