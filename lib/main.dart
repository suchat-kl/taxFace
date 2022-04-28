
import 'package:facesliptax/menu/menu.dart';
import 'package:facesliptax/dataProvider/loginDetail';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
       providers: [
        Provider<LoginDetail>(create: (_) => LoginDetail()),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          // '/':(context)=>MyLoginPage(title: 'เข้าระบบ'),
          '/menu':(context)=>Menu(title: LoginDetail().titleBar)
        },
        initialRoute: '/menu',
        title: 'ระบบงานออกใบรับรองภาษีสลิปรายบุคคล',
        theme: ThemeData(
          
          primarySwatch: Colors.green,
        ),
        // home:MyLoginPage(title: 'เข้าระบบ'),  // MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}


