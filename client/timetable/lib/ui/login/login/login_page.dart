import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/data/token_repository.dart';
import 'package:light_timetable_flutter_app/provider/user_provider.dart';
import 'package:light_timetable_flutter_app/utils/http_util.dart';
import 'package:light_timetable_flutter_app/utils/pattern_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey _formKey = new GlobalKey<FormState>();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey, //设置globalKey，用于后面获取FormState
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _accountController,
                        decoration: InputDecoration(
                            labelText: "账号",
                            hintText: "邮箱或手机号",
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.phone_iphone)),
                        validator: (v) {
                          return PatternUtil.isAccountValid(v)
                              ? null
                              : "账号无效，请输入手机号或邮箱";
                        },
                      ),
                      TextFormField(
                        controller: _pwdController,
                        decoration: InputDecoration(
                          labelText: "密码",
                          hintText: "您的登录密码",
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.lock),
                          suffix: GestureDetector(
                            child: Icon(
                              //根据passwordVisible状态显示不同的图标
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: _passwordVisible
                                  ? Theme.of(context).primaryColor
                                  : Colors.black26,
                            ),
                            onTap: () {
                              //更新状态控制密码显示或隐藏
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_passwordVisible,
                        validator: (v) {
                          return PatternUtil.isPasswordValid(v)
                              ? null
                              : "密码不能少于6位";
                        },
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ))),
                        onPressed: _loginBtnOnClick,
                        child: Container(
                            width: double.infinity,
                            child: Center(child: Text("登录"))),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ],
    );
  }

  void _loginBtnOnClick() {
    final formSate = _formKey.currentState as FormState;
    if (!formSate.validate()) {
      Util.showToast("无效输入");
      return;
    }

    Util.cancelFocus(context);

    final account = _accountController.value.text;
    final pwd = _pwdController.value.text;

    HttpUtil.client
        .post<String>("/user/login",
            data: FormData.fromMap({"account": account, "password": pwd}))
        .then((value) {
      //{"status":0,"msg":"登录成功","data":{"id":1,"userName":"admin","account":null,"token":"3E9D701BA08B583D85879F213A4E6210"}}
      Map<String, dynamic>? map = HttpUtil.getDataFromResponse(value.data,
          isDialogMode: true, context: this.context);

      if (map != null) {
        TokenRepository.getInstance().token = map["token"];
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateLoginState(
          true,
          map["userName"],
          map["iconUrl"],
        );
        Navigator.pop(context);
      }
    }).catchError((e) {
      Util.showToast("服务器不可用");
      print(e);
    });
  }

  @override
  bool get wantKeepAlive => true;
}
