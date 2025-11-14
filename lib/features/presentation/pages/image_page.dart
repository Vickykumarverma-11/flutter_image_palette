import 'package:assignment/features/presentation/pages/widgets/animated_gradient_background.dart';
import 'package:assignment/features/presentation/pages/widgets/image_display_widget.dart';
import 'package:assignment/features/presentation/pages/image_page_constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:neopop/neopop.dart';
import '../../../core/utils/app_notifier.dart';
import '../bloc/image_bloc.dart';
import '../bloc/image_event.dart';
import '../bloc/image_state.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({super.key});

  static const double _borderRadius = ImagePageConstants.borderRadius;
  static const double _padding = ImagePageConstants.padding;

  static const double _errorIconSize = ImagePageConstants.errorIconSize;

  static const Duration _animationDuration =
      ImagePageConstants.animationDuration;
  static const Duration _switcherDuration = ImagePageConstants.switcherDuration;

  static const Color _buttonColor = ImagePageConstants.buttonColor;
  static const Color _buttonPlunkColor = ImagePageConstants.buttonPlunkColor;
  static const Color _buttonShadowColor = ImagePageConstants.buttonShadowColor;

  Widget _buildImageWidget(String url) {
    return ImageDisplayWidget(
      imageUrl: url,
      semanticLabel: 'Random unsplash image',
      onImageLoaded: () {},
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Tap 'Another' to load an image",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? previousUrl, String message) {
    if (previousUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildImageWidget(previousUrl),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Failed to load new image",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: _errorIconSize, color: Colors.red),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: Colors.red, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    // use AnimatedGradientBackground inside the clip for a nice loading background
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AnimatedGradientBackground(
        primaryColor: Theme.of(context).colorScheme.primaryContainer,
        secondaryColor: Theme.of(context).colorScheme.surfaceVariant,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitFadingCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 64,
              ),
              const SizedBox(height: 18),
              Text(
                "Loading amazing image...",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFetchButton(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Semantics(
        button: true,
        label: isLoading ? 'Loading image' : 'Load another image',
        child: Tooltip(
          message: isLoading ? 'Loading...' : 'Fetch another image',
          child: NeoPopTiltedButton(
            isFloating: true,
            onTapUp: isLoading
                ? null
                : () {
                    context.read<ImageBloc>().add(FetchImage());
                  },
            decoration: NeoPopTiltedButtonDecoration(
              color: isLoading ? Colors.grey : _buttonColor,
              plunkColor: _buttonPlunkColor,
              shadowColor: _buttonShadowColor,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLoading ? "Loading..." : "Another",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImageBloc, ImageState>(
      listener: (context, state) {
        state.maybeWhen(
          failure: (msg, previous, _) {
            if (previous == null) {
              AppNotifier.showError(context, msg);
            } else {
              AppNotifier.showWarning(
                context,
                "Failed to load new image. Showing previous.",
              );
            }
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final bgBaseColor = state.maybeWhen(
          success: (_, color) => color,
          loading: (_, color) => color,
          failure: (_, __, color) => color,
          orElse: () => Theme.of(context).colorScheme.background,
        );

        // compute complementary secondary gradient color for smoother look
        final secondary = Color.lerp(
                bgBaseColor, Theme.of(context).colorScheme.surface, 0.12) ??
            bgBaseColor;

        final isLoading = state.maybeWhen(
          loading: (_, __) => true,
          orElse: () => false,
        );

        final content = state.when(
          idle: () => _buildEmptyState(),
          loading: (_, __) => _buildLoadingState(context),
          success: (img, _) => _buildImageWidget(img.url),
          failure: (msg, prev, _) => _buildErrorState(prev?.url, msg),
        );

        return AnimatedGradientBackground(
          primaryColor: bgBaseColor,
          secondaryColor: secondary,
          duration: _animationDuration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: AnimatedSwitcher(
                  duration: _switcherDuration,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: AspectRatio(
                    key: ValueKey<String>(
                      state.maybeWhen(
                        success: (img, _) => "success_${img.url}",
                        orElse: () => "state_${state.runtimeType}",
                      ),
                    ),
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(_padding),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(_borderRadius),
                        child: content,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: _buildFetchButton(context, isLoading),
          ),
        );
      },
    );
  }
}
