import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/asset_paths.dart';

class AnthemScreen extends StatefulWidget {
  const AnthemScreen({super.key});

  @override
  State<AnthemScreen> createState() => _AnthemScreenState();
}

class _AnthemScreenState extends State<AnthemScreen> {
  final AudioController _audio = AudioController.instance;

  @override
  void initState() {
    super.initState();
    _audio.stopMenuMusic();
  }

  @override
  void dispose() {
    _audio.stopAnthem();
    _audio.playMenuMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F2),
      appBar: AppBar(
        title: const Text(
          'Мамлекеттик гимн',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () {
            _audio.playButtonClick();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                AssetPaths.coatOfArms,
                width: 140,
                height: 140,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.shield_rounded,
                  size: 100,
                  color: AppTheme.coralRed,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Кыргыз Республикасынын\nМамлекеттик Гимни',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF881337),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            // Audio Controls
            StreamBuilder<PlayerState>(
              stream: _audio.anthemPlayerStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final isPlaying = (state?.playing ?? false) &&
                    state?.processingState != ProcessingState.completed;
                return Column(
                  children: [
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _audio.playButtonClick();
                          if (isPlaying) {
                            _audio.pauseAnthem();
                          } else {
                            _audio.playAnthem();
                          }
                        },
                        icon: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 28,
                        ),
                        label: Text(
                          isPlaying ? 'Токтотуу' : 'Угуу',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPlaying ? const Color(0xFFE11D48) : AppTheme.coralRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<Duration>(
                      stream: _audio.anthemPositionStream,
                      builder: (context, posSnapshot) {
                        final position = posSnapshot.data ?? Duration.zero;
                        final total = _audio.anthemDuration ?? const Duration(seconds: 123);
                        final maxMs = total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 123000.0;
                        final curMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

                        String formatDuration(Duration d) {
                          final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
                          final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
                          return '$minutes:$seconds';
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.coralRed,
                                  inactiveTrackColor: AppTheme.coralRed.withValues(alpha: 0.2),
                                  thumbColor: AppTheme.coralRed,
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                ),
                                child: Slider(
                                  value: curMs,
                                  min: 0,
                                  max: maxMs,
                                  onChanged: (val) {
                                    _audio.seekAnthem(Duration(milliseconds: val.round()));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatDuration(position),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      formatDuration(total),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            // Lyrics Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Text(
                'Ак мөңгүлүү аска тоолор, талаалар,\n'
                'Элибиздин жаны менен барабар.\n'
                'Сансыз кылым Ала-Тоосун мекендеп,\n'
                'Сактап келди биздин ата-бабалар.\n\n'
                'Кайырма:\n'
                'Алгалай бер, кыргыз эл,\n'
                'Азаттыктын жолунда.\n'
                'Өркүндөй бер, өсө бер,\n'
                'Өз тагдырың колуңда.\n\n'
                'Байыртадан бүткөн мүнөз элиме,\n'
                'Досторуна даяр дилин берүүгө.\n'
                'Бул ынтымак эл бирдигин ширетип,\n'
                'Бейкуттукту берет кыргыз жерине.\n\n'
                'Кайырма:\n'
                'Алгалай бер, кыргыз эл,\n'
                'Азаттыктын жолунда.\n'
                'Өркүндөй бер, өсө бер,\n'
                'Өз тагдырың колуңда.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

