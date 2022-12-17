import 'package:battery_saver/components/async_button.dart';
import 'package:battery_saver/pages/mfa/mfa_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: const [
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
                Column(
                  children: [
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
                            final success = await Provider.of<WyzeClientProvider>(context, listen: false).login(email, password, mfa);
                            if (!success) addError('An unknown error occurred...');
                          } catch (e) {
                            addError(e.toString());
                          }
                        }
                        return false;
                      },
                      text: 'Login',
                    ),
                  ],
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
