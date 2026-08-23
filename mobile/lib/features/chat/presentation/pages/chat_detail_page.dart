import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../home/data/models/product_model.dart';
import '../manager/chat_detail_controller.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_detail_body.dart';

/// ChatDetailPage is the main chat conversation screen.
class ChatDetailPage extends StatefulWidget {
  final String roomId, partnerName, partnerAvatar;
  final ProductModel? initialProduct;

  const ChatDetailPage({
    super.key,
    required this.roomId,
    required this.partnerName,
    required this.partnerAvatar,
    this.initialProduct,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatDetailController _controller = ChatDetailController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.accessToken != null) {
      _controller.initChat(
        token: auth.accessToken!,
        roomId: widget.roomId,
        myId: auth.userId,
        initialProduct: widget.initialProduct,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myId = context.read<AuthProvider>().userId;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: IndieFolkTheme.surface(isDark),
        appBar: ChatAppBar(
          partnerName: widget.partnerName,
          partnerAvatar: widget.partnerAvatar,
        ),
        body: ChatDetailBody(
          loading: _controller.loading,
          messages: _controller.messages,
          isAiTyping: _controller.isAiTyping,
          myId: myId,
          controller: _controller.textController,
          focusNode: _controller.focusNode,
          onSend: () => _controller.sendTextMessage(widget.roomId),
          showStickers: _controller.showStickers,
          onToggleStickers: _controller.toggleStickers,
          onSendSticker: (url) => _controller.sendSticker(widget.roomId, url),
        ),
      ),
    );
  }
}
