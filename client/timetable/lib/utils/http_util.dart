import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:light_timetable_flutter_app/data/token_repository.dart';
import 'package:light_timetable_flutter_app/utils/dialog_util.dart';
import 'package:light_timetable_flutter_app/utils/text_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';

class HttpUtil {
  HttpUtil._();

  static const BASE_URL = "http://192.168.50.162";

  static Dio? _client;

  static Dio get client {
    if (_client == null) {
      _client = Dio(BaseOptions(
        baseUrl: BASE_URL,
        connectTimeout: 10 * 1000,
        receiveTimeout: 3000,
        sendTimeout: 3000,
      ));
      _client!.interceptors
          .add(InterceptorsWrapper(onRequest: (options, handler) {
        String? token = TokenRepository.getInstance().token;
        if (token == null) {
          _client!.lock();
          TokenRepository.getInstance()
              .getTokenFromSharedPreferences()
              .then((value) {
            value = value.trim();
            if (value.isNotEmpty) {
              options.headers["token"] = value;
            }
            handler.next(options);
          }).catchError((e) {
            handler.reject(e);
          }).whenComplete(() => _client!.unlock());
        } else {
          options.headers["token"] = token;
          handler.next(options);
        }
      }, onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          Util.showToast("请先登录！");
        }
        handler.reject(error);
      }));
    }
    return _client!;
  }

  static dynamic getDataFromResponse(String? jsonStr,
      {bool isDialogMode = false, BuildContext? context}) {
    var resp = json.decode(jsonStr ?? "");

    if (resp["status"] == 0) {
      return resp["data"];
    } else {
      if (!TextUtil.isEmpty(resp["msg"])) {
        if (isDialogMode) {
          if (context == null) {
            throw Exception("要使用tipDialog,请设置context");
          } else {
            DialogUtil.showTipDialog(context, resp["msg"]);
          }
        } else {
          Util.showToast(resp["msg"]);
        }
      }
      return null;
    }
  }
}
