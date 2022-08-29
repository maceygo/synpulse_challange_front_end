// 08.23

import 'package:flutter/material.dart';
import 'package:nofire/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.setScreen}) : super(key: key);
  final Function
      setScreen; // 注册成功时执行login()方法 进入主屏setScreen('dashboard) 不再让用户重新登录
  @override
  State<LoginScreen> createState() => _RegistScreenState();
}

class _RegistScreenState extends State<LoginScreen> {
  final themeColor = Colors.red[600];
  late Size screenSize;
  // 登录页面是输入电话号码和验证码
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  late String screenMode; // 字符串 定义当前是输入电话号码页还是输入验证码页
  late String userid;

  @override
  void initState() {
    // 初始状态是登录 会去verify widget
    screenMode = 'login';
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
                    'Sign In !',
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
                        // 文本域 controller监听用户输入
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
                    "Don't have an account yet?",
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
                      //跳转到登录页面
                      goSignup();
                    },
                    child: Text(
                      'Sign UP',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline, //下划线
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
                // 点submit后 跳转到收验证码
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
                  'Login',
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
      userid = _phoneNumberController.text; // 将输入的手机号赋值给user_id
      screenMode = 'passcode';
      setState(() {});
    } catch (e) {
      showSnackbar(
        "Failed to Verify Phone Number: $e",
      );
    }
  }

  Future signInWithPhoneNumber() async {
    // await 验证OTP是否正确
    try {
      // 消息提醒
      showSnackbar("Successfully signed");
      login();
    } catch (e) {
      showSnackbar("Failed to sign in: $e");
    }
  }

  void login() {
    // sucessfully login , return to the dashboard screen
    appUser = AppUser(id: userid);
    appUser
        .getData(); // obatin key-value storaged in share-preference, key is user_id , value is watchlist

    widget.setScreen('dashboard');
  }

  void goSignup() {
    widget.setScreen('signup');
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
    screenSize =
        MediaQuery.of(context).size; // widget can rebuild automatically
    return Container(
      child: screenMode == 'login' ? _getPhoneWidget : _getVerifyWidget,
      //  ‘login ’ , 'passcode'
    );
  }
}
