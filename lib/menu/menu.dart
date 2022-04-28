import 'dart:convert';
import 'package:custom_input_text/custom_input_text.dart';
// import 'dart:html';
import 'package:image_downloader/image_downloader.dart';
// import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
import 'package:multilevel_drawer/multilevel_drawer.dart';
import 'package:flutter/foundation.dart';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:modern_form_esys_flutter_share/modern_form_esys_flutter_share.dart';
// import 'package:local_auth/auth_strings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info/device_info.dart';
import 'package:local_auth/local_auth.dart';
// import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:dio/dio.dart';
// import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'package:facesliptax/file_models/file_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:facesliptax/dataProvider/loginDetail';
// import 'package:facesliptax/playerWidget.dart';
// import 'package:facesliptax/local_auth_api.dart';
import 'package:facesliptax/message.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

enum SelectMenu {
  mnuNull,
  // mnuEditG,
  // mnuEditE,
  mnuCancelPhone,
  mnuCancelFingerprint,
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class Menu extends StatefulWidget {
  Menu({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final TextEditingController slipYearCtrl = TextEditingController();
  final TextEditingController taxYearCtrl = TextEditingController();
  final TextEditingController idcardCtrl = TextEditingController();
  String _message = "";
  String _path = "";
  String _size = "";
  String _mimeType = "";
  File? _imageFile;
  // int _progress = 0;
  String urlImgLogin = "";

  int itemIndex = 4;
  SelectMenu _selectMenu = SelectMenu.mnuNull;
  bool unknown = false;
  var _imageRegister, _imageLogin;
  var imagePicker;
  bool networkImg = false;

  String fileName = "";
  int fileSize = 0;
  late AudioPlayer player;
  String imgLoginTmp = "";
// String loginName="";
  String ext = "";
  String uuid = "";
  String year = "";
  String curMonth = "";
  String curYear = "";

  late PDFDocument document;

  List<FileModel> fileList = [];

  late final String path;
  String _fileUrl = "";
  String _fileName = "";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool isChecked = false;
  bool fingerPrint = false;
  bool foundPhoneId = false;
  bool foundFingerPrint = false;
  bool errPhone = true;
  var logicalWidth = 0.0;
  bool validReport = false;
  String appTitle = "";

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  // bool _isAuthenticating = false;
  // bool readyFingerPrint = false;
  static const iosStrings = const IOSAuthMessages(
      cancelButton: 'cancel',
      goToSettingsButton: 'settings',
      goToSettingsDescription: 'Please set up your Touch ID.',
      lockOut: 'Please reenable your Touch ID');
  static const androidStrings = const AndroidAuthMessages(
    cancelButton: 'ยกเลิก',
    goToSettingsButton: 'ตั้งค่า',
    goToSettingsDescription: 'กำหนดค่าสแกนลายนิ้วมือ',
    // lockOut: 'เปิดใช้งานการสแกนลายนิ้วมือ'
  );

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

/*
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason: 'Let OS determine authentication method',
          useErrorDialogs: true,
          stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }
*/
  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        // _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason: 'สแกนลายนิ้วมือเพื่อเข้าระบบ',
          useErrorDialogs: false,
          stickyAuth: true,
          biometricOnly: true,
          iOSAuthStrings: iosStrings,
          androidAuthStrings: androidStrings);

      setState(() {
        // _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        // _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  Future<bool> fingerPrintReady() async {
    //  if (_authorized == 'Authorized') return;
    await _checkBiometrics();
    if (!_canCheckBiometrics!) return false;
    await _getAvailableBiometrics();
//  if (_availableBiometrics!.contains(BiometricType.face)) {
//         // Face ID.
//       } else

    if (!_availableBiometrics!.contains(BiometricType.fingerprint)) {
      // Touch ID.
      return false;
    }

    if (_supportState != _SupportState.supported) {
      return false;
    }
    return true;
  }

/*
  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }
*/
  Future<void> popupFingerPrint() async {
    if (_authorized == 'Authorized') return;
    await _checkBiometrics();
    if (!_canCheckBiometrics!) return;
    await _getAvailableBiometrics();
//  if (_availableBiometrics!.contains(BiometricType.face)) {
//         // Face ID.
//       } else

    if (!_availableBiometrics!.contains(BiometricType.fingerprint)) {
      // Touch ID.
      return;
    }

    if (_supportState == _SupportState.supported) {
      await _authenticateWithBiometrics();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );

    player = AudioPlayer();

    var pixelRatio = window.devicePixelRatio;

    var logicalScreenSize = window.physicalSize / pixelRatio;
    logicalWidth = logicalScreenSize.width;

    imagePicker = new ImagePicker();
    DateTime now = new DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    year = formatted.split("-")[0];
    year = (int.parse(year) - 1 + 543).toString().trim(); //tax year
    curMonth = formatted.split("-")[1];
    curYear = (int.parse(year) + 1).toString().trim();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      // onSelectNotification: _onSelectNotification
    );
  }

  @override
  Widget build(BuildContext context) {
    return menu(context);
  }

  Scaffold menu(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Consumer<LoginDetail>(
          builder: (context, loginDetail, child) => MultiLevelDrawer(
                backgroundColor: Colors.white,
                rippleColor: Colors.white,
                subMenuBackgroundColor: Colors.grey.shade100,
                header: Container(
                  decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                          //Colors.yellow.shade100, Colors.green.shade100
                          colors: [
                        Colors.yellow.shade100,
                        Colors.green.shade100
                      ])),
                  // Header for Drawer
                  height: size.height * 0.25,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "assets/images/doh.jpg",
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          "สวัสดี.." + loginDetail.loginName,
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      )
                    ],
                  )),
                ),
                children: [
                  if (itemIndex == 1 &&
                      foundPhoneId &&
                      (!errPhone) &&
                      loginDetail.token != "")
                    MLMenuItem(
                        leading: itemIndex == 1
                            ? Icon(Icons.mobile_off_rounded)
                            : Text(""),
                        //  trailing: Icon(Icons.arrow_right),
                        content: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            "ยกเลิกใช้งานเครื่องนี้",
                            style: TextStyle(
                                fontSize: 16, color: Colors.blueAccent),
                          ),
                        ),
                        onClick: () {
                          setState(() {
                            _selectMenu = SelectMenu.mnuCancelPhone;
                            Navigator.pop(context);
                          });
                        }
                        /*
                  content: ListTile(
                    // contentPadding: EdgeInsets.all(0),
                    // enabled: itemIndex == 1,
                    // leading: Icon(
                    //   Icons.supervised_user_circle_rounded,
                    //   size: 40,
                    // ),
                    title: Text(
                      'ยกเลิกการใช้งานเครื่องนี้',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    // subtitle: Text(
                    //   "เปลี่ยนรหัสผ่าน",
                    //   style: TextStyle(fontSize: 16, color: Colors.black),
                    // ),
                    // tileColor: Colors.green.shade100,
                    // trailing: Icon(Icons.more_vert),
                    onTap: () {
                      setState(() {
                        _selectMenu = SelectMenu.mnuChagePassword;
                        Navigator.pop(context);
                      });
                    },
                  ),
*/
                        // subMenuItems: [
                        //   MLSubmenu(onClick: () {}, submenuContent: Text("Option 1")),
                        //   MLSubmenu(onClick: () {}, submenuContent: Text("Option 2")),
                        //   MLSubmenu(onClick: () {}, submenuContent: Text("Option 3")),
                        // ],
                        ),
                  if (itemIndex == 1 &&
                      foundFingerPrint &&
                      loginDetail.token != "")
                    MLMenuItem(
                        leading: itemIndex == 1
                            ? Icon(Icons.fingerprint_rounded)
                            : Text(""),
                        content: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            "ยกเลิกใช้งานลายนิ้วมือ",
                            style: TextStyle(
                                fontSize: 16, color: Colors.blueAccent),
                          ),
                        ),
                        onClick: () {
                          setState(() {
                            _selectMenu = SelectMenu.mnuCancelFingerprint;
                            Navigator.pop(context);
                          });
                        }),
                ],
              )),
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text(appTitle, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: <Widget>[
          Consumer<LoginDetail>(
            builder: (context, loginDetail, child) => IconButton(
                icon: Icon(Icons.exit_to_app),
                color: Colors.white,
                tooltip: "ออกจากระบบ",
                iconSize: 50,
                alignment: Alignment.center,
                onPressed: () {
                  signOut(context, loginDetail);
                }),
          )
        ],
      ),
      body: Consumer<LoginDetail>(
          builder: (context, loginDetail, child) => new FutureBuilder(
              future: this.getDocumentRep(loginDetail),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Text("");
                else if (snapshot.hasError)
                  return Text("ERROR: ${snapshot.error}");
                // else if (snapshot.connectionState == ConnectionState.waiting)
                //   return Center(child: CircularProgressIndicator());
                else
                  // return Center(child: CircularProgressIndicator());

                  return visibilityPage(loginDetail);
              })),
      bottomNavigationBar: Consumer<LoginDetail>(
        builder: (context, loginDetail, child) => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 35,
          mouseCursor: SystemMouseCursors.grab,
          selectedFontSize: 14,
          selectedIconTheme: IconThemeData(color: Colors.amberAccent, size: 35),
          selectedItemColor: Colors.amberAccent,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          backgroundColor: Colors.blueGrey,
          unselectedIconTheme: IconThemeData(
            color: Colors.deepOrange.shade50, //Accent
          ),
          unselectedItemColor: Colors.deepOrange.shade50,
          items: [
            BottomNavigationBarItem(
                label: 'ลงทะเบียน', icon: Icon(Icons.handyman_outlined)),
            BottomNavigationBarItem(
                label: 'เข้าระบบ', icon: Icon(Icons.edit_location_alt_sharp)),
            BottomNavigationBarItem(
                label: 'ภาษี', icon: Icon(Icons.print_rounded)),
            BottomNavigationBarItem(
                label: 'สลิป', icon: Icon(Icons.print_rounded)),
            BottomNavigationBarItem(
                label: 'about', icon: Icon(Icons.attribution_outlined)),
          ],
          currentIndex: itemIndex,
          onTap: (index) async {
            // manaualView = false;
            switch (index) {
              case 0:
                loginDetail.titleBar = "ลงทะเบียน";
                break;
              case 1:
                loginDetail.titleBar = "เข้าระบบ";
                await chkFingerPrint(uuid, "");
                break;
              case 2:
                loginDetail.titleBar = "ใบรับรองภาษี";
                break;
              case 3:
                loginDetail.titleBar = "สลิปเงินเดือน";
                break;
              case 4:
                loginDetail.titleBar = "รายละเอียด";
                break;
              default:
            }
            setState(() {
              networkImg = false;
              itemIndex = index;
              appTitle = loginDetail.titleBar;
              // _selectMenu = SelectMenu.mnuNull;
            });
            if (itemIndex == 1 && foundFingerPrint) {
              await popupFingerPrint();
            }
          },
        ),
      ),
    );
  }

  Widget visibilityPage(LoginDetail loginDetail) {
    int choice = 0;
    bool show = false;

    switch (this.itemIndex) {
      case 0:
        choice = 1;
        show = true;
        // networkImg = false;
        break;
      case 1:
        choice = 2;
        show = true;
        // networkImg = false;
        break;
      case 2:
        choice = 3;
        show = true;

        break;
      case 3:
        choice = 5;
        show = true;

        break;
      case 4:
        choice = 6;
        show = true;
        break;
      default:
    }

    // if (this.showPreview) {
    //   choice = 4;
    //   show = true;
    // }

    return Visibility(
      visible: show,
      child: selectMethod(choice, loginDetail),
    );
  }

  Widget selectMethod(int choice, LoginDetail loginDetail) {
    switch (choice) {
      case 1:
        return register(loginDetail);
      case 2:
        return login(loginDetail);
      case 3:
        return report(loginDetail);
      case 4:
      //return preview(loginDetail);
      case 5:
        return slip(loginDetail);
      case 6:
        return about(loginDetail);
      default:
    }

    return Text("");
  }

  Widget register(LoginDetail loginDetail) {
    return ListView(scrollDirection: Axis.vertical, children: <Widget>[
      Container(
          color: Colors.green[50],
          child: Center(
            child: Container(
                constraints:
                    BoxConstraints(maxWidth: double.infinity, minWidth: 450.0),
                // width: 450.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [
                      Colors.yellow.shade100,
                      Colors.green.shade100
                    ])),
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Form(
                  key: formKey,
                  child: Column(
                    //Image.file(image)
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildImage("ลงทะเบียน ", loginDetail),
                      showImg("register", loginDetail),
                      // buildTextFieldEmail(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildCheckBox("phone"),
                            buildTxtMsg("ใช้เฉพาะเครื่องนี้"),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildCheckBox("fingerprint"),
                            buildTxtMsg("ใช้สแกนลายนิ้วมือ"),
                          ]),
                      buildTextFieldIdcard(loginDetail),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: selectGallery("register"),
                              width: (logicalWidth / 2) - 25,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              child: selectCamera("register"),
                              width: (logicalWidth / 2) - 25,
                            ),
                          ],
                        ),
                      ),
                      buildButtonRegister(loginDetail, "register"),
                    ],
                  ),
                )),
          ))
    ]);
  }

  Widget selectCamera(String type) {
    return InkWell(
      onTap: () async {
        networkImg = false;
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          XFile image = await imagePicker.pickImage(
              source: ImageSource.camera,
              imageQuality: 50,
              maxHeight: 500.0,
              maxWidth: 400.0,
              preferredCameraDevice: CameraDevice.front);

          setState(() {
            switch (type) {
              case "register":
                _imageRegister = File(image.path);
                break;
              case "login":
                _imageLogin = File(image.path);
                break;
              default:
            }

            ext = "." + image.name.split(".")[1]; //extension file name ja
          });
        }
      },
      child: Container(
          constraints: BoxConstraints.expand(height: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.green[200],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              // combine txt
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  // TextSpan(
                  //   text: "Click ",
                  // ),
                  WidgetSpan(
                    child: Icon(Icons.camera, size: 15),
                  ),
                  TextSpan(
                    text: " กล้อง",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.all(3)),
    );
  }

  Widget selectGallery(String type) {
    return InkWell(
      onTap: () async {
        networkImg = false;
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          XFile image = await imagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 50,
              maxHeight: 500.0,
              maxWidth: 400.0,
              preferredCameraDevice: CameraDevice.front);

          setState(() {
            switch (type) {
              case "register":
                _imageRegister = File(image.path);
                break;
              case "login":
                _imageLogin = File(image.path);
                break;
              default:
            }

            ext = "." + image.name.split(".")[1]; //extension file name ja
          });
        }
      },
      child: Container(
          constraints: BoxConstraints.expand(height: 40.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.green[200],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              // combine txt
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  // TextSpan(
                  //   text: "Click ",
                  // ),
                  WidgetSpan(
                    child: Icon(Icons.image_outlined, size: 15),
                  ),

                  TextSpan(
                    text: " รูปภาพ",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  )
                ],
              ),
            ),
          ),
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.all(3)),
    );
  }

  Widget buildButtonRegister(LoginDetail loginDetail, String type) {
    String msg = "";
    switch (type) {
      case "register":
        msg = " ลงทะเบียนใบหน้า";
        break;
      case "login":
        msg = " เข้าสู่ระบบ";
        break;
      case "report":
        msg = " รายงาน";
        break;
      case "saveImg":
        msg = " บันทึกรูป(ค้นไฟล์รูปโดยใช้เลข ปชช)";
        break;
      case "cancelPhone":
        msg = " ยกเลิกการใช้งานเครื่องนี้";
        break;
      case "cancelFingerPrint":
        msg = " ยกเลิกการใช้งานลายนิ้วมือ";
        break;
      case "download":
      case "slip":
        msg = " แสดงรายงาน";
        break;
      case "manual":
        msg = "คู่มือ";
        break;
      case "share-download":
      case "share-slip":
        msg = " แชร์รายงาน";
        break;
      default:
    }
    return InkWell(
      onTap: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          if (type == "report")
            print("");
          // await processReport(loginDetail);
          else if (type == "register" || type == "login")
            await uploadFile(loginDetail, type);
          else if (type == "download" || type == "slip" || type == "manual") {
            // dwnFile=true;
            await downloadFile(loginDetail, type);
          } else if (type == "cancelPhone") {
            await cancelPhone(loginDetail);
          } else if (type == "cancelFingerPrint") {
            await cancelFingerPrint(loginDetail);
          } else if (type == "share-download" || type == "share-slip") {
            await downloadFile(loginDetail, type);
          } else if (type == "saveImg") {
            await downloadImg(loginDetail);
          }
        }
      },
      child: Container(
          constraints:
              BoxConstraints.expand(height: 40.0, width: (logicalWidth - 5)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.green[200],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              // combine txt
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: changeIcon(type),
                  ),
                  TextSpan(
                    text: msg,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.all(3)),
    );
  }

  Icon changeIcon(String type) {
    Icon icon = Icon(null);
    switch (type) {
      case "register":
        icon = Icon(Icons.app_registration, size: 15);
        break;
      case "login":
        icon = Icon(Icons.login, size: 15);
        break;
      case "report":
        icon = Icon(Icons.print, size: 15);
        break;
      case "download":
      case "slip":
        icon = Icon(Icons.preview, size: 15);
        break;
      case "cancelPhone":
        icon = Icon(
          Icons.mobile_off,
          size: 15,
        );
        break;
      case "cancelFingerPrint":
        icon = Icon(
          Icons.fingerprint,
          size: 15,
        );
        break;
      case "manual":
        icon = Icon(Icons.book_online, size: 15);
        break;
      case "share-download":
      case "share-slip":
        icon = Icon(
          Icons.share_sharp,
          size: 15,
        );
        break;
      case "saveImg":
        icon = Icon(
          Icons.save_as,
          size: 15,
        );
        break;
      default:
    }
    return icon;
  }

  void signOut(BuildContext context, LoginDetail loginDetail) {
    // Navigator.pushNamed(context, "/menu");
    // manaualView = false;
    /*
    this.itemIndex = 0;
    loginDetail.idcard = "";
    loginDetail.token = "";
    _imageRegister = null;
    _imageLogin = null;
    validReport = false;
    isChecked = false;
    networkImg = false;
    fingerPrint = false;
    foundFingerPrint=false;
*/
    if (Platform.isAndroid) {
      SystemNavigator.pop();
      // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    } else if (Platform.isIOS) {
      exit(0);
    }

    setState(() {});
    // Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(builder: (context) => MyLoginPage()),
    //     ModalRoute.withName('/'));
  }

  final formKey = GlobalKey<FormState>();

  String password = '';

  bool isNumeric(String s) {
    // if (s == null) {
    //   return false;
    // }
    return double.tryParse(s) != null;
  }

  Widget buildTextFieldIdcard(LoginDetail loginDetail) {
    idcardCtrl.text = loginDetail.idcard;
    RegExp exp;
    String msg = "";
    bool idcardValid = idcardCtrl.text.toString().length == 13 ? true : false;
    return CustomInputText(
      placeholder: 'เลขบัตรประชาชน 13 หลักติดกัน',
      icon: Icons.lock_outline_rounded,
      textController: idcardCtrl,
      isPassword: false,
      validation:
          idcardValid, // if is true, the border of input will be color green else red
      onChanged: (value) {
        if (value.toString().trim().length == 13) {
          exp = RegExp(r"^[\d]{13}$");
          idcardValid = exp.hasMatch(value.toString());
          if (idcardValid) {
            loginDetail.idcard = value.toString();
          } else
            msg = "บันทึกเลขบัตรประชาชนไม่ครบ 13 หลัก";
            print(msg);
        }
      },
    );
  }

  Container buildTextFieldIdcard123(LoginDetail loginDetail) {
    idcardCtrl.text = loginDetail.idcard;
    return Container(
        padding: EdgeInsets.all(1),
        margin: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextField(
            // initialValue: loginDetail.idcard,
            autofocus: true,
            controller: idcardCtrl,
            maxLength: 13,
            // validator: (value) =>
            //     (value.toString().length == 13) && (isNumeric(value.toString()))
            //         ? null
            //         : "ต้องบันทึกเลขบัตรประชาชน",
            // onSaved: (value) {

            //   loginDetail.idcard = value.toString();
            // },
            // keyboardType: TextInputType.number,
            // obscureText: true,
            decoration: InputDecoration(
                hintText: "เลขบัตรประชาชน",
                labelText: "เลขบัตรประชาชน",
                icon: Icon(Icons.supervised_user_circle_rounded)),
            style: TextStyle(fontSize: 16, color: Colors.black)));
  }

  Container buildImage(String title1, LoginDetail loginDetail) {
    String title2 = " จำนวน:" + loginDetail.cntregis;
    return Container(
        padding: EdgeInsets.all(3),
        margin: EdgeInsets.symmetric(vertical: 3),
        // decoration: BoxDecoration(
        //     color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: <Widget>[
            Image.asset(
              "assets/images/doh.jpg",
              height: 40,
              width: 50,
            ),
            SizedBox(
              width: 7,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      Text(title1,
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      Text(title2,
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget showImg(String type, LoginDetail loginDetail) {
    var _image;
    String imgName;
    if (unknown)
      imgName = "UNKNOWN"; // this.uuid;
    else
      imgName = loginDetail.idcard;
    String url =
        "http://dbdoh.doh.go.th:9000/files/" + imgName + ext + "?type=" + type;
    switch (type) {
      case "register":
        if (_imageRegister != null && networkImg == false) {
          _image = File(_imageRegister.path);
        } else if (networkImg) {
          // _image = networkContent;
        }
        break;
      case "login":
        if (_imageLogin != null && networkImg == false) {
          _image = File(_imageLogin.path);
        } else if (networkImg) {
          // _image = networkContent;
          urlImgLogin = url;
        }
        break;
      default:
    }

    return Container(
      width: 400.0,
      height: 150.0,
      decoration: BoxDecoration(color: Colors.blue[50]),
      child: //(_image != null && networkImg==false)
          // ? Image.memory(base64Decode(_image))
          // ?
          networkImg
              ? Image.network(url,
                  width: 400.0, height: 130.0, fit: BoxFit.fitHeight)
              : _image != null
                  ? Image.file(
                      _image,
                      width: 400.0,
                      height: 130.0,
                      fit: BoxFit.fitHeight,
                    )
                  : Container(
                      decoration: BoxDecoration(color: Colors.red[200]),
                      width: 400.0,
                      height: 50.0,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
    );
  }

  Future<void> uploadFile(LoginDetail loginDetail, String type) async {
    // Uint8List? fileBytes = result.files.first.bytes;
    // String fileName = result.files.first.name;
    // fileUpload = fileName;
    String url = "";
    unknown = false;
    //  _authenticateMe();
    if (type == "login") {
      if (foundFingerPrint && (_authorized != 'Authorized')) {
        String msg = "ต้องทำการสแกนลายนิ้วมือก่อนเข้าระบบ";
        MsgShow().showMsg(msg, TypeMsg.Warning, context);
        return;
      }
    }

    if (type == "register") {
      bool valid = await isValidIdcard(loginDetail.idcard);
      if (!valid) {
        String msg = "เลขบัตรประชาชนไม่ถูกต้อง(ข้าราชการหรือลูกจ้างประจำ)";
        MsgShow().showMsg(msg, TypeMsg.Warning, context);
        return;
      }

      url = "http://dbdoh.doh.go.th:9000/upload_regis/" +
          loginDetail.idcard +
          ext;
    } else if (type == "login") {
      loginDetail.idcard = "";
      loginDetail.token = "";
      validReport = false;
      imgLoginTmp = this.uuid + ext; //this.uuid    "imgTmp"
      url = "http://dbdoh.doh.go.th:9000/upload_login/" + imgLoginTmp;
    }

    String status = "";

    if (isChecked && type == "register") {
      status = "add";
      // print(l[0]);
      // print(l[1]);
      // print(l[2]);

    }
    if (type == "register") {
      if (await chkNotAllowUse(loginDetail, uuid, status)) return;
    }
    status = "";
    if (fingerPrint && type == "register") {
      status = "add";
      await chkFingerPrint(uuid, status);
    }

    var _image;
    switch (type) {
      case "register":
        _image = _imageRegister; // File(_imageRegister.path);
        break;
      case "login":
        _image = _imageLogin; // File(_imageLogin.path);
        break;
      default:
    }
    if (_image == null) {
      String msg = "ยังไม่ทำการเลือกรูปภาพ!";
      MsgShow().showMsg(msg, TypeMsg.Warning, context);
      return;
    }
    // await upload(
    //     fileBytes: fileSize,
    //     fileName: fileName,
    //     loginDetail: loginDetail,
    //     uploadURL: url);

    var headers = {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json;charset=UTF-8',
      "Accept": "application/json; charset=UTF-8",
      // 'Authorization': 'Bearer ' + loginDetail.getToken
    };
    // String fileName = "abc.txt";//    imageFile.path.split("/").last;
    // print(fileName);

    var request = http.MultipartRequest('POST', Uri.parse(url));
    // request.files.add(http.MultipartFile.fromPath(
    //     'file', fileName
    //     )); //
    // request.fields( http.MultipartFile.fromPath('file', fileName));
    request.files.add(await http.MultipartFile.fromPath(
      'file', _image.path,
      // contentType: new MediaType('image', imageType)
    ));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      var str = await response.stream.bytesToString();
      // print(str);
      var jsonData = json.decode(str);
      var tmp = jsonData["statusFace"].toString().trim().replaceAll("\"", "");
      String msg = "";
      // print(type);
      // print(tmp);
      // print("************************************");
      if (type == "register") {
        if (int.parse(tmp) == 1) {
          // print("Ifsuccess");

          msg = "ลงทะเบียนใบหน้าสำเร็จแล้ว";
          MsgShow().showMsg(msg, TypeMsg.Information, context);
          // await showImgSuccess(type, loginDetail);

          setState(() {
            networkImg = true;
          });
          await showName(loginDetail, type);
        } else if (int.parse(tmp) == 0) {
          // print("Ifsuccess");
          MsgShow()
              .showMsg("ไม่สามารถตรวจสอบใบหน้าได้", TypeMsg.Warning, context);
        } else if (int.parse(tmp) > 0) {
          // print("Ifsuccess");
          MsgShow()
              .showMsg("มีจำนวนใบหน้ามากกว่าหนึ่ง", TypeMsg.Warning, context);
        } else if (int.parse(tmp) == -1) {
          // print("Ifsuccess");
          MsgShow().showMsg("ไม่สามารถตรวจสอบใบหน้าที่มีการสวมหน้ากากได้",
              TypeMsg.Warning, context);
        }
      } else if (type == "login") {
        // print("number:"+tmp);
        if (tmp.length == 13) {
          // setState(() {});
          loginDetail.idcard = tmp;
          if (await chkNotAllowUse(loginDetail, uuid, status)) return;
          msg = "เข้าสู่ระบบด้วยใบหน้าสำเร็จแล้ว";
          // print(msg);
          await loginGetToken(loginDetail);

          MsgShow().showMsg(msg, TypeMsg.Information, context);
          // await showImgSuccess(type, loginDetail);

          setState(() {
            networkImg = true;
          });
          await showName(loginDetail, type);
        } else {
          msg = "ไม่สามารถเข้าระบบได้ ตรวจสอบว่าลงทะเบียนหรือยัง";
          loginDetail.idcard = "";
          validReport = false;
          loginDetail.token = "";
          MsgShow().showMsg(msg, TypeMsg.Warning, context);
          if (tmp == "UNKNOWN") {
            unknown = true;
            networkImg = true;
            setState(() {});
          }
        }

        // print(loginDetail.idcard);
      } //chk login

    } else {
      //status code
      print(response.statusCode);
      print(response.reasonPhrase);
    }
  }

  Widget login(LoginDetail loginDetail) {
    return ListView(scrollDirection: Axis.vertical, children: <Widget>[
      Container(
          color: Colors.green[50],
          child: Center(
            child: Container(
                constraints:
                    BoxConstraints(maxWidth: double.infinity, minWidth: 450.0),
                // width: 450.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [
                      Colors.yellow.shade100,
                      Colors.green.shade100
                    ])),
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Form(
                  key: formKey,
                  child: Column(
                    //Image.file(image)
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildImage("เข้าระบบ ", loginDetail),
                      showImg("login", loginDetail),
                      (Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: selectGallery("login"),
                              width: (logicalWidth / 2) - 25,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              child: selectCamera("login"),
                              width: (logicalWidth / 2) - 25,
                            ),
                          ],
                        ),
                      )),
                      buildButtonRegister(loginDetail, "login"),
                      loginDetail.token == ""
                          ? Text("")
                          : buildButtonRegister(loginDetail, "saveImg"),
/*
                      loginDetail.token == ""
                          ? Text("")
                          : foundPhoneId && (!errPhone)
                              ? buildButtonRegister(loginDetail, "cancelPhone")
                              : Text(""),
                      loginDetail.token == ""
                          ? Text("")
                          : foundFingerPrint
                              ? buildButtonRegister(
                                  loginDetail, "cancelFingerPrint")
                              : Text(""),

                              */
                      buildButtonRegister(loginDetail, "manual"),
                    ],
                  ),
                )),
          ))
    ]);
  }

  Widget report(LoginDetail loginDetail) {
    return ListView(scrollDirection: Axis.vertical, children: <Widget>[
      Container(
          color: Colors.green[50],
          child: Center(
            child: Container(
                constraints:
                    BoxConstraints(maxWidth: double.infinity, minWidth: 450.0),
                // width: 450.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [
                      Colors.yellow.shade100,
                      Colors.green.shade100
                    ])),
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Form(
                  key: formKey,
                  child: Column(
                    //Image.file(image)
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildImage("รายงานภาษี ", loginDetail),
                      buildTextFieldYear("download"),
                      validReport && loginDetail.token != ""
                          ? buildButtonRegister(loginDetail, "download")
                          : Text(""),
                      validReport && loginDetail.token != ""
                          ? buildButtonRegister(loginDetail, "share-download")
                          : Text(""),
                    ],
                  ),
                )),
          ))
    ]);
  }

  Container buildTextFieldYear(String type) {
    String yt = this.year;
    if (type == "slip") yt = curYear;

    type == "slip" ? slipYearCtrl.text = yt : taxYearCtrl.text = yt;
    return Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextFormField(
            controller: type == "slip" ? slipYearCtrl : taxYearCtrl,
            // initialValue: yt,
            maxLength: 4,
            validator: (value) =>
                (value.toString().length == 4) && (isNumeric(value.toString()))
                    ? null
                    : "ต้องบันทึกปี พ.ศ.",
            onSaved: (value) {
              yt = value.toString();
              type == "slip" ? curYear = yt : year = yt;
            },
            keyboardType: TextInputType.number,
            // obscureText: true,
            decoration: InputDecoration(
                hintText: "ปี พ.ศ.",
                labelText: "ปี พ.ศ.",
                icon: Icon(Icons.supervised_user_circle_rounded)),
            style: TextStyle(fontSize: 16, color: Colors.black)));
  }

  processReport(LoginDetail loginDetail, String mt, String yt) async {
    String url = "http://dbdoh.doh.go.th:9000/repYT/" +
        loginDetail.idcard +
        "?yt=" +
        yt +
        "&mt=" +
        mt;

    http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + loginDetail.token
      },
      // body: jsonEncode(
      //     <String, String>{"username": userName, "password": password}),
    );

    // print(response.statusCode);
    if (response.statusCode == 200) {
      MsgShow()
          .showMsg("สร้างรายงานเรียบร้อยแล้ว", TypeMsg.Information, context);

      // setState(() {
      //   this.showPreview = true;
      // });
    }
  }

  Future<void> getDocumentRep(LoginDetail loginDetail) async {
    if (logicalWidth == 0.0) {
      var pixelRatio = window.devicePixelRatio;
      var logicalScreenSize = window.physicalSize / pixelRatio;
      logicalWidth = logicalScreenSize.width;
    }
    // readyFingerPrint = await fingerPrintReady();
    await countRegister(loginDetail);
    // if (uuid==""){
    List l = await getDeviceDetails();
    uuid = l[2];

    switch (_selectMenu) {
      case SelectMenu.mnuCancelFingerprint:
        await cancelFingerPrint(loginDetail);
        _selectMenu = SelectMenu.mnuNull;
        break;
      case SelectMenu.mnuCancelPhone:
        await cancelPhone(loginDetail);
        _selectMenu = SelectMenu.mnuNull;
        break;
      default:
    }
  }

