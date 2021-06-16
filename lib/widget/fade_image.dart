import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class FadeImage extends StatefulWidget {
  final String url;
  final int duration;
  final double imageWidth;
  final double imageHeight;
  final BoxFit fit;
  final bool fromAsset;

  static FadeImage network(String url,
      {Key? key,
      int duration = 300,
      double imageWidth = double.infinity,
      double imageHeight = double.infinity,
      BoxFit fit = BoxFit.cover}) {
    return FadeImage(
      url,
      key: key,
      duration: duration,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      fit: fit,
      fromAsset: false,
    );
  }

  static FadeImage asset(String url,
      {Key? key,
      int duration = 300,
      double imageWidth = double.infinity,
      double imageHeight = double.infinity,
      BoxFit fit = BoxFit.cover}) {
    return FadeImage(
      url,
      key: key,
      duration: duration,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      fit: fit,
      fromAsset: true,
    );
  }

  FadeImage(
    this.url, {
    Key? key,
    this.duration = 300,
    this.imageWidth = double.infinity,
    this.imageHeight = double.infinity,
    this.fit = BoxFit.cover,
    this.fromAsset = false,
  }) : super(key: key ?? Key(url + "${duration.hashCode}"));

  @override
  State<StatefulWidget> createState() => _FadeImageState();
}

class _FadeImageState extends State<FadeImage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late CurvedAnimation _curvedAnimation;

  bool _placeVisible = true;
  Color _placeColor = Colors.transparent;
  late ImageProvider _imageProvider;

  Future getPaletteColor(ui.Image image) async {
    var rectWidth = image.width / 3.0;
    var rectHeight = image.height / 3.0;
    var color = await PaletteGenerator.fromImage(image,
        region: Rect.fromCenter(
            center: Offset(image.width / 2.0, image.height / 2.0),
            width: rectWidth,
            height: rectHeight),
        maximumColorCount: 5);
    if (mounted) {
      setState(() {
        var lightColor = color.lightVibrantColor ?? color.darkVibrantColor;
        if (lightColor == null) {
          _placeColor = Colors.transparent;
        } else {
          _placeColor = lightColor.color;
        }
        _placeVisible = false;
      });
      _fadeController.forward();
    }
  }

  void initAnimationControllerIfLate() {
    _fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration));
    _curvedAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _imageProvider = _addImageLoader(widget.url);
  }

  ImageProvider<Object> _addImageLoader(String url) {
    Image image;
    if (widget.fromAsset) {
      image = Image.asset(widget.url);
    } else {
      image = Image.network(widget.url);
    }
    image.image
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((info, synchronousCall) {
          if (!synchronousCall) {
            var image = info.image;
            getPaletteColor(image);
          } else {
            if (mounted) {
              setState(() {
                _fadeController.value = 1.0;
                _placeVisible = false;
              });
            }
          }
        }, onChunk: (_) {}, onError: (_, stack) {}));
    return image.image;
  }

  @override
  void initState() {
    super.initState();
    initAnimationControllerIfLate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _placeVisible ? 1.0 : 0.15,
          curve: Curves.easeOut,
          duration: Duration(milliseconds: widget.duration),
          child: Container(
            width: widget.imageWidth,
            height: widget.imageHeight,
            color: _placeColor,
          ),
        ),
        FadeTransition(
          opacity: _curvedAnimation,
          child: SizedBox(
              width: widget.imageWidth,
              height: widget.imageHeight,
              child: Image(
                width: widget.imageWidth,
                height: widget.imageHeight,
                image: _imageProvider,
                fit: widget.fit,
              )),
        )
      ],
    );
  }
}
