class ChunkModel {
  final String id;
  final int chunkNumber;
  final String text;
  final List<double>? embedding; // optional

  ChunkModel({
    required this.id,
    required this.chunkNumber,
    required this.text,
    this.embedding,
  });

  factory ChunkModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ChunkModel(
      id: documentId,
      chunkNumber: json['chunkNumber'] ?? 0,
      text: json['text'] ?? '',
      embedding: json['embedding'] != null 
          ? List<double>.from(json['embedding'].map((e) => e.toDouble()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chunkNumber': chunkNumber,
      'text': text,
      if (embedding != null) 'embedding': embedding,
    };
  }
}
