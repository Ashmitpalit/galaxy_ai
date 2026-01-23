class PhotoModel {
  final int id;
  final int width;
  final int height;
  final String url;
  final String photographer;
  final String? photographerUrl;
  final String avgColor;
  final PhotoSrc src;
  
  PhotoModel({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.photographer,
    this.photographerUrl,
    required this.avgColor,
    required this.src,
  });
  
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      url: json['url'] as String,
      photographer: json['photographer'] as String,
      photographerUrl: json['photographer_url'] as String?,
      avgColor: json['avg_color'] as String? ?? '#000000',
      src: PhotoSrc.fromJson(json['src'] as Map<String, dynamic>),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'width': width,
      'height': height,
      'url': url,
      'photographer': photographer,
      'photographer_url': photographerUrl,
      'avg_color': avgColor,
      'src': src.toJson(),
    };
  }
}

class PhotoSrc {
  final String original;
  final String large2x;
  final String large;
  final String medium;
  final String small;
  final String portrait;
  final String landscape;
  final String tiny;
  
  PhotoSrc({
    required this.original,
    required this.large2x,
    required this.large,
    required this.medium,
    required this.small,
    required this.portrait,
    required this.landscape,
    required this.tiny,
  });
  
  factory PhotoSrc.fromJson(Map<String, dynamic> json) {
    return PhotoSrc(
      original: json['original'] as String,
      large2x: json['large2x'] as String,
      large: json['large'] as String,
      medium: json['medium'] as String,
      small: json['small'] as String,
      portrait: json['portrait'] as String,
      landscape: json['landscape'] as String,
      tiny: json['tiny'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'large2x': large2x,
      'large': large,
      'medium': medium,
      'small': small,
      'portrait': portrait,
      'landscape': landscape,
      'tiny': tiny,
    };
  }
}
