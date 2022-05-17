import 'dart:io';

import 'package:flutter/material.dart';

enum ImageType { Asset, Network, File }

typedef LoadingCallback = Widget Function(
    BuildContext, Widget, ImageChunkEvent?)?;

class CustomImage extends Image {
  // ignore: use_key_in_widget_constructors
  CustomImage._asset(String name, BoxFit boxfit)
      : super.asset(name, fit: boxfit);

  // ignore: use_key_in_widget_constructors
  CustomImage._file(String name, BoxFit boxfit)
      : super.file(File(name), fit: boxfit);

  // ignore: use_key_in_widget_constructors
  CustomImage._network(String name, BoxFit boxFit,
      {Widget Function(BuildContext, Object, StackTrace?)? errorBuilder})
      : super.network(name,
            loadingBuilder: _loadingBuilder,
            fit: boxFit,
            errorBuilder: errorBuilder);

  static Widget show(ImageType imageType, String url,
      {BoxFit boxfit = BoxFit.cover,
      String errMessage = "",
      double? width,
      double? height,
      double? radius,
      Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
      Color? backgroundColor,
      Color? filterColor,
      double? filterColorValue}) {
    CustomImage? _child;
    switch (imageType) {
      case ImageType.Asset:
        _child = CustomImage._asset(url, boxfit);
        break;
      case ImageType.Network:
        _child = CustomImage._network(
          url,
          boxfit,
          errorBuilder:
              errorBuilder ?? (a, b, c) => Center(child: Text(errMessage)),
        );
        break;
      case ImageType.File:
        _child = CustomImage._file(url, boxfit);
        break;
      default:
        _child = null;
        break;
    }
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color.fromARGB(0, 255, 247, 247),
        borderRadius: radius != null
            ? BorderRadius.circular(radius)
            : const BorderRadius.all(Radius.zero),
      ),
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: radius != null
                ? BorderRadius.circular(radius)
                : const BorderRadius.all(Radius.zero),
            child: _child ?? Text(errMessage),
          ),
          filterColor != null
              ? ClipRRect(
                  borderRadius: radius != null
                      ? BorderRadius.circular(radius)
                      : const BorderRadius.all(Radius.zero),
                  child: Container(
                    color: filterColor.withOpacity(filterColorValue ?? 0),
                  ))
              : Container(),
        ],
      ),
    );
  }

  // ignore: prefer_function_declarations_over_variables
  static final LoadingCallback _loadingBuilder =
      (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  };
}
