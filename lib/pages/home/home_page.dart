import 'package:battery_saver/helpers/updater.dart';
import 'package:battery_saver/pages/home/components/devices.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../providers/wyze_client_provider.dart';
import 'components/charge_percentage_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                const Text(
                  'Options',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Set what percentage to turn off the plug(s)',
                  style: TextStyle(fontSize: 12,),
                  textAlign: TextAlign.center,
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
