

import 'package:alan_voice/alan_voice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radioai/colors/ai_util.dart';
import 'package:radioai/model/model.dart' as md;
import 'package:velocity_x/velocity_x.dart';
import 'package:audioplayers/audioplayers.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<md.Radio>? radios;
  md.Radio? _SelectedRadio;
  Color? selectedColor;
  bool isPlaying = false;

  final sugg = [
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    "Play 104 FM",
    "Pause",
    "Play previous",
    "Play pop music"
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
    fetchRadios();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.PLAYING) {
        isPlaying = true;
      } else {
        isPlaying = false;
      }
      setState(() {});
    });
  }

  Playmusic(String url) {
    _audioPlayer.play(url);
    _SelectedRadio = radios!.firstWhere((element) => element.url == url);
    print(_SelectedRadio!.name);
    setState(() {});
  }

  fetchRadios() async {
    final radiojson = await rootBundle.loadString("assets/radio.json");
    radios = md.MyRadioList.fromJson(radiojson).radios;
    _SelectedRadio = radios![0];

    // print(radios);
    setState(() {});
  }

  setupAlan() {
    AlanVoice.addButton(
        "4e5a0daca36abf2922d0c357a5602cb02e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => handleCommand(command.data));
  }

  handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        Playmusic(_SelectedRadio!.url);
        break;
      case "play_channel":
        final id = response["id"];
        _audioPlayer.pause();
        md.Radio newradio = radios!.firstWhere((element) => element.id == id);
        radios!.remove(newradio);
        radios!.insert(0, newradio);
        Playmusic(newradio.url);
        break;
      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _SelectedRadio!.id;
        md.Radio newradio;
        if (index + 1 > radios!.length) {
          newradio = radios!.firstWhere((element) => element.id == 1);
          radios!.remove(newradio);
          radios!.insert(0, newradio);
        } else {
          newradio = radios!.firstWhere((element) => element.id == index + 1);
          radios!.remove(newradio);
          radios!.insert(0, newradio);
        }
        Playmusic(newradio.url);
        break;

      case "prev":
        final index = _SelectedRadio!.id;
        md.Radio newradio;
        if (index - 1 <= 0) {
          newradio = radios!.firstWhere((element) => element.id == 1);
          radios!.remove(newradio);
          radios!.insert(0, newradio);
        } else {
          newradio = radios!.firstWhere((element) => element.id == index - 1);
          radios!.remove(newradio);
          radios!.insert(0, newradio);
        }
        Playmusic(newradio.url);
        break;

      default:
        print("Command was ${response["Command"]}");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: selectedColor ?? AIColors.primaryColor2,
          child: radios != null
              ? [
                  100.heightBox,
                  "All Channels".text.xl.white.semiBold.make().px16(),
                  20.heightBox,
                  ListView(
                    padding: Vx.m0,
                    shrinkWrap: true,
                    children: radios!
                        .map((e) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.icon),
                              ),
                              title: "${e.name} FM".text.white.make(),
                              subtitle: e.tagline.text.white.make(),
                            ))
                        .toList(),
                  ).expand()
                ].vStack(crossAlignment: CrossAxisAlignment.start)
              : const Offstage(),
        ),
      ),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIColors.primaryColor1,
                    selectedColor ?? AIColors.primaryColor2,
                  ],
                  tileMode: TileMode.mirror,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
        [
            AppBar(
              title: "AI Radio".text.xl4.bold.white.make().shimmer(
                  primaryColor: Vx.purple300, secondaryColor: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p16(),
            "Start with - Hey Alan 👇".text.italic.semiBold.white.make(),
            10.heightBox,
             
            
          ].vStack(alignment: MainAxisAlignment.start),
          30.heightBox,
          radios != null
              ? VxSwiper.builder(
                  height: 300,
                  itemCount: radios!.length,
                  aspectRatio: context.mdWindowSize==MobileDeviceSize.small?2.0:context.mdWindowSize==MobileDeviceSize.medium?1.5:3.0,
                  enlargeCenterPage: true,
                  onPageChanged: (index) {
                    _SelectedRadio = radios![index];
                    final colorHex = radios![index].color;
                    selectedColor = Color(int.tryParse(colorHex)as int);
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final rad = radios![index];

                    return VxBox(
                            child: ZStack(
                      [
                        // Positioned(
                        //   top: 0.0,
                        //   right: 0.0,
                        //   child: VxBox(
                        //     child:
                        //         rad.category.text.uppercase.white.make().px16(),
                        //   )
                        //       .height(30)
                        //       .black
                        //       .alignCenter
                        //       .withRounded(value: 10.0)
                        //       .make(),
                        // ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VStack(
                            [
                              rad.name.text.xl3.white.bold.make(),
                              10.heightBox,
                              rad.tagline.text.sm.white.semiBold.make(),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                          ),
                        ),
                      Align(
                        alignment: Alignment.center,
                        child: [
                          Icon(CupertinoIcons.play_circle, color: Colors.white),
                          "Double Tap to Play".text.gray300.make(),
                        ].vStack(),
                      ),
                    ]))
                        .clip(Clip.antiAlias)
                        .bgImage(DecorationImage(
                            image: NetworkImage(rad.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.3),
                                BlendMode.darken)))
                        .withRounded(value: 60.0)
                        
                        .border(
                          color: Colors.white12,
                        )
                        .make()
                        
                        .onInkDoubleTap(() {
                      Playmusic(rad.url);
                    }).p16();
                  }).centered()
              : Center(
                  child: CircularProgressIndicator(),
                ),
          Align(
                  alignment: Alignment.bottomCenter,
                  child: [
                    if (isPlaying)
                      "Playing Now - ${_SelectedRadio!.name} FM"
                          .text
                          .white
                          .makeCentered(),
                    Icon(
                      isPlaying
                          ? CupertinoIcons.stop_circle
                          : CupertinoIcons.play_circle,
                      color: Colors.white,
                      size: 75.0,
                    ).onInkTap(() {
                      if (isPlaying) {
                        _audioPlayer.stop();
                      } else {
                        Playmusic(_SelectedRadio!.url);
                      }
                    }).shimmer(
                        primaryColor: Vx.purple300,
                        secondaryColor: Colors.white)
                  ].vStack())
              .pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
