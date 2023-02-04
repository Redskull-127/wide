import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

class DetailesPage extends StatefulWidget {
  final String ip;
  final String vendor;
  final String mac;
  final time;
  final String hostname;
  const DetailesPage(
      {super.key,
      required this.ip,
      required this.vendor,
      required this.mac,
      required this.time,
      required this.hostname});

  @override
  State<DetailesPage> createState() => _DetailesPageState(
      IP: ip, VENDOR: vendor, MAC: mac, TIME: time, HOSTNAME: hostname);
}

class _DetailesPageState extends State<DetailesPage> {
  void stillScanning(BuildContext context) {
    bool isScanning;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Scanning'),
            content: const Text('This might take a while'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }

  void searchedDone(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Vulnerable Ports'),
            content: vulnArray.isEmpty
                ? ListView(
                    shrinkWrap: true,
                    children: const [
                      Text('No Vulnerable Ports Found'),
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: vulnArray.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (vulnArray[index] == '80') {
                        return Text('${vulnArray[index]} - HTTP');
                      } else if (vulnArray[index] == '443') {
                        return Text('${vulnArray[index]} - HTTPS');
                      } else if (vulnArray[index] == '8080') {
                        return Text('${vulnArray[index]} - HTTP');
                      } else if (vulnArray[index] == '8443') {
                        return Text('${vulnArray[index]} - HTTPS');
                      } else if (vulnArray[index] == '445') {
                        return Text('${vulnArray[index]} - SMB');
                      } else if (vulnArray[index] == '139') {
                        return Text('${vulnArray[index]} - SMB');
                      } else if (vulnArray[index] == '137') {
                        return Text('${vulnArray[index]} - SMB');
                      } else if (vulnArray[index] == '53') {
                        return Text('${vulnArray[index]} - DNS');
                      } else if (vulnArray[index] == '25') {
                        return Text('${vulnArray[index]} - SMTP');
                      } else if (vulnArray[index] == '21') {
                        return Text('${vulnArray[index]} - FTP');
                      } else if (vulnArray[index] == '22') {
                        return Text('${vulnArray[index]} - SSH');
                      } else if (vulnArray[index] == '23') {
                        return Text('${vulnArray[index]} - Telnet');
                      } else if (vulnArray.isEmpty) {
                        return const Text(
                            'Your device is Secured\n No vulnerable ports found');
                      }
                    }),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }

  List<String> customArray = [
    '20',
    '21',
    '22',
    '23',
    '25',
    '53',
    '137',
    '139',
    '445',
    '80',
    '443',
    '8080',
    '8443'
  ];

  List<String> vulnArray = [];

  Future<void> pingPort(String host, int port) async {
    print('running');
    try {
      final socket = await Socket.connect(host, port);
      print('Connected to $host:$port');
      vulnArray.add(port.toString());
      await socket.close();
    } catch (e) {
      print('Failed to connect to $host:$port');
    }
  }

  num roundToHour(int minutes) {
    if (minutes < 60) {
      return minutes;
    } else {
      return (minutes / 60);
    }
  }

  final String IP;
  final String VENDOR;
  final String MAC;
  final TIME;
  final String HOSTNAME;
  _DetailesPageState(
      {required this.IP,
      required this.VENDOR,
      required this.MAC,
      required this.TIME,
      required this.HOSTNAME});
  @override
  Widget build(BuildContext context) {
    if (IP != '') {
      return Scaffold(
        appBar: AppBar(
          title: Text("$IP - $VENDOR"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                title: const Text('IP Address :'),
                subtitle: Text('$IP'),
              ),
              ListTile(
                title: const Text('Mac Address :'),
                subtitle: Text('$MAC'),
              ),
              ListTile(
                title: const Text('Connected Since :'),
                subtitle: Text('${roundToHour(TIME).toStringAsFixed(2)} Hours'),
              ),
              ListTile(
                title: const Text('Hostname :'),
                subtitle: Text('$HOSTNAME'),
              ),
              ListTile(
                title: const Text('Vendor :'),
                subtitle: Text('$VENDOR'),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          height: 60,
          width: 140,
          child: FloatingActionButton(
            onPressed: () {
              vulnArray = [];
              for (var i = 0; i < customArray.length; i++) {
                pingPort(IP, int.parse(customArray[i]));
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: const [
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 20,
                    ),
                    Text('Scanning Ports ... (Takes 10 Seconds))')
                  ]),
                  duration: Duration(seconds: 10),
                ),
              );

              Future.delayed(Duration(seconds: 10), () {
                searchedDone(context);
              });
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.wifi),
                  Text(
                    'Scan Ports',
                    style: TextStyle(fontSize: 18),
                  ),
                ]),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("$IP - $VENDOR"),
        ),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }
  }
}
