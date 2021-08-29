import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:light_timetable_flutter_app/components/action_icon_button.dart';
import 'package:light_timetable_flutter_app/components/select_term_dialog.dart';
import 'package:light_timetable_flutter_app/entity/background_config.dart';
import 'package:light_timetable_flutter_app/provider/store.dart';
import 'package:light_timetable_flutter_app/ui/main/home/home_page_view_model.dart';
import 'package:light_timetable_flutter_app/ui/main/home/timetable.dart';
import 'package:light_timetable_flutter_app/ui/main/home/timetable_header.dart';
import 'package:light_timetable_flutter_app/utils/device_type.dart';
import 'package:light_timetable_flutter_app/utils/dialog_util.dart';
import 'package:light_timetable_flutter_app/utils/text_util.dart';
import 'package:light_timetable_flutter_app/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum _HomeMenu {
  SelectWeekOfTerm,
  CollegeImport,
  ShareTimetable,
  SetTime,
  SelectBgImg
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 左侧节数表头的宽度
  static const double _leftHeaderWidth = 32;

  /// 顶部星期表头的高度
  static const double _topHeaderHeight = 30;

  late final Store _store;

  late final HomePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _store = Store.getInstanceReadMode(context);
    _viewModel = HomePageViewModel(_store);

    _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final double tableWidth = screenSize.width - _leftHeaderWidth;
    final double tableCellWidth = tableWidth / 7.0;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Column(
        children: [
          AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              centerTitle: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Selector<Store, int>(
                    builder: (context, value, child) {
                      return Text("第$value周");
                    },
                    selector: (context, provider) {
                      return provider.currentWeek;
                    },
                  ),
                  Text(
                    _getDate(),
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
              leading: _buildAppbarLeading(),
              actions: _buildActions()),
          Expanded(
            child: Stack(
              children: [
                _buildBgImg(),
                Column(
                  children: [
                    DayOfWeekTableHeader(
                      height: _topHeaderHeight,
                      leftPadding: _leftHeaderWidth,
                    ),
                    Expanded(
                      flex: 1,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double tableHeight =
                              max(tableCellWidth * 12, constraints.maxHeight);
                          return _buildScrollView(tableHeight);
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _buildBgImg() {
    return SizedBox.expand(
      child: Selector<HomePageViewModel, BackgroundConfig?>(
          selector: (_, viewModel) => _viewModel.backgroundConfig,
          shouldRebuild: (oldValue, value) => true,
          builder: (context, value, child) {
            if (value == null) {
              return Container(color: Colors.white);
            }
            switch (value.type) {
              case BackgroundType.defaultBg:
                return Container(color: Colors.white);
              case BackgroundType.color:
                if (value.color != null) {
                  return Container(color: Color(value.color!));
                }
                break;
              case BackgroundType.img:
                if (TextUtil.isNotEmpty(value.imgPath)) {
                  return Image.file(
                    File(value.imgPath!),
                    fit: BoxFit.cover,
                  );
                }
                break;
            }
            return Container(color: Colors.white);
          }),
    );
  }

  Widget _buildTimetable(double height) {
    var screenSize = MediaQuery.of(context).size;
    final double tableWidth = screenSize.width - _leftHeaderWidth;
    final double tableCellWidth = tableWidth / 7.0;
    final double tableHeight = max(tableCellWidth * 12, height);

    return Timetable(width: tableWidth, height: tableHeight);
  }

  Widget? _buildAppbarLeading() {
    if (!DeviceType.isMobile) {
      return null;
    }
    return IconButton(
      splashRadius: 16,
      padding: const EdgeInsets.all(3),
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
      ),
      icon: Icon(Icons.qr_code_scanner),
      tooltip: "扫描二维码",
      onPressed: _scanQRCode,
    );
  }

  void _scanQRCode() {
    _viewModel.scanQRCodeAction(context);
  }

  List<Widget> _buildActions() {
    return <Widget>[
      ActionIconButton(
        icon: Icon(
          Icons.add,
        ),
        tooltip: "添加",
        onPressed: () {
          _viewModel.jumpToEditCoursePage(context, -1, true);
        },
      ),
      ActionIconButton(
        icon: Icon(Icons.file_download),
        tooltip: "选择学期",
        onPressed: () async {
          try {
            showSelectTermDialog(await getTermOptionsFormInternet(), context);
          } catch (e) {
            Util.showToast("获取学期信息失败");
          }
        },
      ),
      PopupMenuButton<_HomeMenu>(
        itemBuilder: (context) {
          return _buildMenu();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0.0),
          child: Icon(Icons.more_vert),
        ),
        offset: DeviceType.isAndroid ? Offset(0, 20) : Offset.zero,
        onSelected: _onSelectMenuOption,
      ),
    ];
  }

  List<PopupMenuEntry<_HomeMenu>> _buildMenu() {
    return const <PopupMenuEntry<_HomeMenu>>[
      PopupMenuItem<_HomeMenu>(
        value: _HomeMenu.SelectWeekOfTerm,
        child: Text('选择周数'),
      ),
      PopupMenuItem<_HomeMenu>(
        value: _HomeMenu.CollegeImport,
        child: Text('教务系统导入'),
      ),
      PopupMenuItem<_HomeMenu>(
        value: _HomeMenu.ShareTimetable,
        child: Text('分享'),
      ),
      PopupMenuItem<_HomeMenu>(
        value: _HomeMenu.SetTime,
        child: Text('设置时间'),
      ),
      PopupMenuItem<_HomeMenu>(
        value: _HomeMenu.SelectBgImg,
        child: Text('设置背景'),
      ),
    ];
  }

  /// 菜单选择回调
  void _onSelectMenuOption(_HomeMenu item) {
    switch (item) {
      case _HomeMenu.SelectWeekOfTerm:
        _selectWeekOfTerm();
        break;
      case _HomeMenu.CollegeImport:
        _viewModel.jumpToCollegeLoginPage(context);
        break;
      case _HomeMenu.ShareTimetable:
        _shareTimetable();
        break;
      case _HomeMenu.SetTime:
        Navigator.pushNamed(context, "setTime");
        break;
      case _HomeMenu.SelectBgImg:
        _selectBgImg();
        break;
    }
  }

  void _shareTimetable() async {
    try {
      final url = await _viewModel.shareTimetable(json.encode(_store.courses));
      if (url is String && TextUtil.isNotEmpty(url)) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("分享二维码"),
                content: Container(
                    height: 166,
                    padding: const EdgeInsets.all(3),
                    child: Center(
                      child: QrImage(
                        data: url,
                        version: QrVersions.auto,
                        size: 160,
                      ),
                    )),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("知道了")),
                ],
              );
            });
      }
    } catch (e) {
      print(e);
    }
  }

  void _selectWeekOfTerm() {
    DialogUtil.showPickerViewOneColumn(
        context: context,
        title: "选择周数",
        count: _store.maxWeekNum,
        builder: (index) {
          return Text(
            '第${index + 1}周',
            style: const TextStyle(fontSize: 12),
          );
        },
        confirmCallBack: (index) {
          _store.updateCurrentWeek(index + 1);
        },
        initIndex: _store.currentWeek - 1);
  }

  Widget _buildScrollView(double tableHeight) {
    return SingleChildScrollView(
        child: Container(
      height: tableHeight,
      child: Row(
        children: [
          ClassIndexTableHeader(width: _leftHeaderWidth),
          _buildTimetable(tableHeight),
        ],
      ),
    ));
  }

  String _getDate() {
    final now = DateTime.now();
    return "${now.year}/${now.month}/${now.day}";
  }

  /// 选择背景图片
  void _selectBgImg() async {
    await showSelectBgTypeDialog();
  }

  /// 选择背景图片的类型
  Future showSelectBgTypeDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          title: Text(
            "设置背景类型",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (DeviceType.isMobile)
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _viewModel.selectBgImgFromPhotoGallery();
                    },
                    child: Text(
                      "从相册中选择",
                      style: const TextStyle(fontSize: 16),
                    )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _viewModel.pickColorAction(context);
                  },
                  child: Text(
                    "选择纯色背景",
                    style: const TextStyle(fontSize: 16),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _viewModel.backgroundConfig.type = BackgroundType.defaultBg;
                    _viewModel.updateBgConfig();
                  },
                  child: Text(
                    "恢复默认背景",
                    style: const TextStyle(fontSize: 16),
                  )),
            ],
          ),
        );
      },
    );
  }
}
