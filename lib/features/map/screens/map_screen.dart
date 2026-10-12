import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/asset_paths.dart';
import '../widgets/region_detail_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapRepository _repository = MapRepository();
  late List<RegionModel> _regions;

  @override
  void initState() {
    super.initState();
    _regions = _repository.getRegions();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Кыргызстан картасы',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () {
            AudioController.instance.playButtonClick();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: const Text(
              'Облус же шаардын үстүн басып, ал тууралуу кененирээк билип алыңыз!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InteractiveViewer(
                  maxScale: 3.0,
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              AssetPaths.mapImage,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.blue.shade50,
                                child: const Center(child: Icon(Icons.map, size: 80, color: Colors.blue)),
                              ),
                            ),
                          ),
                        ),
                        // Region interactive pins
                        ..._regions.map((region) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final left = region.x * constraints.maxWidth - 20;
                              final top = region.y * constraints.maxHeight - 20;
                              return Positioned(
                                left: left,
                                top: top,
                                child: GestureDetector(
                                  onTap: () => _onRegionSelected(region),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.coralRed,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.coralRed.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.place_rounded, color: Colors.white, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          region.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

