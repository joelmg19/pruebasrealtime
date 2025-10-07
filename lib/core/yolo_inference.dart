// Cellsay 🚀 AGPL-3.0 License - https://cellsay.com/license

import 'package:flutter/services.dart';
import 'package:ultralytics_yolo/models/yolo_task.dart';
import 'package:ultralytics_yolo/models/yolo_exceptions.dart';
import 'package:ultralytics_yolo/utils/error_handler.dart';
import 'package:ultralytics_yolo/utils/map_converter.dart';

/// Inference functionality for YOLO models limited to object detection.
class YOLOInference {
  final MethodChannel _channel;
  final String _instanceId;
  final YOLOTask _task;

  YOLOInference({
    required MethodChannel channel,
    required String instanceId,
    required YOLOTask task,
  }) : _channel = channel,
       _instanceId = instanceId,
       _task = task;

  Future<Map<String, dynamic>> predict(
    Uint8List imageBytes, {
    double? confidenceThreshold,
    double? iouThreshold,
  }) async {
    if (imageBytes.isEmpty) {
      throw InvalidInputException('Image data is empty');
    }

    if (confidenceThreshold != null &&
        (confidenceThreshold < 0.0 || confidenceThreshold > 1.0)) {
      throw InvalidInputException(
        'Confidence threshold must be between 0.0 and 1.0',
      );
    }
    if (iouThreshold != null && (iouThreshold < 0.0 || iouThreshold > 1.0)) {
      throw InvalidInputException('IoU threshold must be between 0.0 and 1.0');
    }

    try {
      final Map<String, dynamic> arguments = {'image': imageBytes};

      if (confidenceThreshold != null) {
        arguments['confidenceThreshold'] = confidenceThreshold;
      }
      if (iouThreshold != null) {
        arguments['iouThreshold'] = iouThreshold;
      }

      if (_instanceId != 'default') {
        arguments['instanceId'] = _instanceId;
      }

      final result = await _channel.invokeMethod(
        'predictSingleImage',
        arguments,
      );

      if (result is Map) {
        return _processInferenceResult(result);
      }

      throw InferenceException('Invalid result format returned from inference');
    } on PlatformException catch (e) {
      throw YOLOErrorHandler.handleError(e, 'Error during image prediction');
    } catch (e) {
      throw YOLOErrorHandler.handleError(e, 'Error during image prediction');
    }
  }

  Map<String, dynamic> _processInferenceResult(Map<dynamic, dynamic> result) {
    final Map<String, dynamic> resultMap = MapConverter.convertToTypedMap(
      result,
    );

    if (_task != YOLOTask.detect) {
      throw InferenceException('Unsupported YOLO task: ${_task.name}');
    }

    final List<Map<String, dynamic>> boxes = [];
    if (resultMap.containsKey('boxes') && resultMap['boxes'] is List) {
      boxes.addAll(MapConverter.convertBoxesList(resultMap['boxes'] as List));
      resultMap['boxes'] = boxes;
    }

    final detections = _processDetectResults(boxes);
    resultMap['detections'] = detections;

    return resultMap;
  }

  List<Map<String, dynamic>> _processDetectResults(
    List<Map<String, dynamic>> boxes,
  ) {
    final List<Map<String, dynamic>> detections = [];

    for (final box in boxes) {
      detections.add(_createDetectionMap(box));
    }

    return detections;
  }

  Map<String, dynamic> _createDetectionMap(Map<String, dynamic> box) {
    return {
      'classIndex': 0,
      'className': MapConverter.safeGetString(box, 'class'),
      'confidence': MapConverter.safeGetDouble(box, 'confidence'),
      'boundingBox': {
        'left': MapConverter.safeGetDouble(box, 'x1'),
        'top': MapConverter.safeGetDouble(box, 'y1'),
        'right': MapConverter.safeGetDouble(box, 'x2'),
        'bottom': MapConverter.safeGetDouble(box, 'y2'),
      },
      'normalizedBox': {
        'left': MapConverter.safeGetDouble(box, 'x1_norm'),
        'top': MapConverter.safeGetDouble(box, 'y1_norm'),
        'right': MapConverter.safeGetDouble(box, 'x2_norm'),
        'bottom': MapConverter.safeGetDouble(box, 'y2_norm'),
      },
    };
  }
}
