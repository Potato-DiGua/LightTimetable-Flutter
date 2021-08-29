import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/components/pickerview/picker_view.dart';
import 'package:light_timetable_flutter_app/components/pickerview/picker_view_popup.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';

typedef onClickCallBack = void Function();
typedef onPickerViewConfirmCallBack = void Function(int index);
typedef pickerViewItemBuilder = Widget Function(int index);

class DialogUtil {
  static void showTipDialog(BuildContext context, String tip) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            title: Text(
              "提示",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 24.0, 8, 24),
                  child: Text(
                    tip,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                Divider(height: 1.0),
                Container(
                  height: 48,
                  width: double.infinity,
                  child: TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15.0),
                            bottomRight: Radius.circular(15.0),
                          ),
                        )),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "知道了",
                      )),
                )
              ],
            ),
          );
        });
  }

  /// 当点击确定按钮时返回[DialogResult.OK],当点击取消按钮时返回[DialogResult.CANCEL]
  static Future<DialogResult?> showConfirmDialog(
      BuildContext context, String tip, onClickCallBack okBtnClick,
      {onClickCallBack? cancelBtnClick}) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text(
              "提示",
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    tip,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                Divider(height: 1.0),
                Container(
                  height: 48,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15.0)))),
                            ),
                            onPressed: () {
                              Navigator.pop(context, DialogResult.CANCEL);
                              if (cancelBtnClick != null) {
                                cancelBtnClick();
                              }
                            },
                            child: Text(
                              "取消",
                              style: TextStyle(color: Colors.black),
                            )),
                      ),
                      Container(
                        height: 48,
                        child: VerticalDivider(
                          width: 1.0,
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(15.0)))),
                            ),
                            onPressed: () {
                              Navigator.pop(context, DialogResult.OK);
                              okBtnClick();
                            },
                            child: Text("确定")),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  static void showLoadingDialog(BuildContext context, {Future? task}) {
    showDialog(
        barrierDismissible: false, // 取消点击其他区域关闭对话框功能
        context: context,
        builder: (context) {
          // 当异步任务结束关闭对话框
          task?.whenComplete(() => Navigator.pop(context));
          return AlertDialog(
            content: Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Text("加载中..."),
                    )
                  ],
                )),
          );
        });
  }

  static Future<bool?> showPickerViewOneColumn(
      {required BuildContext context,
      required String title,
      required int count,
      required pickerViewItemBuilder builder,
      required onPickerViewConfirmCallBack confirmCallBack,
      int initIndex = 0}) {
    PickerController pickerController =
        PickerController(count: 1, selectedItems: [initIndex]);

    return PickerViewPopup.showMode<bool>(
        PickerShowMode.BottomSheet, // AlertDialog or BottomSheet
        controller: pickerController,
        context: context,
        title: Text(
          title,
          style: TextStyle(fontSize: 14),
        ),
        cancel: Text(
          '取消',
          style: TextStyle(color: Colors.grey),
        ),
        confirm: Text(
          '确定',
          style: TextStyle(color: Colors.blue),
        ),
        onConfirm: (controller) {
          confirmCallBack(controller.selectedRowAt(section: 0)!);
        },
        builder: (context, popup) {
          return Container(
            height: 250,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          return count;
        },
        itemBuilder: (section, row) {
          return DefaultTextStyle(
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .merge(TextStyle(fontFamily: Util.getDesktopFontFamily())),
            child: builder(row),
          );
        });
  }
}

enum DialogResult { OK, CANCEL }
