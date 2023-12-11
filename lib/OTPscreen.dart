import 'dart:math';

import 'package:backcoffer_task/HomePage.dart';
import 'package:backcoffer_task/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OTPscreen extends StatefulWidget {
  String verificationid;
  OTPscreen({super.key,required this.verificationid});

  @override
  State<OTPscreen> createState() => _OTPscreenState();
}

class _OTPscreenState extends State<OTPscreen> {
  TextEditingController otpController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OTP screen"),centerTitle: true,),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter the OTP",
                suffixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25)
                )
              ),
            ),
          ),
          SizedBox(height: 30,),
          ElevatedButton(onPressed: () async{
              try{
                PhoneAuthCredential credential=await PhoneAuthProvider.credential(verificationId: widget.verificationid, smsCode: otpController.text.toString());
                FirebaseAuth.instance.signInWithCredential(credential).then((value) => {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>HomePage()))
                  
                });
              }catch(ex){
                log(ex as num);
              }
            }, child: Text("OTP Verify")
          )
        ],
      ),
    );
  }
}
