import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ImageDisplayWidget extends StatefulWidget {
  final String imageUrl;
  final VoidCallback? onImageLoaded;
  final String? semanticLabel;

  const ImageDisplayWidget({
    super.key,
    required this.imageUrl,
    this.onImageLoaded,
    this.semanticLabel,
  });

  @override
  State<ImageDisplayWidget> createState() => _ImageDisplayWidgetState();
}

class _ImageDisplayWidgetState extends State<ImageDisplayWidget> {
  bool _visible = false;

  void _onLoaded() {
    if (widget.onImageLoaded != null) widget.onImageLoaded!();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.85;

    return Center(
      child: Hero(
        tag: 'random_image',
        child: Semantics(
          label: widget.semanticLabel ?? 'Displayed image',
          image: true,
          child: Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero,
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Center(
                    child: SpinKitFadingCircle(
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 50,
                    semanticLabel: 'Failed to load image',
                  ),
                ),
                imageBuilder: (context, imageProvider) {
                  return StatefulBuilder(builder: (context, setState) {
                    Future.microtask(() {
                      if (!_visible) setState(() => _visible = true);
                    });
                    return AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      onEnd: _onLoaded,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
