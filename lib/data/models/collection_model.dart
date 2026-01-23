class CollectionModel {
  final String id;
  final String title;
  final String coverImageUrl;
  final int pinCount;
  final List<String> previewImageUrls;

  CollectionModel({
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.pinCount,
    required this.previewImageUrls,
  });
}
