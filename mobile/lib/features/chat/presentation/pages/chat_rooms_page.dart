import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/models/chat_room_model.dart';
import 'chat_detail_page.dart';

class ChatRoomsPage extends StatefulWidget {
  const ChatRoomsPage({super.key});

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  final ChatRemoteDatasource _datasource = ChatRemoteDatasource();
  List<ChatRoomModel>? _rooms;
  bool _loading = true;

  String? _lastToken;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = Provider.of<AuthProvider>(context).accessToken;
    if (token != _lastToken) {
      _lastToken = token;
      if (token != null) {
        setState(() { _loading = true; });
        _fetchRooms(token);
      } else {
        setState(() {
          _rooms = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchRooms(String token) async {
    try {
      final list = await _datasource.listRooms(token: token);
      if (mounted) setState(() { _rooms = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _refreshRooms() async {
    final token = _lastToken;
    if (token == null) return;
    await _fetchRooms(token);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    return Scaffold(
      backgroundColor: IndieFolkTheme.surface(isDark),
      appBar: AppBar(
        title: Text(isVi ? 'Hội thoại' : 'Conversations', style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 22)),
        backgroundColor: IndieFolkTheme.surface(isDark),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_rooms == null || _rooms!.isEmpty)
              ? Center(child: Text(isVi ? 'Chưa có cuộc trò chuyện nào' : 'No active chats yet', style: IndieFolkTheme.body(isDark)))
              : RefreshIndicator(
                  onRefresh: _refreshRooms,
                  child: ListView.separated(
                    itemCount: _rooms!.length,
                    separatorBuilder: (_, __) => Divider(color: IndieFolkTheme.secondary(isDark).withOpacity(0.2)),
                    itemBuilder: (context, idx) {
                      final room = _rooms![idx];
                      return ListTile(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                roomId: room.id,
                                partnerName: room.partnerName,
                                partnerAvatar: room.partnerAvatar,
                              ),
                            ),
                          );
                          _refreshRooms();
                        },
                        leading: CircleAvatar(
                          backgroundImage: (room.partnerAvatar.isNotEmpty && !room.partnerAvatar.toLowerCase().endsWith('.svg'))
                              ? NetworkImage(ApiConstants.resolveImageUrl(room.partnerAvatar))
                              : null,
                          child: (room.partnerAvatar.isEmpty || room.partnerAvatar.toLowerCase().endsWith('.svg'))
                              ? const Icon(Icons.person, size: 24)
                              : null,
                          radius: 24,
                        ),
                        title: Text(room.partnerName, style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 16)),
                        subtitle: Text(
                          room.lastMessage.isNotEmpty ? room.lastMessage : (isVi ? 'Chưa có tin nhắn' : 'No messages yet'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: IndieFolkTheme.body(isDark).copyWith(fontSize: 14, color: IndieFolkTheme.secondary(isDark)),
                        ),
                        trailing: room.unreadCount > 0
                            ? CircleAvatar(
                                radius: 10,
                                backgroundColor: IndieFolkTheme.tertiary(isDark),
                                child: Text('${room.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            : null,
                      );
                    },
                  ),
                ),
    );
  }
}
