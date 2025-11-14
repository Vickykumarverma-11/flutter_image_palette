import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/color_extractor.dart';
import '../../../core/network/exceptions.dart';
import '../../domain/usecases/get_random_image.dart';
import '../../domain/entities/image_entity.dart';
import 'image_event.dart';
import 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final GetRandomImage getRandomImage;
  final Logger _logger = Logger();

  StreamSubscription? _colorExtractionSubscription;

  ImageBloc(this.getRandomImage) : super(const ImageState.idle()) {
    on<FetchImage>(_onFetchImage);
    on<_UpdateColorEvent>(_onUpdateColor);
  }

  Future<void> _onFetchImage(
    FetchImage event,
    Emitter<ImageState> emit,
  ) async {
    _logger.i('Fetching new image...');

    final previousImage = state.maybeWhen(
      success: (img, _) => img,
      failure: (_, img, __) => img,
      loading: (img, _) => img,
      orElse: () => null,
    );

    final previousColor = state.maybeWhen(
      success: (_, c) => c,
      loading: (_, c) => c,
      failure: (_, __, c) => c,
      orElse: () => const Color(0xFFE0E0E0),
    );

    emit(
        ImageState.loading(previous: previousImage, background: previousColor));

    try {
      final newImage = await getRandomImage();

      final dominant = await ColorExtractor.extractDominantColor(newImage.url);

      emit(ImageState.success(newImage, dominant));
    } catch (err, stack) {
      _logger.e("Fetch failed", error: err, stackTrace: stack);

      emit(ImageState.failure(
        _getDetailedErrorMessage(err),
        previous: previousImage,
        background: previousColor,
      ));
    }
  }

  Future<void> _onUpdateColor(
    _UpdateColorEvent event,
    Emitter<ImageState> emit,
  ) async {
    state.maybeWhen(
      success: (currentImage, _) {
        if (currentImage.url == event.image.url) {
          emit(ImageState.success(event.image, event.color));
        }
      },
      orElse: () {},
    );
  }

  String _getDetailedErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    } else if (error.toString().contains('timeout')) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('Connection refused')) {
      return 'Cannot connect to server. Please try again later.';
    } else if (error.toString().contains('DioException')) {
      return 'Network error occurred. Please try again.';
    }
    return 'Failed to load image. Please try again.';
  }

  @override
  Future<void> close() {
    _logger.i('ImageBloc closing');
    _colorExtractionSubscription?.cancel();
    return super.close();
  }
}

class _UpdateColorEvent extends ImageEvent {
  final ImageEntity image;
  final Color color;

  _UpdateColorEvent(this.image, this.color);

  @override
  List<Object?> get props => [image, color];
}
