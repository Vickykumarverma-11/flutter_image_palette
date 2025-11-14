import 'package:injectable/injectable.dart';
import '../entities/image_entity.dart';
import '../repositories/image_repository.dart';

@lazySingleton
class GetRandomImage {
  final ImageRepository repository;
  GetRandomImage(this.repository);

  Future<ImageEntity> call() => repository.getRandomImage();
}
