import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart'; //위도 경도 가져오기
import 'package:geocoding/geocoding.dart'; //위를 통해서 주고 가져오기
import 'package:permission_handler/permission_handler.dart';
import 'package:pp/notifications.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 초기화 설정
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('dddla');
  const InitializationSettings settings =
  InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(settings);

  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NativePluginWidget(),
    );
  }
}

class NativePluginWidget extends StatefulWidget {

  @override
  State<NativePluginWidget> createState() => _NativePluginWidgetState();
}

class _NativePluginWidgetState extends State<NativePluginWidget> {
  String? latitude;
  String? longitude;
  String? address;

  Future<void> getGeoData() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Permissions are denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });


      // 위도와 경도를 주소로 변환
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];

      setState(() {
        address = "${place.street}, ${place.locality}, ${place.country}";
      });
    } catch (e) {
      print('Error: $e');
    }

    try {
      PermissionStatus status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.notification.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          return Future.error('Permissions are denied');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  showNotification() async {

    var androidDetails = AndroidNotificationDetails(
      '유니크한 알림 채널 ID',
      '알림종류 설명',
      priority: Priority.high,
      importance: Importance.max,
      color: Color.fromARGB(255, 126, 131, 209),
    );

    // 알림 id, 제목, 내용 맘대로 채우기
    notifications.show(
        1,
        '제목임둥',
        '내용임둥 내 주소${address}',
        NotificationDetails(android: androidDetails)
    );
  }


  @override
  void initState() {
    super.initState();
    getGeoData();
    initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Geolocator"),),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //모두 Widget임을 알림
          children: (<Widget> [
            Text('MyLocation'),
            Text('latitude : ${latitude}'),
            Text('longitude : ${longitude}'),
            Text('address : ${address}'),
            IconButton(onPressed: () {showNotification(); print('tlqkf');}, icon: Icon(Icons.home))
          ]),
        ),
      ),
    );
  }
}
