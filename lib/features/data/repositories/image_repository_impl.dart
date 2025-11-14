import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/image_entity.dart';
import '../../domain/repositories/image_repository.dart';
import '../../../core/network/exceptions.dart';
import '../sources/image_service.dart';

@LazySingleton(as: ImageRepository)
class ImageRepositoryImpl implements ImageRepository {
  final ImageService _service;
  final Logger _logger = Logger();

  ImageRepositoryImpl(this._service);

  @override
  Future<ImageEntity> getRandomImage() async {
    try {
      _logger.i('Fetching random image from API');

      final image = await _service.getRandomImage();

      _logger.d('Image fetched successfully: ${image.url}');

      return image;
    } on DioException catch (e, stackTrace) {
      _logger.e('DioException occurred', error: e, stackTrace: stackTrace);
      throw NetworkException.fromDioError(e);
    } on NetworkException {
      // Already a NetworkException, just rethrow
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('Unexpected error occurred', error: e, stackTrace: stackTrace);
      throw NetworkException(
        'An unexpected error occurred. Please try again.',
        type: NetworkExceptionType.unknown,
        originalError: e,
      );
    }
  }
}
