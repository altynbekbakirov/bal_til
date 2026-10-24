import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_orientation.dart';
import '../../../core/utils/asset_paths.dart';
import '../../../alippe/core/alippe_constants.dart';
import '../widgets/region_detail_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapRepository _repository = MapRepository();
  late List<RegionModel> _regions;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    _regions = _repository.getRegions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeAnimation == null) {
      final modalRoute = ModalRoute.of(context);
      _routeAnimation = modalRoute?.animation;
      if (_routeAnimation != null) {
        if (_routeAnimation!.isCompleted) {
          _engageLandscape();
        } else {
          _routeAnimation!.addStatusListener(_onRouteAnimationStatus);
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _engageLandscape();
        });
      }
    }
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
      _engageLandscape();
    }
  }

  void _engageLandscape() {
    if (!mounted) return;
    AppOrientation.forceLandscape();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _exitScreen() async {
    AudioController.instance.playButtonClick();
    await AppOrientation.forcePortrait();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Give device a frame to rotate before popping
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatus);
    AppOrientation.forcePortrait();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onRegionSelected(RegionModel region) {
    AudioController.instance.playButtonClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RegionDetailSheet(region: region),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitScreen();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: SafeArea(
          child: Stack(
            children: [
              // Interactive Landscape Map filling available space
              Positioned.fill(
                child: Center(
                  child: InteractiveViewer(
                    maxScale: 3.5,
                    minScale: 0.8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: AspectRatio(
                        aspectRatio: 1115 / 668,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Clean Map image background
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      AssetPaths.mapImage,
                                      fit: BoxFit.fill,
                                      errorBuilder: (_, _, _) => Container(
                                        color: Colors.blue.shade50,
                                        child: const Center(
                                          child: Icon(Icons.map, size: 80, color: Colors.blue),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Region interactive pins
                                ..._regions.map((region) {
                                  return Positioned(
                                    left: region.x * constraints.maxWidth,
                                    top: region.y * constraints.maxHeight,
                                    child: FractionalTranslation(
                                      translation: const Offset(-0.5, -0.5),
                                      child: GestureDetector(
                                        onTap: () => _onRegionSelected(region),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppTheme.coralRed,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.25),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                              BoxShadow(
                                                color: AppTheme.coralRed.withValues(alpha: 0.5),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.place_rounded, color: Colors.white, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                region.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Top Bar Floating Overlay with Title and Hint
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    // Back button styled with Alippe back icon
                    GestureDetector(
                      key: const ValueKey('map_back_button'),
                      onTap: _exitScreen,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            AlippeAssets.sideBack,
                            width: 28,
                            height: 28,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF1E293B),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.explore_rounded, color: AppTheme.skyTurquoise, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Кыргызстан картасы',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Hint pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded, color: Color(0xFF64748B), size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Аймакты басып билип ал',
                            style: TextStyle(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}


