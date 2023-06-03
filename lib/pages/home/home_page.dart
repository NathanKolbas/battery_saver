import 'package:battery_saver/helpers/updater.dart';
import 'package:battery_saver/pages/home/components/devices.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../pigeon/battery_changed_pigeon.g.dart';
import '../../providers/wyze_client_provider.dart';
import 'components/charge_percentage_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? isBatteryOptimizationDisabled;
  final fBatteryChangedPigeon = FBatteryChangedPigeon();

  requestBatteryOptimizationDisabled() async {
    isBatteryOptimizationDisabled = (await DisableBatteryOptimization.isBatteryOptimizationDisabled) == true;
    if (!(isBatteryOptimizationDisabled!)) await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Disable battery optimizations
    requestBatteryOptimizationDisabled();
  }

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Battery Saver',
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: Provider.of<WyzeClientProvider>(context, listen: false).logout,
                  child: Row(
                    children: const [
                      Text('Logout'),
                      SizedBox(width: 4,),
                      Icon(Icons.logout),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () async {
                    try {
                      final success = await Provider.of<WyzeClientProvider>(context, listen: false).refreshToken();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(success ? "Refreshed!" : 'An unknown error occurred'),
                      ));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Error: $e'),
                      ));
                    }
                  },
                  child: Row(
                    children: const [
                      Text('Refresh token'),
                      SizedBox(width: 4,),
                      Icon(Icons.refresh),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () async => GitHubUpdater().updateSnackBar(context, mounted, showNoUpdate: true),
                  child: Row(
                    children: const [
                      Text('Check for update'),
                      SizedBox(width: 4,),
                      Icon(Icons.update),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => launchUrlString('https://github.com/NathanKolbas/batter_saver', mode: LaunchMode.externalApplication),
                  child: const Text('GitHub'),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 8.0,),
                const Text(
                  'Options',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text.rich(
                        TextSpan(
                          text: 'Disable Battery Optimization\n',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Might be necessary on some devices',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0,),
                      TextButton(
                        onPressed: () => requestBatteryOptimizationDisabled(),
                        child: Text(isBatteryOptimizationDisabled != true ? 'Disable' : 'Already Disabled'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text.rich(
                        TextSpan(
                          text: 'Notification Settings\n',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'You can also turn off the notification here',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0,),
                      TextButton(
                        onPressed: () => fBatteryChangedPigeon.openPersistentNotificationSettings(),
                        child: const Text('Open'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4,),
                const ChargePercentagePicker(),
                const SizedBox(height: 16,),
                const Text(
                  'Devices',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Select the devices you want to switch when charge is reached\n(For now these are only plugs)',
                  style: TextStyle(fontSize: 12,),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16,),
                FutureBuilder(
                  future: Provider.of<WyzeClientProvider>(context).client.devicesList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'An error occurred: ${snapshot.error}',
                        style: const TextStyle(fontSize: 16,),
                        textAlign: TextAlign.center,
                      );
                    }
                    if (snapshot.hasData) {
                      final devices = snapshot.data;
                      if (devices == null || devices.isEmpty) {
                        return const Text(
                          'No devices found',
                          style: TextStyle(fontSize: 16,),
                          textAlign: TextAlign.center,
                        );
                      }
                      return Devices(devices: devices);
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