// bool dwnFile=false;
  downloadFile(LoginDetail loginDetail, String type) async {
    if (type == "manual") {
      _fileName = "slipTax.pdf";
      _fileUrl = "http://dbdoh.doh.go.th:9000/files/slipTax.pdf?type=manual";
      await _download();
      return;
    } else if (loginDetail.idcard == "" ||
        !validReport ||
        loginDetail.token == "") {
      MsgShow()
          .showMsg("ยังไม่ได้เข้าสู่ระบบด้วยใบหน้า", TypeMsg.Warning, context);
      return;
    }
    String mt = "00", yt = year;
    switch (type) {
      case "slip":
      case "share-slip":
        mt = curMonth;
        yt = curYear;
        break;
      default:
    }
    await processReport(loginDetail, mt, yt);
    if (mt == "00")
      _fileName = this.year + "-" + loginDetail.idcard + ".pdf";
    else
      _fileName = this.curYear + "-" + mt + "-" + loginDetail.idcard + ".pdf";
    _fileUrl = "http://dbdoh.doh.go.th:9000/downloadRep/" +
        loginDetail.idcard +
        "?yt=" +
        yt +
        "&mt=" +
        mt;

    if (type == "share-download" || type == "share-slip")
      await shareFileFromUrl();
    else
      await _download();
    //  dwnFile = false;
  }

  void _onSelectNotification(String? json) async {
    final obj = jsonDecode(json!);

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('${obj['error']}'),
        ),
      );
    }
  }

  // var _progress = "";
  // void _onReceiveProgress(int received, int total) {
  //   if (total != -1) {
  //     setState(() {
  //       _progress = (received / total * 100).toStringAsFixed(2) + "%";
  //       // dwnFile=true;
  //     });
  //   }
  // }

  final Dio _dio = Dio();

  Future<void> _startDownload(String savePath) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };

    try {
      final response = await _dio.download(
        _fileUrl, savePath,
        // onReceiveProgress: _onReceiveProgress
      );
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      await _showNotification(result);
      _onSelectNotification(jsonEncode(result));
    }
  }

  Future<void> shareFileFromUrl() async {
    var request = await HttpClient().getUrl(Uri.parse(_fileUrl));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file('SlipTaxDOH', _fileName, bytes, 'application/pdf');
  }

  Future<void> _download() async {
    final dir = await _getDownloadDirectory();

    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      final savePath = p.join(dir!.path, _fileName);
      await _startDownload(savePath);
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  Future<bool> _requestPermissions() async {
    //  var permission = await PermissionHandler()
    // .checkPermissionStatus(PermissionGroup.storage);
    var permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) {
      // await Permission.requestPermissions([PermissionGroup.storage]);
      permission = await Permission.storage.request();
      permission = await Permission.storage.status;
      // permission = await PermissionHandler()
      //     .checkPermissionStatus(PermissionGroup.storage);
    }

    return permission == PermissionStatus.granted;
  }

  Future<Directory?> _getDownloadDirectory() async {
    // if (Platform.isAndroid) {

    //   return await DownloadsPathProvider.downloadsDirectory;
    // }

    // in this example we are using only Android and iOS so I can assume
    // that you are not trying it for other platforms and the if statement
    // for iOS is unnecessary

    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    final android = AndroidNotificationDetails('channel id', 'channel name',
        channelDescription: 'channel description',
        priority: Priority.high,
        importance: Importance.max);
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess
            ? 'ดาวน์โหลดรายงานเสร็จแล้ว!'
            : 'มีข้อผิดพลาดในการดาวน์โหลดไฟล์.',
        platform,
        payload: json);
  }

  Container buildTextFieldPercentDownload() {
    return Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextFormField(
            initialValue: "", // _progress,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                icon: Icon(Icons.supervised_user_circle_rounded)),
            style: TextStyle(fontSize: 16, color: Colors.black)));
  }

  Future<bool> isValidIdcard(String idcard) async {
    bool valid = false;
    String url = "http://dbdoh.doh.go.th:9000/isValidIdcard/" + idcard;
    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'
      },
      // body: jsonEncode(
      //     <String, String>{"username": userName, "password": password}),
    );

    // print(response.statusCode);
    if (response.statusCode == 200) {
      var ret = jsonDecode(response.body);
      valid = ret["found"];
    }
    return valid;
  }

  Future<void> countRegister(LoginDetail loginDetail) async {
    String url = "http://dbdoh.doh.go.th:9000/cnt_regis";
    http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'
      },
      // body: jsonEncode(
      //     <String, String>{"username": userName, "password": password}),
    );

    // print(response.statusCode);
    if (response.statusCode == 200) {
      var ret = jsonDecode(response.body);
      loginDetail.cntregis = ret["count"].toString();
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.green;
  }

  buildCheckBox(String status) {
    // print(status);
    // print(readyFingerPrint);
    return Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(top: 3),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: Switch(
            // checkColor: Colors.white,
            // fillColor: MaterialStateProperty.resolveWith(getColor),
            value: status == "phone"
                ? isChecked
                : status == "fingerprint"
                    ? fingerPrint
                    : false,
            onChanged: (bool? value) {
              setState(() {
                // isChecked = value!;
                status == "phone"
                    ? isChecked = value!
                    : status == "fingerprint" //&& readyFingerPrint
                        ? fingerPrint = value!
                        : fingerPrint = false;
                // print(isChecked);
              });
            }));
  }

  buildTxtMsg(String msg) {
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
          color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child:
              Text(msg, style: TextStyle(fontSize: 16, color: Colors.black))),
    );
  }

  static Future<List<String>> getDeviceDetails() async {
    String deviceName = "";
    String deviceVersion = "";
    String identifier = "99999";
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        // if (build.isPhysicalDevice) {
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.androidId; //UUID for Android
        // }
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        // if (data.isPhysicalDevice) {
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor; //UUID for iOS
        // }
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

// if (!mounted) return[];
    return [deviceName, deviceVersion, identifier];
  }

  Future<void> loginGetToken(LoginDetail loginDetail) async {
    String url = "http://dbdoh.doh.go.th:9000/login";

    String username = "", password = "";

    final String res = await rootBundle.loadString('assets/user.json');
    final data = await json.decode(res);
    username = data["username"];
    password = data["password"];

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
          <String, String>{"username": username, "password": password}),
    );
    Map map = json.decode(response.body);

    if (response.statusCode == 200) {
      loginDetail.token = (map["accessToken"]);
    }
  }

  Future<bool> chkUuid(String idcard, String uuid, String status) async {
    bool err = false;
    String url = "http://dbdoh.doh.go.th:9000/idcardUuidIns/" +
        idcard +
        "?uuid=" +
        uuid +
        "&status=" +
        status;

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'
      },
    );
    Map map = json.decode(response.body);

    if (response.statusCode == 200) {
      foundPhoneId = map["found"];
      errPhone = map["err"];

      return (map["err"]);
    }
    return err;
  }

  Future<bool> chkNotAllowUse(
      LoginDetail loginDetail, String uuid, String status) async {
    bool err = await chkUuid(loginDetail.idcard, uuid, status);

    if (err) {
      validReport = false;
      loginDetail.token = "";
      loginDetail.idcard = "";
      String msg = "เลขบัตรประชาชนนี้ถูกใช้งานที่เครื่องอื่นแล้ว..";
      MsgShow().showMsg(msg, TypeMsg.Warning, context);
      setState(() {});
    } else
      validReport = true;
    return err;
  }

  Future<bool> cancelPhone(LoginDetail loginDetail) async {
    String url = "http://dbdoh.doh.go.th:9000/delPhone/" + loginDetail.idcard;

    http.Response response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + loginDetail.token
      },
      // body: jsonEncode(
      //     <String, String>{"username": username, "password": password}),
    );
    Map map = json.decode(response.body);

    if (response.statusCode == 200) {
      foundPhoneId = false;
      String msg = "ยกเลิกการใช้งานเฉพาะเครื่องนี้แล้ว..";
      MsgShow().showMsg(msg, TypeMsg.Information, context);
      setState(() {});
      return (map["success"]);
    }
    return false;
  }

  Container buildDropDownMonth() {
    List<DropdownMenuItem<String>> monthName = [
      DropdownMenuItem(value: "01", child: Text("มกราคม")),
      DropdownMenuItem(value: "02", child: Text("กุมภาพันธ์")),
      DropdownMenuItem(value: "03", child: Text("มีนาคม")),
      DropdownMenuItem(value: "04", child: Text("เมษายน")),
      DropdownMenuItem(value: "05", child: Text("พฤษภาคม")),
      DropdownMenuItem(value: "06", child: Text("มิถุนายน")),
      DropdownMenuItem(value: "07", child: Text("กรกฎาคม")),
      DropdownMenuItem(value: "08", child: Text("สิงหาคม")),
      DropdownMenuItem(value: "09", child: Text("กันยายน")),
      DropdownMenuItem(value: "10", child: Text("ตุลาคม")),
      DropdownMenuItem(value: "11", child: Text("พฤศจิกายน")),
      DropdownMenuItem(value: "12", child: Text("ธันวาคม")),
    ];

//loginDetail.getMonth.toString();
    return Container(
      constraints: BoxConstraints(
        minWidth: 500.0,
        maxWidth: double.infinity,
      ),
      // width: 500,
      // alignment: Alignment.center,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: new DropdownButton<String>(
        hint: Text("month"),

        focusColor: Colors.black,
        elevation: 8,
        //  autofocus: true,
        //  icon: Icon(Icons.share_arrival_time_outlined,textDirection: TextDirection.ltr,) ,

        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        value: curMonth,
        items: monthName,
        onChanged: (value) {
          setState(() {
            curMonth = value.toString();
          });
        },
      ),
    );
  }

  Widget slip(LoginDetail loginDetail) {
    return ListView(scrollDirection: Axis.vertical, children: <Widget>[
      Container(
          color: Colors.green[50],
          child: Center(
            child: Container(
                constraints:
                    BoxConstraints(maxWidth: double.infinity, minWidth: 450.0),
                // width: 450.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [
                      Colors.yellow.shade100,
                      Colors.green.shade100
                    ])),
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Form(
                  key: formKey,
                  child: Column(
                    //Image.file(image)
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildImage("รายงานสลิป ", loginDetail),

                      buildTextFieldYear("slip"),
                      buildDropDownMonth(),

                      validReport && loginDetail.token != ""
                          ? buildButtonRegister(loginDetail, "slip")
                          : Text(""),
                      validReport && loginDetail.token != ""
                          ? buildButtonRegister(loginDetail, "share-slip")
                          : Text(""),

                      // buildTextFieldPercentDownload(),
                    ],
                  ),
                )),
          ))
    ]);
  }

  Future<void> showName(LoginDetail loginDetail, String type) async {
    bool done = await findName(loginDetail, "G");
    if (!(done)) {
      await findName(loginDetail, "E");
    }

    String msg = "";
    switch (type) {
      case "register":
        msg = "ขอบคุณ" + loginDetail.loginName + "ที่ลงทะเบียนค่ะ";
        break;
      case "login":
        msg = "ยินดีต้อนรับ" + loginDetail.loginName + "เข้าระบบค่ะ";
        break;
      default:
    }
// http: //dbdoh.doh.go.th:9000/speech2Txt/3301500165001?type=register&msg="สวัสดีชาวโลก"
    String url = "http://dbdoh.doh.go.th:9000/speech2Txt/" +
        loginDetail.idcard +
        "?type=" +
        type +
        "&msg=" +
        msg;

    http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        // 'Authorization': 'Bearer ' + loginDetail.token
      },
      // body: jsonEncode(
      //     <String, String>{"username": username, "password": password}),
    );

    // Map map = json.decode(response.body);
    // print(response.statusCode);
    if (response.statusCode == 200) {
      playSound(loginDetail, type);
    }
  }

  Future<bool> findName(LoginDetail loginDetail, String type) async {
    bool done = false;
    String url = "http://dbdoh.doh.go.th:9000/dpis?idcard=" +
        loginDetail.idcard +
        "&type=" +
        type;

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        // 'Authorization': 'Bearer ' + loginDetail.token
      },
      // body: jsonEncode(
      //     <String, String>{"username": username, "password": password}),
    );
    Map map = json.decode(response.body);
    loginDetail.loginName = "";
    if (response.statusCode == 200) {
      if (map.toString() == "000")
        return false;
      else {
        loginDetail.loginName = map["name"];
        return true;
      }
    }
    return done;
  }

  Future<void> playSound(LoginDetail loginDetail, String type) async {
    _fileUrl = "http://dbdoh.doh.go.th:9000/files/" +
        type +
        loginDetail.idcard +
        ".wav?type=sound";

    await player
        .setUrl(_fileUrl); //json.decode(utf8.decode(response.bodyBytes)));
    player.setVolume(1);
    player.play();
  }

  Future<void> chkFingerPrint(String uuid, String status) async {
    // bool err = false;
    bool ready = await fingerPrintReady();
// print("-----");
// print(ready);
    if (!ready && fingerPrint) {
      String msg = "ไม่สามารถใช้งานสแกนลายนิ้วมือเครื่องนี้ได้..";
      MsgShow().showMsg(msg, TypeMsg.Warning, context);
      fingerPrint = false;
      setState(() {});
      return;
    }

    String url = "http://dbdoh.doh.go.th:9000/fingerPrintUuidIns/" +
        "?uuid=" +
        uuid +
        "&status=" +
        status;

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'
      },
    );
    Map map = json.decode(response.body);

    if (response.statusCode == 200) {
      foundFingerPrint = map["found"];
      // print(foundFingerPrint);

      // return (map["err"]);
    }
    // return err;
  }

  Future<bool> cancelFingerPrint(LoginDetail loginDetail) async {
    String url = "http://dbdoh.doh.go.th:9000/delFingerPrint/" + uuid;

    http.Response response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + loginDetail.token
      },
      // body: jsonEncode(
      //     <String, String>{"username": username, "password": password}),
    );
    Map map = json.decode(response.body);

    if (response.statusCode == 200) {
      foundFingerPrint = false;
      String msg = "ยกเลิกการใช้งานสแกนลายนิ้วมือเครื่องนี้แล้ว..";
      MsgShow().showMsg(msg, TypeMsg.Information, context);
      setState(() {});
      return (map["success"]);
    }
    return false;
  }

  Widget about(LoginDetail loginDetail) {
    return ListView(scrollDirection: Axis.vertical, children: <Widget>[
      Container(
          color: Colors.green[50],
          child: Center(
            child: Container(
                constraints:
                    BoxConstraints(maxWidth: double.infinity, minWidth: 450.0),
                // width: 450.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [
                      Colors.yellow.shade100,
                      Colors.green.shade100
                    ])),
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Form(
                  key: formKey,
                  child: Column(
                    //Image.file(image)
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildImage("รายละเอียดการใช้งานระบบ ", loginDetail),
                      buildText("about"),
                    ],
                  ),
                )),
          ))
    ]);
  }

  Container buildText(String type) {
    String msg = "";
    if (type == "about") {
      msg =
          "ระบบงานใบรับรองภาษีและสลิปเงินเดือน\nกรมทางหลวงใช้สำหรับข้าราชการและลูกจ้างประจำ\nเมื่อกดปุ่มลงทะเบียนใบหน้าต้องรอสักครู่เนื่องจากระบบ\nทำการสร้างข้อมูลไฟล์ใบหน้า";
    }

    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
          color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              "สวัสดี.." + msg,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: _launchURL,
            child: Row(
              children: [
                Icon(Icons.web),
                SizedBox(
                  width: 10,
                ),
                Text("Web salary:http://app.doh.go.th:8088/sal/"),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _launchURL2,
            child: Row(
              children: [
                Icon(Icons.mail_sharp),
                SizedBox(
                  width: 10,
                ),
                Text("Mail to:suchat.msit04@gmail.com"),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _launchURL3,
            child: Row(
              children: [
                Icon(Icons.phone_android),
                SizedBox(
                  width: 10,
                ),
                Text("Tel to:+66022063789"),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _launchURL() async {
    String url1 = "http://app.doh.go.th:8088/sal/";
    if (!await launch(url1)) throw 'Could not launch $url1';
  }

  Future<void> _launchURL2() async {
    String url1 =
        "mailto:suchat.msit04@gmail.com?subject=Send Information&body=Message";
    if (!await launch(url1)) throw 'Could not launch $url1';
  }

  Future<void> _launchURL3() async {
    String url1 = "tel:+66022063789";
    if (!await launch(url1)) throw 'Could not launch $url1';
  }

  downloadImg(LoginDetail loginDetail) {
    _downloadImage(
      urlImgLogin,
      destination: AndroidDestinationType.directoryPictures
        ..inExternalFilesDir()
        ..subDirectory(loginDetail.idcard + ext),
    );
  }

  Future<void> _downloadImage(
    String url, {
    AndroidDestinationType? destination,
    bool whenError = false,
    String? outputMimeType,
  }) async {
    String? fileName;
    String? path;
    int? size;
    String? mimeType;
    try {
      var imageId;

      if (whenError) {
        imageId = await ImageDownloader.downloadImage(url,
                outputMimeType: outputMimeType)
            .catchError((error) {
          if (error is PlatformException) {
            String? path = "";
            if (error.code == "404") {
              print("Not Found Error.");
            } else if (error.code == "unsupported_file") {
              print("UnSupported FIle Error.");
              path = error.details["unsupported_file_path"];
            }
            setState(() {
              _message = error.toString();
              _path = path ?? '';
              print(_message);
              print(_path);
            });
          }

          print(error);
        }).timeout(Duration(seconds: 10), onTimeout: () {
          print("timeout");
          return;
        });
      } else {
        if (destination == null) {
          imageId = await ImageDownloader.downloadImage(
            url,
            outputMimeType: outputMimeType,
          );
        } else {
          imageId = await ImageDownloader.downloadImage(
            url,
            destination: destination,
            outputMimeType: outputMimeType,
          );
          var path = await ImageDownloader.findPath(imageId);
          await ImageDownloader.open(path!);
        }
      }

      if (imageId == null) {
        return;
      }
      fileName = await ImageDownloader.findName(imageId);
      path = await ImageDownloader.findPath(imageId);
      size = await ImageDownloader.findByteSize(imageId);
      mimeType = await ImageDownloader.findMimeType(imageId);
    } on PlatformException catch (error) {
      setState(() {
        _message = error.message ?? '';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      var location = Platform.isAndroid ? "Directory" : "Photo Library";
      _message = 'Saved as "$fileName" in $location.\n';
      _size = 'size:     $size';
      _mimeType = 'mimeType: $mimeType';
      _path = path ?? '';
      print(_size);
      if (!_mimeType.contains("video")) {
        _imageFile = File(path!);
      }
      print(_imageFile);
      return;
    });
  }
}
