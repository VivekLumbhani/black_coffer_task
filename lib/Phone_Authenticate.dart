import 'package:backcoffer_task/OTPscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Phone_Authentication extends StatefulWidget {
  const Phone_Authentication({Key? key}) : super(key: key);

  @override
  State<Phone_Authentication> createState() => _Phone_AuthenticationState();
}

class _Phone_AuthenticationState extends State<Phone_Authentication> {
  TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Auth"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: "Enter number",
                  suffixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24))),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.verifyPhoneNumber(
                    verificationCompleted:
                        ((PhoneAuthCredential credential) {}),
                    verificationFailed: (FirebaseAuthException ex) {},
                    codeSent: (String verificationid, int? resendtoken) {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>OTPscreen(verificationid: verificationid,)));
                    },
                    codeAutoRetrievalTimeout: (String verificationid) {},
                    phoneNumber: phoneController.text.toString());
              },
              child: Text("Verify Phone Number")),
        ],
      ),
    );
  }
}
