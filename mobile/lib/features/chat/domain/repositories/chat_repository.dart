import '../../data/models/chat_room_model.dart';
import '../../data/models/chat_message_model.dart';

abstract class ChatRepository {
  Future<ChatRoomModel> getOrCreateRoom({
    required String token,
    required String roomType,
    String? shopId,
    String? shipperId,
    String? associatedOrderId,
  });

  Future<List<ChatRoomModel>> listRooms({required String token});

  Future<List<ChatMessageModel>> listMessages({
    required String token,
    required String roomId,
    int limit = 50,
    int offset = 0,
  });

  Future<void> markAsRead({required String token, required String roomId});
}
