import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import '../models/image_model.dart';

part 'image_service.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://november7-730026606190.europe-west1.run.app")
abstract class ImageService {
  @factoryMethod
  factory ImageService(Dio dio) = _ImageService;

  @GET("/image")
  Future<ImageModel> getRandomImage();
}
