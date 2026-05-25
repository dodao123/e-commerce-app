import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remoteDatasource;

  ChatRepositoryImpl({required this.remoteDatasource});

  @override
  Future<ChatRoomModel> getOrCreateRoom({
    required String token,
    required String roomType,
    String? shopId,
    String? shipperId,
    String? associatedOrderId,
  }) {
    return remoteDatasource.getOrCreateRoom(
      token: token,
      roomType: roomType,
      shopId: shopId,
      shipperId: shipperId,
      associatedOrderId: associatedOrderId,
    );
  }

  @override
  Future<List<ChatRoomModel>> listRooms({required String token}) {
    return remoteDatasource.listRooms(token: token);
  }

  @override
  Future<List<ChatMessageModel>> listMessages({
    required String token,
    required String roomId,
    int limit = 50,
    int offset = 0,
  }) {
    return remoteDatasource.listMessages(
      token: token,
      roomId: roomId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<void> markAsRead({required String token, required String roomId}) {
    return remoteDatasource.markAsRead(token: token, roomId: roomId);
  }
}
