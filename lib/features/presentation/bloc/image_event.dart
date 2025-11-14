import 'package:equatable/equatable.dart';

abstract class ImageEvent extends Equatable {
  const ImageEvent();
  @override
  List<Object?> get props => [];
}

class FetchImage extends ImageEvent {}
