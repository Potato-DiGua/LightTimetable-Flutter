import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:light_timetable_flutter_app/components/select_term_dialog.dart';
import 'package:light_timetable_flutter_app/ui/college/select/select_college_page.dart';
import 'package:light_timetable_flutter_app/utils/dialog_util.dart';
import 'package:light_timetable_flutter_app/utils/http_util.dart';
import 'package:light_timetable_flutter_app/utils/shared_preferences_util.dart';
import 'package:light_timetable_flutter_app/utils/text_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollegeLoginPage extends StatefulWidget {
  @override
  _CollegeLoginPageState createState() => _CollegeLoginPageState();
}

class _CollegeLoginPageState extends State<CollegeLoginPage> {
  final GlobalKey _formKey = new GlobalKey<FormState>();
  late final TextEditingController _accountController = TextEditingController();
  late final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _randomCodeController = TextEditingController();
  Uint8List? _randomImg;
  bool _loading = true;
  bool _isLoadError = false;
  String? _collegeName;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _initAccount();

    Future.delayed(Duration.zero).then((value) {
      dynamic obj = ModalRoute.of(context)?.settings.arguments;
      if (obj["name"] is String && TextUtil.isNotEmpty(obj["name"])) {
        _collegeName = obj["name"];
      } else {
        Util.showToast("请选择学校");
        Navigator.pop(context);
      }
      _setRandomImg();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<bool> _isLogin() async {
    final resp = await HttpUtil.client.get<String>("/college/is-login");
    final data = HttpUtil.getDataFromResponse(resp.data);
    if (data is bool) {
      return false;
    } else {
      return data;
    }
  }

  void _initAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final account = prefs.getString(SharedPreferencesKey.COLLEGE_ACCOUNT);
    final pwd = prefs.getString(SharedPreferencesKey.COLLEGE_PWD);
    _accountController.text = account ?? "";
    _pwdController.text = pwd ?? "";
  }

  void _setRandomImg() async {
    setState(() {
      _loading = true;
      _isLoadError = false;
      _randomImg = null;
    });
    try {
      final resp = await HttpUtil.client.get<List<int>>("/college/random-img",
          queryParameters: {"collegeName": _collegeName},
          options: Options(responseType: ResponseType.bytes));
      if (resp.data != null) {
        setState(() {
          _loading = false;
          _isLoadError = false;
          _randomImg = Uint8List.fromList(resp.data!);
        });
        return;
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _loading = false;
      _isLoadError = true;
      _randomImg = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text("教务系统登录"),
        actions: _buildActions(),
      ),
      body: Column(
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _collegeName ?? "",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 28),
                          ),
                        ),
                        TextFormField(
                          controller: _accountController,
                          decoration: InputDecoration(
                              labelText: "账号",
                              hintText: "您的登录账号",
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.phone_iphone)),
                          validator: (v) {
                            return v == null || v.trim().isEmpty
                                ? "请输入账号"
                                : null;
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
                            return v == null || v.trim().isEmpty
                                ? "请输入账号"
                                : null;
                          },
                        ),
                        Row(
                          children: [
                            Container(
                              // color: Colors.blue,
                              width: 100,
                              child: TextFormField(
                                controller: _randomCodeController,
                                decoration: InputDecoration(
                                    labelText: "验证码",
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.code)),
                                validator: (v) {
                                  return v == null || v.trim().isEmpty
                                      ? "请输入验证码"
                                      : null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                              child: InkWell(
                                onTap: _refreshRandomCodeBtnClick,
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //     border:
                                  //         Border.all(color: Colors.black38)),
                                  width: 100,
                                  height: 34,
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Center(child: _buildRandomCode()),
                                ),
                              ),
                            )
                          ],
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
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      Center(
          child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SelectCollegePage();
                })).then((value) {
                  if (value is String && TextUtil.isNotEmpty(value)) {
                    if (value != _collegeName) {
                      setState(() {
                        _collegeName = value;
                      });
                      _setRandomImg();
                    }
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("选择学校"),
              )))
    ];
  }

  Widget _buildRandomCode() {
    if (_loading) {
      return Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(),
      );
    } else {
      if (!_isLoadError && _randomImg != null && _randomImg!.isNotEmpty) {
        return Image.memory(_randomImg!, fit: BoxFit.scaleDown,
            errorBuilder: (context, exception, stackTrace) {
          print(exception);
          return Icon(
            Icons.error,
            color: Colors.red,
          );
        });
      } else {
        return Icon(
          Icons.error,
          color: Colors.red,
        );
      }
    }
  }

  void _loginBtnOnClick() async {
    final formSate = _formKey.currentState as FormState;
    if (!formSate.validate()) {
      Util.showToast("请正确填写！");
      return;
    }
    final account = _accountController.text.trim();
    final pwd = _pwdController.text.trim();
    final randomCode = _randomCodeController.text.trim();

    Util.cancelFocus(context);
    DialogUtil.showLoadingDialog(context);
    List<String>? data;
    try {
      if (await _login(account, pwd, randomCode)) {
        SharedPreferencesUtil.savePreference(
            SharedPreferencesKey.COLLEGE_ACCOUNT, account);
        SharedPreferencesUtil.savePreference(
            SharedPreferencesKey.COLLEGE_PWD, pwd);
        data = await getTermOptionsFormInternet();
      } else {
        Util.showToast("登陆失败");
        _refreshRandomCodeBtnClick();
        return;
      }
    } catch (e) {
      Util.showToast("登录失败");
      _refreshRandomCodeBtnClick();
      print(e);
      return;
    } finally {
      //关闭加载框
      Navigator.pop(context);
    }
    if (await showSelectTermDialog(data, context) ?? false) {
      Navigator.pop(context);
    }
  }

  Future<bool> _login(String account, String pwd, String randomCode) async {
    try {
      final resp = await HttpUtil.client.post<String>("/college/login",
          data: FormData.fromMap({
            "collegeName": _collegeName,
            'account': account,
            'password': pwd,
            'randomCode': randomCode
          }));
      print(resp.data);
      final data = HttpUtil.getDataFromResponse(resp.data);
      if (data is bool) {
        return data;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  void _refreshRandomCodeBtnClick() {
    _setRandomImg();
  }
}
