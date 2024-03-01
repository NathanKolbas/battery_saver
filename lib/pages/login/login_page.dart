import 'package:battery_saver/components/async_button.dart';
import 'package:battery_saver/pages/mfa/mfa_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../constants.dart';
import '../../providers/wyze_client_provider.dart';
import '../../wyze/service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const kEmailNullError = 'Please enter an email';
  static const kInvalidEmailError = 'Please enter a valid email';
  static const kPassNullError = 'Please enter a password';
  static const kKeyIdNullError = 'Please enter your Key ID';
  static const kApiKeyNullError = 'Please enter your API Key';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String keyId = '';
  String apiKey = '';
  bool remember = false;
  final List<String> errors = [];

  addError(String error) {
    if (!errors.contains(error)) {
      setState(() => errors.add(error));
    }
  }

  removeError(String error) {
    if (errors.contains(error)) {
      setState(() => errors.remove(error));
    }
  }

  clearErrors() => setState(() => errors.clear());

  InputDecoration inputDecoration({
    String? labelText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<String?> mfa(TotpCallbackType totpCallbackType) async {
    return await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => MfaPage(totpCallbackType: totpCallbackType))).then((result) {
      return result is String ? result : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Text(
                        'Battery Saver',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8,),
                      Text(
                        'Sign into your Wyze account. This will allow you to pick the plugs to control. None of your sign in information is saved. Only the access token and refresh token returned by Wyze for the app to work which is stored in encrypted storage.',
                        style: TextStyle(fontSize: 12,),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 8,),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (newValue) => email = newValue ?? '',
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                removeError(kEmailNullError);
                              }
                              if (emailValidatorRegExp.hasMatch(value)) {
                                removeError(kInvalidEmailError);
                              }
                            },
                            validator: (value) {
                              if (value == null) return kEmailNullError;

                              if (value.isEmpty) {
                                return kEmailNullError;
                              } else if (!emailValidatorRegExp.hasMatch(value)) {
                                return kInvalidEmailError;
                              }
                              return null;
                            },
                            decoration: inputDecoration(
                              labelText: 'Enter your Wyze email',
                              suffixIcon: const Icon(Icons.mail_outline),
                            ),
                          ),
                          const SizedBox(height: 16,),
                          TextFormField(
                            obscureText: true,
                            onSaved: (newValue) => password = newValue ?? '',
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                removeError(kPassNullError);
                              }
                            },
                            validator: (value) {
                              if (value == null) return kPassNullError;

                              if (value.isEmpty) {
                                return kPassNullError;
                              }
                              return null;
                            },
                            decoration: inputDecoration(
                              labelText: 'Enter your Wyze password',
                              suffixIcon: const Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 25,),
                          TextButton(
                            onPressed: () => launchUrlString(
                              'https://developer-api-console.wyze.com/#/apikey/view',
                              mode: LaunchMode.externalApplication,
                            ),
                            child: const Text('Get API Key and ID'),
                          ),
                          const SizedBox(height: 4,),
                          Card(
                            clipBehavior: Clip.hardEdge,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                title: const Text('Help me get my API Key and ID'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Getting Started\n',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: 'Click on "Get API Key and ID" above. This will take you to Wyze\'s website where, once you sign-in, you can generate your API Key and ID. ',
                                            children: [
                                              TextSpan(
                                                text: 'Note: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'it might be helpful to save your API Key somewhere safe as once you leave Wyze\'s website you will no longer be able to see your API Key (your ID will still be visible). ',
                                              ),
                                              TextSpan(
                                                text: 'Once done, copy and paste both your ID and API Key into the fields below.',
                                              ),
                                            ]
                                          ),
                                          const TextSpan(
                                            text: '\n\nWhy do I need to do this?\n',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "As of July 2023, users must provide an api key and key id to create an access token. For more information, please visit ",
                                            children: [
                                              TextSpan(
                                                text: 'https://support.wyze.com/hc/en-us/articles/16129834216731',
                                                recognizer: TapGestureRecognizer()..onTap = () => launchUrlString(
                                                  'https://support.wyze.com/hc/en-us/articles/16129834216731',
                                                  mode: LaunchMode.externalApplication,
                                                ),
                                                style: TextStyle(
                                                    color: Theme.of(context).primaryColor
                                                ),
                                              ),
                                              const TextSpan(
                                                text: '.',
                                              ),
                                            ],
                                          ),
                                        ]
                                      )
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16,),
                          TextFormField(
                            obscureText: true,
                            onSaved: (newValue) => keyId = newValue ?? '',
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                removeError(kKeyIdNullError);
                              }
                            },
                            validator: (value) {
                              if (value == null) return kKeyIdNullError;

                              if (value.isEmpty) {
                                return kKeyIdNullError;
                              }
                              return null;
                            },
                            decoration: inputDecoration(
                              labelText: 'Enter your Wyze Key ID',
                              suffixIcon: const Icon(Icons.perm_identity_outlined),
                            ),
                          ),
                          const SizedBox(height: 16,),
                          TextFormField(
                            obscureText: true,
                            onSaved: (newValue) => apiKey = newValue ?? '',
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                removeError(kApiKeyNullError);
                              }
                            },
                            validator: (value) {
                              if (value == null) return kApiKeyNullError;

                              if (value.isEmpty) {
                                return kApiKeyNullError;
                              }
                              return null;
                            },
                            decoration: inputDecoration(
                              labelText: 'Enter your Wyze API Key',
                              suffixIcon: const Icon(Icons.key_rounded),
                            ),
                          ),
                          const SizedBox(height: 16,),
                          if (errors.isNotEmpty) ...[
                              Column(
                                children: List.generate(
                                    errors.length, (index) => Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 14,),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(child: Text(errors[index])),
                                  ],
                                )),
                              ),
                              const SizedBox(height: 16,),
                          ],
                          AsyncButton(
                            press: () async {
                              if (_formKey.currentState?.validate() == true) {
                                _formKey.currentState?.save();
                                clearErrors();

                                try {
                                  final success = await Provider.of<WyzeClientProvider>(context, listen: false)
                                      .login(email, password, keyId, apiKey, mfa);
                                  if (!success) addError('An unknown error occurred...');
                                } catch (e) {
                                  if (kDebugMode) print(e);
                                  addError(e.toString());
                                }
                              }
                              return false;
                            },
                            text: 'Login',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
