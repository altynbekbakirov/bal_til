import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/audio/audio_controller.dart';
import '../core/alippe_audio.dart';
import '../core/alippe_constants.dart';
import '../core/alippe_cubit.dart';
import '../widgets/alippe_container.dart';

class AlippeSplashScreen extends StatefulWidget {
  const AlippeSplashScreen({super.key});

  @override
  State<AlippeSplashScreen> createState() => _AlippeSplashScreenState();
}

class _AlippeSplashScreenState extends State<AlippeSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    await AudioController.instance.stopAll();

    if (!mounted) return;
    final cubit = context.read<AlippeCubit>();
    await cubit.init();
    await AlippeAudio().init();
    if (AlippeAudio().isMusicEnabled) {
      await AlippeAudio().startMusic();
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return const AlippeContainer(
      bgImage: AlippeAssets.splashBg,
      child: SizedBox.expand(),
    );
  }
}
