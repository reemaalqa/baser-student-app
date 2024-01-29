class SliderDetails {
  final String imageUrl;
  final int id;

  SliderDetails({required this.id, required this.imageUrl});

  static SliderDetails fromJson(Map<String, dynamic> json) {
    return SliderDetails(
      id: int.parse((json['id'] ?? 0).toString()),
      imageUrl: json['image'] ?? "",
    );
  }
}
