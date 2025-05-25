import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class MessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const MessageScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  late final Stream<List<Map<String, dynamic>>> _messagesStream;
  final ScrollController _scrollController = ScrollController();

  String get currentUserId => supabase.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _messagesStream = _setupRealtimeUpdates();
    fetchMessages();
  }

  // Convert UTC time to Indonesia time (WIB: UTC+7)
  DateTime _toIndonesiaTime(DateTime utcTime) {
    return utcTime.add(const Duration(hours: 7));
  }

  // Format time to HH:mm (24-hour format)
  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Format date based on conditions (today/yesterday/other)
  String _formatMessageTime(String? isoTime) {
    if (isoTime == null) return '';

    final utcTime = DateTime.parse(isoTime);
    final indonesiaTime = _toIndonesiaTime(utcTime);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(indonesiaTime.year, indonesiaTime.month, indonesiaTime.day);
    final diff = today.difference(messageDate).inDays;

    if (diff == 0) {
      return _formatTime(indonesiaTime);
    } else if (diff == 1) {
      return 'Kemarin ${_formatTime(indonesiaTime)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(indonesiaTime);
    }
  }

  Stream<List<Map<String, dynamic>>> _setupRealtimeUpdates() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((messages) => messages.where((msg) {
      return (msg['sender_id'] == currentUserId &&
          msg['receiver_id'] == widget.receiverId) ||
          (msg['sender_id'] == widget.receiverId &&
              msg['receiver_id'] == currentUserId);
    }).toList());
  }

  Future<void> fetchMessages() async {
    try {
      final response = await supabase
          .from('messages')
          .select()
          .or('and(sender_id.eq.$currentUserId,receiver_id.eq.${widget.receiverId})')
          .or('and(sender_id.eq.${widget.receiverId},receiver_id.eq.$currentUserId)')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pesan: ${e.toString()}')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await supabase.from('messages').insert({
        'sender_id': currentUserId,
        'receiver_id': widget.receiverId,
        'message': text,
      });
      _messageController.clear();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat dengan ${widget.receiverName}'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                final messages = snapshot.data ?? this.messages;
                return messages.isEmpty
                    ? const Center(child: Text('Belum ada pesan'))
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isSent = msg['sender_id'] == currentUserId;
                    return _buildMessageBubble(
                      msg['message'],
                      isSent: isSent,
                      time: msg['created_at'],
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, {required bool isSent, String? time}) {
    final timeStr = _formatMessageTime(time);

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSent ? Colors.orange[100] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isSent ? const Radius.circular(20) : Radius.zero,
            bottomRight: isSent ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message),
            if (timeStr.isNotEmpty)
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.orange,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}