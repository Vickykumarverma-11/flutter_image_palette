import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/image_entity.dart';

part 'image_model.freezed.dart';
part 'image_model.g.dart';

@freezed
class ImageModel with _$ImageModel implements ImageEntity {
  const factory ImageModel({required String url}) = _ImageModel;

  factory ImageModel.fromJson(Map<String, dynamic> json) =>
      _$ImageModelFromJson(json);
}
