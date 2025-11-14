// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:assignment/core/di/register_module.dart' as _i716;
import 'package:assignment/core/network/dio_client.dart' as _i262;
import 'package:assignment/features/data/repositories/image_repository_impl.dart'
    as _i156;
import 'package:assignment/features/data/sources/image_service.dart' as _i165;
import 'package:assignment/features/domain/repositories/image_repository.dart'
    as _i605;
import 'package:assignment/features/domain/usecases/get_random_image.dart'
    as _i1019;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i262.DioClient>(() => registerModule.dioClient);
    gh.lazySingleton<_i361.Dio>(
        () => registerModule.dio(gh<_i262.DioClient>()));
    gh.lazySingleton<_i165.ImageService>(
        () => _i165.ImageService(gh<_i361.Dio>()));
    gh.lazySingleton<_i605.ImageRepository>(
        () => _i156.ImageRepositoryImpl(gh<_i165.ImageService>()));
    gh.lazySingleton<_i1019.GetRandomImage>(
        () => _i1019.GetRandomImage(gh<_i605.ImageRepository>()));
    return this;
  }
}

class _$RegisterModule extends _i716.RegisterModule {}
