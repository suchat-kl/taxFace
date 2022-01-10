import 'dart:convert';
import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

import 'package:device_info/device_info.dart';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import 'package:facesliptax/file_models/file_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:facesliptax/dataProvider/loginDetail';

import 'package:facesliptax/message.dart';

enum SelectMenu {
  mnuNull,
  mnuEditG,
  mnuEditE,
  mnuChagePassword,
  mnuResetPassword,
}

class Menu extends StatefulWidget {
  Menu({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  // SelectMenu _selectMenu = SelectMenu.mnuNull;
  int itemIndex = 1;
  // final ImagePicker _picker = ImagePicker();
  // XFile? photo = null;
  // var size=0;
  var _imageRegister, _imageLogin;
  var imagePicker;
  String fileName = "";
  int fileSize = 0;
  // String idcard = "";
  String ext = "";
  String uuid = "";
  String year = "";
  late PDFDocument document;
  bool showPreview = false;
  List<FileModel> fileList = [];

  // late DownloaderUtils options;
  // late DownloaderCore core;
  late final String path;
  String _fileUrl = "";
  String _fileName = "";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool isChecked = false;

  bool foundPhoneId = false;

  bool validReport = false;
  @override
  void initState() {
    super.initState();

    imagePicker = new ImagePicker();
    DateTime now = new DateTime.now();
    year = (now.year - 1 + 543).toString().trim(); //tax year
    // print(year);
    super.initState();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);
// String json="";
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
    return Scaffold(
      drawer: Consumer<LoginDetail>(
        builder: (context, loginDetail, child) => Drawer(
            child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,

          children: <Widget>[
            DrawerHeader(
              child: Container(
                height: 50,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/doh.jpg",
                      height: 50,
                      width: 50,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          "สวัสดี.." + loginDetail.getDeptName,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                      colors: [Colors.yellow.shade100, Colors.green.shade100])),
            ),
            Divider(color: Colors.brown),
          ],
        )),
      ),
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
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
                  return Center(child: CircularProgressIndicator());
                else if (snapshot.hasError)
                  return Text("ERROR: ${snapshot.error}");
                else
                  return visibilityPage(loginDetail);
              })),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 35,
        mouseCursor: SystemMouseCursors.grab,
        selectedFontSize: 20,
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
              label: 'เข้าใช้งานระบบ',
              icon: Icon(Icons.edit_location_alt_sharp)),
          BottomNavigationBarItem(
              label: 'รายงาน', icon: Icon(Icons.print_rounded)),
          // BottomNavigationBarItem(
          //     label: 'ผู้ใช้งาน', icon: Icon(Icons.supervised_user_circle)),
        ],
        currentIndex: itemIndex,
        onTap: (index) {
          setState(() {
            itemIndex = index;
            // _selectMenu = SelectMenu.mnuNull;
          });
        },
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
        break;
      case 1:
        choice = 2;
        show = true;
        break;
      case 2:
        choice = 3;
        show = true;
        break;

      default:
    }

    if (this.showPreview) {
      choice = 4;
      show = true;
    }

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
                      buildImage("ลงทะเบียนด้วยใบหน้า ", loginDetail),
                      showImg("register"),
                      // buildTextFieldEmail(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildCheckBox(loginDetail),
                            buildTxtMsg("ใช้ระบบงานเฉพาะเครื่องนี้"),
                          ]),
                      buildTextFieldIdcard(loginDetail),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: selectGallery("register"),
                              width: 180,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              child: selectCamera("register"),
                              width: 180,
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
          constraints: BoxConstraints.expand(height: 50),
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
                    style: TextStyle(fontSize: 25, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.all(5)),
    );
  }

  Widget selectGallery(String type) {
    return InkWell(
      onTap: () async {
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
          constraints: BoxConstraints.expand(height: 50.0),
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
                    style: TextStyle(fontSize: 25, color: Colors.black),
                  )
                ],
              ),
            ),
          ),
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.all(5)),
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
      case "download":
        msg = " ดาวน์โหลด";
        break;
      case "cancelPhone":
        msg = " ยกเลิกการใช้งานเฉพาะเครื่องนี้";
        break;
      default:
    }
    return InkWell(
      onTap: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          if (type == "report")
            await processReport(loginDetail);
          else if (type == "register" || type == "login")
            await uploadFile(loginDetail, type);
          else if (type == "download") {
            // dwnFile=true;
            await downloadFile(loginDetail);
          } else if (type == "cancelPhone") {
            await cancelPhone(loginDetail);
          }
          // print((_image.));
        }
      },
      child: Container(
          constraints: BoxConstraints.expand(height: 50.0, width: 370.0),
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
                    style: TextStyle(fontSize: 25, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.all(5)),
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
        icon = Icon(Icons.download_rounded, size: 15);
        break;
      case "cancelPhone":
        icon = Icon(
          Icons.mobile_off,
          size: 15,
        );
        break;
      default:
    }
    return icon;
  }

  void signOut(BuildContext context, LoginDetail loginDetail) {
    // Navigator.pushNamed(context, "/menu");

    setState(() {
      this.itemIndex = 1;
      loginDetail.idcard = "";
      loginDetail.token = "";
      _imageRegister = null;
      _imageLogin = null;
      validReport = false;
      isChecked = false;
    });
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

  Container buildTextFieldIdcard(LoginDetail loginDetail) {
    return Container(
        padding: EdgeInsets.all(1),
        margin: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextFormField(
            initialValue: loginDetail.idcard,
            maxLength: 13,
            validator: (value) =>
                (value.toString().length == 13) && (isNumeric(value.toString()))
                    ? null
                    : "ต้องบันทึกเลขบัตรประชาชน",
            onSaved: (value) {
              // this.idcard = value.toString();
              loginDetail.idcard = value.toString();
            },
            keyboardType: TextInputType.number,
            // obscureText: true,
            decoration: InputDecoration(
                hintText: "เลขบัตรประชาชน",
                labelText: "เลขบัตรประชาชน",
                icon: Icon(Icons.supervised_user_circle_rounded)),
            style: TextStyle(fontSize: 25, color: Colors.black)));
  }

  Container buildImage(String title1, LoginDetail loginDetail) {
    String title2 = " จำนวนผู้ลงทะเบียน:" + loginDetail.cntregis;
    return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 5),
        // decoration: BoxDecoration(
        //     color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: <Widget>[
            Image.asset(
              "assets/images/doh.jpg",
              height: 50,
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
                          style: TextStyle(fontSize: 21, color: Colors.black)),
                      Text(title2,
                          style: TextStyle(fontSize: 21, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget showImg(String type) {
    var _image;
    switch (type) {
      case "register":
        if (_imageRegister != null) {
          _image = File(_imageRegister.path);
        }
        break;
      case "login":
        if (_imageLogin != null) {
          _image = File(_imageLogin.path);
        }
        break;
      default:
    }
    return Container(
      width: 400.0,
      height: 150.0,
      decoration: BoxDecoration(color: Colors.blue[50]),
      child: _image != null
          // ? Image.memory(base64Decode(_image))
          ? Image.file(
              _image,
              width: 400.0,
              height: 150.0,
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
    if (type == "register") {
      bool valid = await isValidIdcard(loginDetail.idcard);
      if (!valid) {
        String msg = "เลขบัตรประชาชนไม่ถูกต้อง(ข้าราชการหรือลูกจ้างประจำ)";
        MsgShow().showMsg(msg, TypeMsg.Warning, context);
        return;
      }

      url =
          "http://dbdoh.doh.go.th:443/upload_regis/" + loginDetail.idcard + ext;
    } else if (type == "login") {
      url =
          "http://dbdoh.doh.go.th:443/upload_login/" + loginDetail.idcard + ext;
    }

    String status = "";

    if (isChecked && type == "register") {
      status = "add";
      // print(l[0]);
      // print(l[1]);
      // print(l[2]);

    }
    if (type == "register") {
      if (await chkAllowUse(loginDetail, uuid, status)) return;
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

    if (response.statusCode == 200) {
      var str = await response.stream.bytesToString();
      print(str);
      var jsonData = json.decode(str);
      var tmp = jsonData["statusFace"].toString().trim().replaceAll("\"", "");
      String msg = "";

      if (type == "register") {
        if (int.parse(tmp) == 1) {
          // print("Ifsuccess");

          msg = "ลงทะเบียนใบหน้าสำเร็จแล้ว";

          MsgShow().showMsg(msg, TypeMsg.Information, context);
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
        if (tmp.length == 13) {
          await loginGetToken(loginDetail);
          setState(() {});
          msg = "เข้าสู่ระบบด้วยใบหน้าสำเร็จแล้ว";
          loginDetail.idcard = tmp;
          if (await chkAllowUse(loginDetail, uuid, status)) return;
          MsgShow().showMsg(msg, TypeMsg.Information, context);
        } else {
          msg = "ไม่สามารถเข้าระบบได้ ตรวจสอบว่าลงทะเบียนหรือยัง";
          loginDetail.idcard = "";
          MsgShow().showMsg(msg, TypeMsg.Warning, context);
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
                      buildImage("เข้าระบบด้วยใบหน้า ", loginDetail),
                      showImg("login"),
                      // buildTextFieldEmail(),
                      // buildTextFieldPassword(),
                      // selectGallery("login"),
                      // selectCamera("login"),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: selectGallery("login"),
                              width: 180,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              child: selectCamera("login"),
                              width: 180,
                            ),
                          ],
                        ),
                      ),
                      buildButtonRegister(loginDetail, "login"),
                      loginDetail.token == ""
                          ? Text("")
                          : foundPhoneId
                              ? buildButtonRegister(loginDetail, "cancelPhone")
                              : Text(""),
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
                      buildImage("ระบบใบรับรองภาษี ", loginDetail),
                      // showImg("report"),
                      // buildTextFieldEmail(),
                      buildTextFieldYear(),
                      // selectGallery("login"),
                      // selectCamera("login"),
                      // buildButtonRegister(loginDetail, "report"),
                      validReport && loginDetail.token != ""
                          ? buildButtonRegister(loginDetail, "download")
                          : Text("")
                      // buildTextFieldPercentDownload(),
                    ],
                  ),
                )),
          ))
    ]);
  }

  Container buildTextFieldYear() {
    return Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextFormField(
            initialValue: year,
            maxLength: 4,
            
            validator: (value) =>
                (value.toString().length == 4) && (isNumeric(value.toString()))
                    ? null
                    : "ต้องบันทึกปี พ.ศ.",
            onSaved: (value) => this.year = value.toString(),
            keyboardType: TextInputType.number,
            // obscureText: true,
            decoration: InputDecoration(
                hintText: "ปี พ.ศ.",
                labelText: "ปี พ.ศ.",
                icon: Icon(Icons.supervised_user_circle_rounded)),
            style: TextStyle(fontSize: 25, color: Colors.black)));
  }

  processReport(LoginDetail loginDetail) async {
    String url = "http://dbdoh.doh.go.th:443/repYT/" +
        loginDetail.idcard +
        "?yt=" +
        this.year;

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
    await countRegister(loginDetail);
    List l = await getDeviceDetails();
    uuid = l[2];
    await chkUuid(loginDetail.idcard, uuid, "");
    // setState(() {

    // });
    // if (!this.showPreview) return;
    // document = await PDFDocument.fromURL(
    //   "http://dbdoh.doh.go.th:443/downloadRep/" + loginDetail.idcard,
    // );
    // print(document);
  }

