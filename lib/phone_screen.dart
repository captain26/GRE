import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneScreen extends StatefulWidget {
  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _codeController = TextEditingController();

  String _verificationId = "";

  bool _isLoading = false;

  Future<void> _submitPhoneNumber() async {
    final phoneNumber = '+91${_phoneNumberController.text.trim()}';

    setState(() {
      _isLoading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        setState(() {
          _isLoading = false;
        });

        await FirebaseAuth.instance.signInWithCredential(credential);

        // Navigate to home screen
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to verify phone number. Please try again.'),
        ));
      },
      codeSent: (String verificationId, int ?resendToken) {
        setState(() {
          _isLoading = false;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _isLoading = false;
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _submitVerificationCode() async {
    final code = _codeController.text.trim();

    setState(() {
      _isLoading = true;
    });

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: code,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to home screen
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to verify verification code. Please try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key:_formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration:  InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
              ),
              validator: (value){
                if(value!.isEmpty){
                  return 'Phone Number is empty';
                }
                return null;
              },
            ),
            SizedBox(height: 16,),
            _verificationId ==null
            ? ElevatedButton(onPressed: _isLoading ? null : _submitPhoneNumber, child: Text('Verify Phone Number'))
            : Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    hintText: 'Enter the verification code',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Verification code cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16,),
                ElevatedButton(onPressed: _isLoading ? null : _submitVerificationCode, child: Text('Verify code'))
              ],
            )
          ],
        ),
      ),

    );
  }
}
