import 'package:flutter/material.dart';

import '../../wyze/service/auth_service.dart';

class MfaPage extends StatefulWidget {
  final TotpCallbackType totpCallbackType;

  const MfaPage({Key? key, required this.totpCallbackType}) : super(key: key);

  @override
  State<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends State<MfaPage> {
  String mfa = '';

  String bodyText() {
    switch (widget.totpCallbackType) {
      case TotpCallbackType.mfa:
        return 'Enter the 2FA code from your Authenticator app';
      case TotpCallbackType.sms:
        return 'Enter the 2FA code sent to your phone';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        '2FA',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8,),
                      Text(
                        bodyText(),
                        style: const TextStyle(fontSize: 12,),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      TextFormField(
                        onChanged: (value) => mfa = value,
                        textAlign: TextAlign.center,
                        cursorWidth: 0,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                        ),
                        decoration: const InputDecoration(
                          hintText: '123456',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16,),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context, mfa),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}
