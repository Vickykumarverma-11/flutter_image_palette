import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/image_entity.dart';
import 'package:flutter/material.dart';

part 'image_state.freezed.dart';

@freezed
class ImageState with _$ImageState {
  const factory ImageState.idle() = _Idle;
  const factory ImageState.loading({ImageEntity? previous, Color? background}) =
      _Loading;
  const factory ImageState.success(ImageEntity image, Color background) =
      _Success;
  const factory ImageState.failure(String message,
      {ImageEntity? previous, Color? background}) = _Failure;
}
