import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:midterm/models/launch_model.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  bool _pressed = false;
  Future<List<Launch>> _fetchLaunchs() async {
    final response =
        await http.get(Uri.parse("https://api.spacexdata.com/v3/missions"));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) => Launch.fromJson(json)).toList();
    } else {
      throw Exception("Failed to get data");
    }
  }

  void _onPress() {
    setState(() {
      _pressed = !_pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Space Mission"),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
            future: _fetchLaunchs(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Launch launch = snapshot.data![index];
                      return Card(
                          child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(children: [
                              Text(
                                launch.missionName.toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            ]),
                            Row(children: [
                              Expanded(
                                  child: Text(
                                launch.description.toString(),
                                softWrap: true,
                              ))
                            ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                (_pressed
                                    ? ElevatedButton.icon(
                                        onPressed: _onPress,
                                        icon: const Icon(Icons.arrow_upward),
                                        label: const Text("More"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: _onPress,
                                        icon: const Icon(Icons.arrow_downward),
                                        label: const Text("More"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey),
                                      ))
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2),
                              child: Center(
                                  child: Wrap(
                                spacing: 10,
                                children: launch.payloadIds!
                                    .map((l) => Chip(
                                          label: Text(l),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          color:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                            math.Random().nextInt(255),
                                            math.Random().nextInt(255),
                                            math.Random().nextInt(255),
                                            math.Random().nextInt(255),
                                          )),
                                        ))
                                    .toList(),
                              )),
                            )
                            // ListView.builder(
                            //     itemCount: launch.payloadIds?.length,
                            //     itemBuilder: (context, index) {
                            //       return Chip(
                            //           label: Text(launch.payloadIds![index]
                            //               .toString()));
                            //     })

                            // GridView.builder(
                            //     itemCount: launch.payloadIds?.length,
                            //     gridDelegate:
                            //         const SliverGridDelegateWithFixedCrossAxisCount(
                            //             crossAxisCount: 2),
                            //     itemBuilder: (context, index) {
                            //       return Text(launch.payloadIds![index]);
                            //     })
                          ],
                        ),
                      ));
                    });
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error"));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      )),
    );
  }
}
