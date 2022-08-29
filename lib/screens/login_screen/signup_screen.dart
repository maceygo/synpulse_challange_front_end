// 08.23

import 'package:flutter/material.dart';
import 'package:nofire/models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key, required this.setScreen}) : super(key: key);
  final Function
      setScreen; // 注册成功时执行login()方法 进入主屏setScreen('dashboard) 不再让用户重新登录
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final themeColor = Colors.red[600];
  late Size screenSize;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  late String
      screenMode; // to define now is the phone number page or verify code page.
  late String userid;

  @override
  void initState() {
    screenMode = 'register'; // default : sign up
    super.initState();
  }

  Widget get _getPhoneWidget {
    return Stack(
      children: [
        // background
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: screenSize.width,
              height: 300,
              color: themeColor,
            ),
          ],
        ),
        // content
        Column(
          children: [
            // header
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Sign Up !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),

            // field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                width: screenSize.width,
                child: Card(
                  elevation: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Enter Mobile Number',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        width: screenSize.width * 0.6,
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(),
                          textAlign: TextAlign.center,
                          controller: _phoneNumberController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            // login option
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      goSignin();
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // submit / register
            InkWell(
              child: Container(
                alignment: Alignment.center,
                width: 250,
                height: 60,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(
                    40,
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              onTap: () {
                // submit phone number
                _verifyPhoneNumber();
              },
            ),

            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget get _getVerifyWidget {
    return Stack(
      children: [
        // background
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: screenSize.width,
              height: 300,
              color: themeColor,
            ),
          ],
        ),
        // content
        Column(
          children: [
            // header
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Sign UP !',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),

            // field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                width: screenSize.width,
                child: Card(
                  elevation: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Enter OTP',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        width: screenSize.width * 0.6,
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(),
                          textAlign: TextAlign.center,
                          controller: _otpController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // login option
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't received an OTP?",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      // 重新向手机号发送OTP
                    },
                    child: Text(
                      'Resent OTP',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),
            // submit / register
            InkWell(
              onTap: () {
                signInWithPhoneNumber();
              },
              child: Container(
                alignment: Alignment.center,
                width: 250,
                height: 60,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(
                    40,
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ],
    );
  }

  Future _verifyPhoneNumber() async {
    try {
      // 用户输入手机号并点submit后 跳转到验证码屏幕
      userid = _phoneNumberController.text;
      screenMode = 'passcode';
      setState(() {});
    } catch (e) {
      showSnackbar(
        "Failed to Verify Phone Number: $e",
      );
    }
  }

  Future signInWithPhoneNumber() async {
    // await
    // verify the OTP
    try {
      // 消息提醒
      showSnackbar("Successfully signed");
      login();
    } catch (e) {
      showSnackbar("Failed to sign in: $e");
    }
    // Navigator.pop(context);
  }

  void login() {
    // sucessfully login

    appUser = AppUser(
      id: userid,
    );
    appUser.setData('all');

    // setData('all') is only invoked when a user firstly sign up the app , init the key-value like {key="id", watchilist=[]};
    // everytime the user sign in sucessfully , invoke the getData() method.
    // everytime the user update his watchlist, (toggleFollow) , invoke  setData().

    widget.setScreen('dashboard');
  }

  void goSignin() {
    // already register before
    widget.setScreen('login');
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Container(
      child: screenMode == 'register' ? _getPhoneWidget : _getVerifyWidget,
    );
  }
}
