import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../network/dio_client.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio dio(DioClient dioClient) => dioClient.createDio();

  @lazySingleton
  DioClient get dioClient => DioClient();
}
