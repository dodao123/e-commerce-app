import '../../../../core/utils/price_formatter.dart';
import '../../../home/data/models/product_model.dart';
import '../manager/chat_websocket_manager.dart';

/// Helper to format and send automatic product inquiries when opening chat from product details.
class ChatProductInquiryHelper {
  ChatProductInquiryHelper._();

  /// Sends product image and formatted text inquiry to start the conversation.
  static void sendInquiry({
    required ChatWebSocketManager wsManager,
    required String roomId,
    required ProductModel product,
  }) {
    if (product.imageUrl.isNotEmpty) {
      wsManager.sendMessage(
        roomId,
        product.imageUrl,
        messageType: 'image',
      );
    }

    final formattedPrice = PriceFormatter.format(product.price);
    final inquiryText =
        'Chào shop, mình quan tâm đến sản phẩm "${product.name}" ($formattedPrice). '
        'Shop tư vấn giúp mình nhé!';

    wsManager.sendMessage(roomId, inquiryText);
  }
}
