// Cellsay 🚀 AGPL-3.0 License - https://cellsay.com/license

import 'package:ultralytics_yolo/models/yolo_task.dart';

enum ModelType {
  detect('yolo11n', YOLOTask.detect);

  final String modelName;

  final YOLOTask task;

  const ModelType(this.modelName, this.task);
}

enum SliderType { none, numItems, confidence, iou }