// bool dwnFile=false;
  downloadFile(LoginDetail loginDetail) async {
    if (loginDetail.idcard == "" || !validReport || loginDetail.token == "") {
      MsgShow()
          .showMsg("ยังไม่ได้เข้าสู่ระบบด้วยใบหน้า", TypeMsg.Warning, context);
      return;
    }
    await processReport(loginDetail);
    _fileName = this.year + "-" + loginDetail.idcard + ".pdf";
    _fileUrl = "http://dbdoh.doh.go.th:443/downloadRep/" +
        loginDetail.idcard +
        "?yt=" +
        this.year;

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

  var _progress = "";
  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(2) + "%";
        // dwnFile=true;
      });
    }
  }

  final Dio _dio = Dio();

  Future<void> _startDownload(String savePath) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };

    try {
      final response = await _dio.download(_fileUrl, savePath,
          onReceiveProgress: _onReceiveProgress);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      await _showNotification(result);
      _onSelectNotification(jsonEncode(result));
      print(result['isSuccess']);
      print(result['filePath']);
    }
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
    // var permission = await PermissionHandler()
    //     .checkPermissionStatus(PermissionGroup.storage);
    var permission = await Permission.storage.request().isGranted;

    return permission;
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }

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
            initialValue: _progress,
            
            keyboardType: TextInputType.text,
          
            decoration: InputDecoration(
               
                icon: Icon(Icons.supervised_user_circle_rounded)),
            style: TextStyle(fontSize: 18, color: Colors.black)));
  }

  Future<bool> isValidIdcard(String idcard) async {
    bool valid = false;
    String url = "http://dbdoh.doh.go.th:443/isValidIdcard/" + idcard;
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
    String url = "http://dbdoh.doh.go.th:443/cnt_regis";
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

  buildCheckBox(LoginDetail loginDetail) {
    return Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: Checkbox(
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.resolveWith(getColor),
            value: isChecked,
            onChanged: (bool? value) {
              setState(() {
                isChecked = value!;
                // print(isChecked);
              });
            }));
  }

  buildTxtMsg(String msg) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
          color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child:
              Text(msg, style: TextStyle(fontSize: 25, color: Colors.black))),
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
    String url = "http://dbdoh.doh.go.th:443/login";
    
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
    String url = "http://dbdoh.doh.go.th:443/idcardUuidIns/" +
        idcard +
        "?uuid=" +
        uuid +
        "&status=" +
        status;
    // print(url);
    // String username = "gdbf-7ho9yh'vp^jfy[wx", password = "suchat@doh";
    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'
      },
      // body: jsonEncode(
      //     <String, String>{"username": username, "password": password}),
    );
    Map map = json.decode(response.body);
    // print(response.statusCode);
    // print(map["err"]);
    if (response.statusCode == 200) {
      foundPhoneId = map["found"];
      // print("******");
      // print(foundPhoneId);
      return (map["err"]);
    }
    return err;
  }

  Future<bool> chkAllowUse(
      LoginDetail loginDetail, String uuid, String status) async {
    bool err = await chkUuid(loginDetail.idcard, uuid, status);
// print(loginDetail.idcard);
// print(uuid);
// print(status);
// print(err);
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
    String url = "http://dbdoh.doh.go.th:443/delPhone/" + loginDetail.idcard;
    // print(url);
    // String username = "gdbf-7ho9yh'vp^jfy[wx", password = "suchat@doh";
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
    // print(response.statusCode);
    // print(map["err"]);
    if (response.statusCode == 200) {
      // foundPhoneId = map["found"];
      // print("******");
      // print(foundPhoneId);
      foundPhoneId = false;
      String msg = "ยกเลิกการใช้งานเฉพาะเครื่องนี้แล้ว..";
      MsgShow().showMsg(msg, TypeMsg.Information, context);
      setState(() {});
      return (map["success"]);
    }
    return false;
  }
}
