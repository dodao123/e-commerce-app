class ChatRoomModel {
  final String id;
  final String roomType;
  final String? customerId;
  final String? shopId;
  final String? shipperId;
  final String? associatedOrderId;
  final String partnerName;
  final String partnerAvatar;
  final String lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  ChatRoomModel({
    required this.id,
    required this.roomType,
    this.customerId,
    this.shopId,
    this.shipperId,
    this.associatedOrderId,
    required this.partnerName,
    required this.partnerAvatar,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      roomType: json['room_type'] as String,
      customerId: json['customer_id'] as String?,
      shopId: json['shop_id'] as String?,
      shipperId: json['shipper_id'] as String?,
      associatedOrderId: json['associated_order_id'] as String?,
      partnerName: json['partner_name'] ?? '',
      partnerAvatar: json['partner_avatar'] ?? '',
      lastMessage: json['last_message'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_type': roomType,
      'customer_id': customerId,
      'shop_id': shopId,
      'shipper_id': shipperId,
      'associated_order_id': associatedOrderId,
      'partner_name': partnerName,
      'partner_avatar': partnerAvatar,
      'last_message': lastMessage,
      'unread_count': unreadCount,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
