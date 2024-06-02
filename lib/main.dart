import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RussianRoulette(),
    );
  }
}

class RussianRoulette extends StatefulWidget {
  const RussianRoulette({super.key});

  @override
  State<RussianRoulette> createState() => _RussianRouletteState();
}

class _RussianRouletteState extends State<RussianRoulette> {
  late List<bool> slots;
  late int deathShell;
  bool firingFlash = false;
  late int remainingBullets;
  int deathIndex = 0;

  late AssetsAudioPlayer sfx;

  @override
  void initState() {
    super.initState();
    sfx = AssetsAudioPlayer();
    emptyBullet();
    deathShell = deathShuffle();
    deathIndex = Random().nextInt(6);
  }

  emptyBullet() {
    setState(() {
      slots = List<bool>.filled(6, false);
      remainingBullets = 0;
    });
  }

  int deathShuffle() {
    Random random = Random();
    int shuffledNumber = random.nextInt(6);
    return shuffledNumber;
  }

  void shuffleSlots() {
    setState(() {
      deathShell = deathShuffle();
    });
  }

  void bang() {
    if (slots[deathIndex]) {
      sfx.open(Audio("assets/audios/desert_eagle_gunshot.mp3"));
      Vibration.vibrate(duration: 100, amplitude: 1);
      setState(() {
        firingFlash = true;
        slots[deathIndex] = false;
        remainingBullets--;
      });
      Future.delayed(const Duration(milliseconds: 150), () {
        setState(() {
          firingFlash = false;
        });
      });
    } else {
      sfx.open(Audio("assets/audios/gun_dry_firing.mp3"));
      Vibration.vibrate(duration: 10);
    }

    deathIndex = (deathIndex + 1) % slots.length;

    if (deathIndex == deathShell) {
      shuffleSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                firingFlash
                    ? Image.asset(
                        'assets/images/muzzle-flash.png',
                        height: 150,
                      )
                    : const SizedBox(
                        height: 150,
                      ),
                Image.asset(
                  'assets/images/revolver-handgun.png',
                  height: MediaQuery.of(context).size.width * 1.7,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height - 320,
                left: MediaQuery.of(context).size.width / 3),
            child: SizedBox(
              width: 90,
              height: 95,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  surfaceTintColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                onPressed: () {
                  if (remainingBullets > 0) {
                    bang();
                  } else {
                    sfx.open(Audio("assets/audios/gun_dry_firing.mp3"));
                    Vibration.vibrate(duration: 10);
                  }
                },
                child: null,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height - 350,
                left: MediaQuery.of(context).size.width / 1.68),
            child: SizedBox(
              width: 110,
              height: 120,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                    surfaceTintColor:
                        MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    sfx.open(Audio(
                        "assets/audios/revolver_chamber_spin_ratchet.mp3"));
                    shuffleSlots();
                  },
                  child: null),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200, left: 10),
            child: SizedBox(
              height: 350,
              child: Column(
                children: [
                  for (int i = 0; i < slots.length; i++) bullets(i),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: () {
          setState(() {
            emptyBullet();
            firingFlash = false;
            deathIndex = 0;
          });
        },
        icon: const Icon(Icons.refresh_rounded, size: 50),
      ),
    );
  }

  Widget bullets(int index) {
    return slots[index]
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: SizedBox(
              width: 30,
              height: 30,
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ButtonStyle(
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  surfaceTintColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                onPressed: () {
                  sfx.open(Audio("assets/audios/revolver_reload.mp3"));
                  setState(() {
                    slots[index] = true;
                    remainingBullets++;
                  });
                },
                child: Image.asset(
                  'assets/images/bullet.png',
                ),
              ),
            ),
          );
  }
}