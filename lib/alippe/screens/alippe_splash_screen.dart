import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../configs/routes.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/utils/app_orientation.dart';
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
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _cancelAndExit() async {
    _cancelled = true;
    AlippeAudio().isAlippeActive = false;
    AudioController.instance.isBalTilActive = true;
    await AlippeAudio().stopAll();
    await AppOrientation.setPortrait();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routers.home, (route) => false);
      if (AudioController.instance.isMusicEnabled && AudioController.instance.isBalTilActive) {
        AudioController.instance.playMenuMusic();
      }
    }
  }

  Future<void> _initAndNavigate() async {
    AlippeAudio().isAlippeActive = true;
    AudioController.instance.isBalTilActive = false;
    await AudioController.instance.stopAll();

    if (!mounted || _cancelled) return;
    final cubit = context.read<AlippeCubit>();
    await cubit.init();
    await AlippeAudio().init();
    if (AlippeAudio().isMusicEnabled && !_cancelled) {
      await AlippeAudio().startMusic();
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _cancelled) return;

    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _cancelAndExit();
      },
      child: const AlippeContainer(
        bgImage: AlippeAssets.splashBg,
        child: SizedBox.expand(),
      ),
    );
  }
}
