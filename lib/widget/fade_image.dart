import 'dart:math';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class FadeImage extends StatefulWidget {
  final String url;
  final int duration;
  final double imageWidth;
  final double imageHeight;
  final BoxFit fit;

  FadeImage(
    this.url, {
    Key? key,
    this.duration = 300,
    this.imageWidth = double.infinity,
    this.imageHeight = double.infinity,
    this.fit = BoxFit.cover,
  }) : super(key: key ?? Key(url + "${duration.hashCode}"));

  @override
  State<StatefulWidget> createState() => _FadeImageState();
}

class _FadeImageState extends State<FadeImage> with TickerProviderStateMixin {
  late AnimationController _fadeController;

  bool _placeVisible = true;
  Color _placeColor = Colors.transparent;
  late ImageProvider _imageProvider;

  Future getPaletteColor(int width, int height) async {
    var scaleWidth = width / 100.0;
    var scaleHeight = height / 100.0;
    var rectWidth = scaleWidth / 3.0;
    var rectHeight = scaleHeight / 3.0;
    var color = await PaletteGenerator.fromImageProvider(_imageProvider,
        size: Size(scaleWidth, scaleHeight),
        region: Rect.fromCenter(
            center: Offset(scaleWidth / 2.0,scaleHeight / 2.0 ), width: rectWidth, height: rectHeight),maximumColorCount: 5);
    if (mounted) {
      setState(() {
        var lightColor = color.lightVibrantColor ?? color.darkVibrantColor;
        if (lightColor == null) {
          _placeColor = Colors.transparent;
        }else{
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

    _imageProvider = _addImageLoader(widget.url);
  }

  ImageProvider<Object> _addImageLoader(String url) {
    var image = Image.network(url);
    image.image
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((info, synchronousCall) {
          if (!synchronousCall) {
            //_fadeController.forward();
            var image = info.image;
            getPaletteColor(image.width, image.height);
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
          opacity: _placeVisible ? 1.0 : 0.25,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: widget.duration),
          child: Container(
            width: widget.imageWidth,
            height: widget.imageHeight,
            color: _placeColor,
          ),
        ),
        FadeTransition(
          opacity: _fadeController,
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
