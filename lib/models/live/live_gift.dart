class LiveGift {
  final String id;
  final String name;
  final String imageUrl;
  final int coins;
  final String? animationUrl;

  LiveGift({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.coins,
    this.animationUrl,
  });

  factory LiveGift.fromJson(Map<String, dynamic> json) {
    return LiveGift(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      coins: json['coins'] ?? 0,
      animationUrl: json['animation_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'coins': coins,
      'animation_url': animationUrl,
    };
  }
}

class SentGift {
  final String id;
  final String streamId;
  final String senderId;
  final String receiverId;
  final String giftId;
  final LiveGift? gift;
  final int quantity;
  final DateTime sentAt;

  SentGift({
    required this.id,
    required this.streamId,
    required this.senderId,
    required this.receiverId,
    required this.giftId,
    this.gift,
    this.quantity = 1,
    required this.sentAt,
  });

  factory SentGift.fromJson(Map<String, dynamic> json) {
    return SentGift(
      id: json['id'] ?? '',
      streamId: json['stream_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      giftId: json['gift_id'] ?? '',
      gift: json['gift'] != null ? LiveGift.fromJson(json['gift']) : null,
      quantity: json['quantity'] ?? 1,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stream_id': streamId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'gift_id': giftId,
      'quantity': quantity,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}
