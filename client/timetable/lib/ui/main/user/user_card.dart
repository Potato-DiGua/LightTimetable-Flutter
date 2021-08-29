import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:light_timetable_flutter_app/components/card_view.dart';
import 'package:light_timetable_flutter_app/data/token_repository.dart';
import 'package:light_timetable_flutter_app/provider/user_provider.dart';
import 'package:light_timetable_flutter_app/ui/login/login_page.dart';
import 'package:light_timetable_flutter_app/utils/device_type.dart';
import 'package:light_timetable_flutter_app/utils/dialog_util.dart';
import 'package:light_timetable_flutter_app/utils/file_util.dart';
import 'package:light_timetable_flutter_app/utils/http_util.dart';
import 'package:light_timetable_flutter_app/utils/text_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:provider/provider.dart';

class UserCard extends StatelessWidget {
  static const double height = 80;

  static const double iconSize = 56;
  final picker = ImagePicker();
  late final BuildContext _context;
  late final UserProvider _userProvider;

  @override
  Widget build(BuildContext context) {
    _context = context;
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    return CardView(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipOval(
                child: SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: Selector<UserProvider, bool>(
                    selector: (context, provider) => provider.isLogin,
                    builder: (context, value, child) {
                      return InkWell(
                        child: Selector<UserProvider, String>(
                          selector: (context, provider) => provider.userIcon,
                          builder: (context, value, child) {
                            if (value.trim().isEmpty) {
                              return Image.asset("images/user_icon.png");
                            }
                            return FadeInImage.assetNetwork(
                              placeholder: "images/user_icon.png",
                              image: HttpUtil.BASE_URL + value,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        onTap: () {
                          if (!value) {
                            return;
                          }
                          if (DeviceType.isMobile) {
                            DialogUtil.showConfirmDialog(context, "确定要修改头像吗？",
                                () {
                              _uploadIconBtnClick();
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            Selector<UserProvider, String>(
                selector: (context, provider) => provider.name,
                builder: (context, value, child) {
                  return Text(TextUtil.isEmptyOrDefault(value, "请先登录"),
                      style: TextStyle(fontSize: 18));
                }),
            Expanded(child: Container()),
            Selector<UserProvider, bool>(
                selector: (context, provider) => provider.isLogin,
                builder: (context, value, child) {
                  if (!value) {
                    return _buildLoginButton(context);
                  } else {
                    return _buildLogOutButton(context);
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return _buildButton(context, "登录", Colors.blue, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Login();
      }));
    });
  }

  Widget _buildLogOutButton(BuildContext context) {
    return _buildButton(context, "注销", Colors.red.shade400, () {
      DialogUtil.showConfirmDialog(context, "确定要退出当前账号吗？", () {
        Util.getReadProvider<UserProvider>(context)
            .updateLoginState(false, "", "");
        TokenRepository.getInstance().clear();
      });
    });
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onClick) {
    return SizedBox(
      height: 32,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        onPressed: onClick,
        child: Text(
          text,
          style: TextStyle(
              fontSize: 13.0, fontFamily: Util.getDesktopFontFamily()),
        ),
      ),
    );
  }

  void _uploadIconBtnClick() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        return;
      }
      File? croppedFile = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          maxHeight: 300,
          maxWidth: 300,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          cropStyle: CropStyle.circle,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: '图片裁剪',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true),
          compressQuality: 100,
          compressFormat: ImageCompressFormat.png,
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      FileUtil.delete(pickedFile.path);

      String iconPath = croppedFile?.path ?? "";
      DialogUtil.showLoadingDialog(_context);
      await _uploadIcon(iconPath);
      Navigator.pop(_context);
      // FileUtil.delete(iconPath);
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _uploadIcon(String iconPath) async {
    try {
      final form = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(iconPath),
      });
      final resp =
          await HttpUtil.client.post<String>("/user/upload-icon", data: form);
      final data = HttpUtil.getDataFromResponse(resp.data);
      if (data is String && data.trim().isNotEmpty) {
        _userProvider.userIcon = data;
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
