import 'dart:io';
import 'package:flutter/material.dart';
import 'package:arp_scanner/arp_scanner.dart';
import 'package:arp_scanner/device.dart';
import 'DetailedPage.dart';
import 'package:http/http.dart' as http;
import 'AllowBadCRT.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wide',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const MyHomePage(title: 'Wide'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = '';
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Device> _devices = [];
  @override
  void initState() {
    super.initState();
    print(_result);
    ArpScanner.onScanning.listen((Device device) {
      setState(() {
        _result =
            "${_result}Mac:${device.mac} ip:${device.ip} hostname:${device.hostname} time:${device.time} vendor:${device.vendor} \n";
      });
    });
    ArpScanner.onScanFinished.listen((List<Device> devices) {
      setState(() {
        _devices = devices;
      });
      // show snackbar
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Total: ${devices.length}")));
    });
    //show snackbar
  }

  Future<http.Response> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://api.quotable.io/random?tags=technology&maxLength=35'));
    return response;
  }

  @override
  Widget build(BuildContext context) {
    if (_result != '' && _result != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'All Devices',
            style: TextStyle(height: 20),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text(
                'Total: ${_devices.length}',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            )
          ],
        ),
        // map the array and print each device
        body: _devices.length > 0
            ? ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ListTile(
                      title: Text(
                        _devices[index].ip.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "${_devices[index].mac} ${_devices[index].vendor}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      tileColor: Colors.purple[900],
                      //add icon
                      leading: const Icon(
                        Icons.devices,
                        color: Colors.white,
                      ),
                      //add icon at end
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailesPage(
                                    ip: _devices[index].ip.toString(),
                                    mac: _devices[index].mac.toString(),
                                    vendor: _devices[index].vendor.toString(),
                                    time: _devices[index].time.toInt(),
                                    hostname:
                                        _devices[index].hostname.toString())))
                      },
                    ),
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator.adaptive(),
              ),

        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.grey[500],
            onPressed: () async {
              //scan sub net devices
              await ArpScanner.scan();
              setState(() {
                _result = "";
              });
              // add snackbar with total numbers
            },
            child: const Icon(Icons.refresh)),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
            toolbarHeight: 127,
            centerTitle: true,
            title: Image.asset('assets/Logo/logo.png', height: 143)),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // const Text(
            //   'Welcome to Wide',
            //   style: TextStyle(
            //     fontSize: 30,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(height: 50),
            const Text('Top things to do here!',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Connect to WiFi'),
              subtitle: const Text('For scanning all devices in your network'),
              tileColor: Colors.purple[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text('Click the button below'),
              subtitle: const Text('It will scan all your devices'),
              tileColor: Colors.purple[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text('Search for vulnerable ports'),
              subtitle: const Text('I will make it sure you :)'),
              tileColor: Colors.purple[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            ListTile(
              title: const Text('Take Immediate Actions'),
              subtitle: const Text(
                  'if you find any vulnerable ports or any unknown device, Take immediate actions'),
              tileColor: Colors.purple[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        )),
        floatingActionButton: Container(
          height: 60,
          width: 140,
          child: FloatingActionButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [Icon(Icons.wifi), Text('Scan Devices')]),
              onPressed: () async {
                await ArpScanner.scan();
                setState(() {
                  _result = "";
                });
                // add snackbar with total numbers
              }),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
  }
}
