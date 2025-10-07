// Cellsay 🚀 AGPL-3.0 License - https://cellsay.com/license

/// Configuration class for customizing YOLO streaming behavior.
///
/// This streamlined version focuses on object detection scenarios. Advanced
/// toggles for segmentation, pose, classification, and oriented bounding boxes
/// remain in the API surface for backwards compatibility but are ignored by the
/// detection-only runtime.
class YOLOStreamingConfig {
  /// Whether to include basic detection results (bounding boxes, confidence, class).
  ///
  /// This is the core YOLO output and is typically always enabled.
  /// Disabling this will result in no detection data being sent.
  final bool includeDetections;

  /// Whether to include classification outputs alongside detections.
  ///
  /// Retained for backwards compatibility. In the Cellsay detection-only
  /// experience these values are ignored by the native layers and always
  /// treated as `false`.
  final bool includeClassifications;

  /// Whether to include processing time metrics in milliseconds.
  ///
  /// This provides timing information for performance monitoring.
  /// Default is true to maintain compatibility with existing apps.
  final bool includeProcessingTimeMs;

  /// Whether to include frames per second (FPS) metrics.
  ///
  /// This provides real-time FPS information for performance monitoring.
  /// Default is true to maintain compatibility with existing apps.
  final bool includeFps;

  /// Whether to include segmentation masks with detection results.
  ///
  /// Retained for API stability. Masks are not generated in detection-only
  /// mode, so this flag is ignored by the runtime and effectively behaves as
  /// `false`.
  final bool includeMasks;

  /// Whether to include pose estimation keypoints with detection results.
  ///
  /// Retained for API stability but ignored in detection-only mode.
  final bool includePoses;

  /// Whether to include oriented bounding boxes (OBB) with detection results.
  ///
  /// Retained for API stability but ignored in detection-only mode.
  final bool includeOBB;

  /// Whether to include original camera frames without annotations.
  ///
  /// Original images are useful for custom post-processing or debugging.
  /// This significantly increases memory usage and should be used carefully.
  final bool includeOriginalImage;

  /// Maximum frames per second for streaming output.
  ///
  /// This controls how often results are sent to Flutter, not inference frequency.
  /// When set, limits the rate at which results are sent to improve
  /// performance. Null means no limit (device-dependent maximum).
  final int? maxFPS;

  /// Minimum interval between result transmissions.
  ///
  /// When set, ensures a minimum time gap between consecutive results.
  /// Useful for throttling high-frequency updates.
  final Duration? throttleInterval;

  /// Target inference frequency in frames per second.
  ///
  /// This controls how often YOLO inference is actually performed on camera frames.
  /// Lower values reduce CPU/GPU usage and heat generation but may miss fast objects.
  /// Higher values provide smoother tracking but consume more resources.
  ///
  /// Examples:
  /// - `30`: High frequency - smooth tracking, high resource usage
  /// - `15`: Balanced - good tracking with moderate resource usage
  /// - `10`: Low frequency - basic detection, low resource usage
  /// - `5`: Very low - minimal detection, battery saving
  /// - `null`: Maximum frequency (device-dependent, usually 30-60 FPS)
  final int? inferenceFrequency;

  /// Skip frames between inferences for power saving.
  ///
  /// This is an alternative way to control inference frequency by specifying
  /// how many camera frames to skip between inferences.
  ///
  /// Examples:
  /// - `0`: Process every frame (maximum frequency)
  /// - `1`: Process every 2nd frame (half frequency)
  /// - `2`: Process every 3rd frame (1/3 frequency)
  /// - `4`: Process every 5th frame (1/5 frequency)
  ///
  /// Note: If both `inferenceFrequency` and `skipFrames` are set,
  /// `inferenceFrequency` takes precedence.
  final int? skipFrames;

  /// Creates a YOLOStreamingConfig with custom settings.
  ///
  /// This constructor allows full customization of streaming behavior.
  /// Defaults are optimized for high-speed operation with minimal data.
  const YOLOStreamingConfig({
    this.includeDetections = true,
    this.includeClassifications = false,
    this.includeProcessingTimeMs = true,
    this.includeFps = true,
    this.includeMasks = false,
    this.includePoses = false,
    this.includeOBB = false,
    this.includeOriginalImage = false,
    this.maxFPS,
    this.throttleInterval,
    this.inferenceFrequency,
    this.skipFrames,
  });

  /// Creates a minimal configuration optimized for maximum performance.
  ///
  /// This is the default configuration for YOLOView, providing only essential
  /// detection data and performance metrics.
  const YOLOStreamingConfig.minimal()
    : includeDetections = true,
      includeClassifications = false,
      includeProcessingTimeMs = true,
      includeFps = true,
      includeOriginalImage = false,
      maxFPS = null,
      throttleInterval = null,
      inferenceFrequency = null,
      skipFrames = null;

  /// Creates a custom configuration with specified parameters.
  ///
  /// Any unspecified parameters default to false (except detections and
  /// performance metrics which default to true).
  const YOLOStreamingConfig.custom({
    bool? includeDetections,
    bool? includeProcessingTimeMs,
    bool? includeFps,
    bool? includeOriginalImage,
    this.maxFPS,
    this.throttleInterval,
    this.inferenceFrequency,
    this.skipFrames,
  })  : includeDetections = includeDetections ?? true,
        includeClassifications = includeClassifications ?? false,
        includeProcessingTimeMs = includeProcessingTimeMs ?? true,
        includeFps = includeFps ?? true,
        includeMasks = includeMasks ?? false,
        includePoses = includePoses ?? false,
        includeOBB = includeOBB ?? false,
        includeOriginalImage = includeOriginalImage ?? false;
}
