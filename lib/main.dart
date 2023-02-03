import 'package:flutter/material.dart';
import 'package:arp_scanner/arp_scanner.dart';
import 'package:arp_scanner/device.dart';
import 'DetailedPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wide',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
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
  bool _isScanning = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // array to add device results
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
        // _result = "${_result}total: ${devices.length}";
        _devices = devices;
      });
      // show snackbar
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Total: ${devices.length}")));
    });
    //show snackbar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () async {
              await ArpScanner.cancel();
            },
          ),
        ],
        title: Text(widget.title),
      ),
      // map the array and print each device
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ListTile(
              title: Text(_devices[index].ip.toString()),
              subtitle:
                  Text("${_devices[index].mac} ${_devices[index].vendor}"),
              tileColor: Colors.amber[700],
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DetailesPage()))
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.scanner_sharp),
          onPressed: () async {
            //scan sub net devices
            await ArpScanner.scan();
            setState(() {
              _result = "";
            });
            // add snackbar with total numbers
          }),
    );
  }
}
