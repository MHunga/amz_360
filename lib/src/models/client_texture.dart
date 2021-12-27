import 'package:flutter/material.dart';

class ClientTexture {
  final int? idImage;
  ImageStream? imageStream;
  ImageInfo? imageInfo;
  ImageStreamListener? listener;
  Function(double?)? progressCallback;
  ClientTexture(
      {this.idImage,
      required bool isNetwork,
      String? imageUrl,
      Function(ImageInfo imageInfo, bool s)? updateTexture,
      this.progressCallback}) {
    late ImageProvider provider;
    if (isNetwork) {
      provider = Image.network(imageUrl!).image;
    } else {
      provider = Image.asset(imageUrl!).image;
    }
    imageStream = provider.resolve(const ImageConfiguration());

    listener = ImageStreamListener(
      (imageInfo, s) async {
        this.imageInfo = imageInfo;
        progressCallback?.call(null);
        updateTexture?.call(imageInfo, s);
      },
      onChunk: (event) {
        if (event.expectedTotalBytes != null) {
          double progress =
              event.cumulativeBytesLoaded / event.expectedTotalBytes!;
          progressCallback?.call(progress);
          if (progress == 1) {
            progressCallback?.call(null);
          }
        } else {
          progressCallback?.call(null);
        }
      },
    );
    imageStream!.addListener(listener!);
  }

  void dispose() {
    imageStream?.removeListener(listener!);
    imageInfo?.dispose();
    imageInfo = null;
  }
}
