// Cellsay 🚀 AGPL-3.0 License - https://cellsay.com/license

import 'package:flutter/material.dart';
import '../controllers/camera_inference_controller.dart';
import '../models/models.dart';
import '../widgets/camera_inference_content.dart';
import '../widgets/camera_logo_overlay.dart';
import '../widgets/camera_controls.dart';
import '../widgets/threshold_slider.dart';

/// A screen that demonstrates real-time YOLO inference using the device camera.
///
/// This screen provides:
/// - Live camera feed with Cellsay YOLO object detection
/// - Accessible status information with large, high-contrast text
/// - Adjustable thresholds (confidence, IoU, max detections)
/// - Camera controls (flip, zoom)
/// - Performance metrics (FPS)
class CameraInferenceScreen extends StatefulWidget {
  const CameraInferenceScreen({super.key});

  @override
  State<CameraInferenceScreen> createState() => _CameraInferenceScreenState();
}

class _CameraInferenceScreenState extends State<CameraInferenceScreen> {
  late final CameraInferenceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CameraInferenceController();
    _controller.initialize().catchError((error) {
      if (mounted) {
        _showError('Model Loading Error', error.toString());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              CameraInferenceContent(controller: _controller),
              _AccessibleStatusPanel(
                controller: _controller,
                isLandscape: isLandscape,
              ),
              CameraLogoOverlay(
                controller: _controller,
                isLandscape: isLandscape,
              ),
              CameraControls(
                currentZoomLevel: _controller.currentZoomLevel,
                isFrontCamera: _controller.isFrontCamera,
                activeSlider: _controller.activeSlider,
                onZoomChanged: _controller.setZoomLevel,
                onSliderToggled: _controller.toggleSlider,
                onCameraFlipped: _controller.flipCamera,
                isLandscape: isLandscape,
              ),
              ThresholdSlider(
                activeSlider: _controller.activeSlider,
                confidenceThreshold: _controller.confidenceThreshold,
                iouThreshold: _controller.iouThreshold,
                numItemsThreshold: _controller.numItemsThreshold,
                onValueChanged: _controller.updateSliderValue,
                isLandscape: isLandscape,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showError(String title, String message) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class _AccessibleStatusPanel extends StatelessWidget {
  const _AccessibleStatusPanel({
    required this.controller,
    required this.isLandscape,
  });

  final CameraInferenceController controller;
  final bool isLandscape;

  String? _sliderDescription() {
    switch (controller.activeSlider) {
      case SliderType.confidence:
        return 'Confidence threshold ${controller.confidenceThreshold.toStringAsFixed(2)}';
      case SliderType.iou:
        return 'IoU threshold ${controller.iouThreshold.toStringAsFixed(2)}';
      case SliderType.numItems:
        return 'Maximum items ${controller.numItemsThreshold}';
      case SliderType.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sliderDescription = _sliderDescription();
    final padding = isLandscape
        ? const EdgeInsets.all(16)
        : const EdgeInsets.all(20);

    return Positioned(
      top: isLandscape ? 12 : 24,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Semantics(
          container: true,
          label: 'Cellsay detection status',
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: padding,
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        alignment: WrapAlignment.start,
                        children: [
                          _InfoTile(
                            label: 'Detections',
                            value: controller.detectionCount.toString(),
                            semanticLabel:
                                'Detected objects: ${controller.detectionCount}',
                          ),
                          _InfoTile(
                            label: 'Frames per second',
                            value: controller.currentFps.toStringAsFixed(1),
                            semanticLabel:
                                'Frames per second: ${controller.currentFps.toStringAsFixed(1)}',
                          ),
                          if (sliderDescription != null)
                            _SliderDescriptionCard(
                              description: sliderDescription,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.semanticLabel,
  });

  final String label;
  final String value;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle =
        theme.textTheme.labelMedium?.copyWith(
          color: Colors.white70,
          letterSpacing: 0.6,
        ) ??
        const TextStyle(
          color: Colors.white70,
          letterSpacing: 0.6,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );

    final valueStyle =
        theme.textTheme.displaySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 32,
        ) ??
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 32,
        );

    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: labelStyle),
            const SizedBox(height: 6),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(value, style: valueStyle),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderDescriptionCard extends StatelessWidget {
  const _SliderDescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle =
        theme.textTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ) ??
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        );

    return Semantics(
      label: 'Active slider: $description',
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(description.toUpperCase(), style: textStyle),
      ),
    );
  }
}
