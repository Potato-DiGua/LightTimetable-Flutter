import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/ui/login/login_page.dart';
import 'package:light_timetable_flutter_app/utils/dialog_util.dart';
import 'package:light_timetable_flutter_app/utils/event_bus_util.dart';
import 'package:light_timetable_flutter_app/utils/http_util.dart';
import 'package:light_timetable_flutter_app/utils/pattern_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey _formKey = new GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _pwdController = TextEditingController();

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
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText: "昵称",
                            hintText: "您的昵称",
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person)),
                        validator: (v) {
                          return PatternUtil.isUserNameValid(v)
                              ? null
                              : "昵称不能少于3位";
                        },
                      ),
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
                            prefixIcon: Icon(Icons.lock)),
                        validator: (v) {
                          return PatternUtil.isPasswordValid(v)
                              ? null
                              : "密码不能少于6位";
                        },
                        obscureText: true,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ))),
                        onPressed: _registerOnClick,
                        child: Container(
                            width: double.infinity,
                            child: Center(child: Text("注册"))),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ],
    );
  }

  void _registerOnClick() {
    if (!(_formKey.currentState as FormState).validate()) {
      Util.showToast("无效输入");
      return;
    }
    Util.cancelFocus(context);

    final name = _nameController.value.text.trim();
    final account = _accountController.value.text.trim();
    final pwd = _pwdController.value.text;

    HttpUtil.client
        .post<String>("/user/register",
            data: FormData.fromMap(
                {"name": name, "account": account, "password": pwd}))
        .then((value) {
      final data = json.decode(value.data ?? "");
      if (data != null) {
        if (data["status"] == 0) {
          Util.showToast("注册成功");
          EventBusUtil.getInstance().fire(TabSwitchEvent(0));
        } else {
          DialogUtil.showTipDialog(this.context, data["msg"] ?? "注册失败");
        }
      }
    }).catchError((e) {
      Util.showToast("服务器不可用");
      print(e);
    });
  }

  @override
  bool get wantKeepAlive => true;
}
