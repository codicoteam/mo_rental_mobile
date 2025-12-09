import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/chat_models/chat_models.dart';
import '../controllers/chat_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatController _controller;
  bool _isTyping = false;
  bool _initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ChatController>();
    
    // Delay the API call to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversation();
    });
    
    // Setup scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadConversation() async {
    try {
      await _controller.fetchConversationById(widget.conversationId);
      setState(() {
        _initialLoadComplete = true;
      });
      
      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error loading conversation: $e');
      Get.snackbar(
        'Error',
        'Failed to load conversation',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _initialLoadComplete = true;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels <= 
        _scrollController.position.minScrollExtent + 100) {
      _controller.loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    setState(() => _isTyping = false);

    final sentMessage = await _controller.sendMessageToConversation(
      conversationId: widget.conversationId,
      content: message,
    );

    if (sentMessage != null) {
      _scrollToBottom();
    }
  }

  void _onMessageChanged(String value) {
    setState(() => _isTyping = value.trim().isNotEmpty);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Clear selected conversation when leaving
    _controller.clearSelectedConversation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final conversation = _controller.selectedConversation.value;
          if (conversation == null) {
            return const Text('Chat');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conversation.title,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '${conversation.participants.length} participants',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show conversation info
              _showConversationInfo();
            },
          ),
        ],
      ),
      body: Obx(() {
        // Show loading only on initial load
        if (!_initialLoadComplete && _controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _controller.error.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadConversation,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final conversation = _controller.selectedConversation.value;
        if (conversation == null && _initialLoadComplete) {
          return const Center(
            child: Text('Conversation not found'),
          );
        }

        return Column(
          children: [
            Expanded(
              child: _buildMessagesList(),
            ),
            _buildMessageInput(),
          ],
        );
      }),
    );
  }

  Widget _buildMessagesList() {
    if (!_initialLoadComplete && _controller.isLoadingMessages.value && _controller.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start the conversation',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: _controller.messages.length + (_controller.hasMoreMessages.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _controller.messages.length) {
          return _buildLoadMoreIndicator();
        }
        
        final message = _controller.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _controller.isLoadingMessages.value
            ? const CircularProgressIndicator()
            : const Text('Load more messages...'),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = _controller.isCurrentUserSender(message);
    final isRead = message.isReadByCurrentUser;
    final hasAttachments = message.attachments != null && message.attachments!.isNotEmpty;
    
    // Check if message is deletable (only sender can delete their own messages)
    final isDeletable = isMe && !message.isDeleted;

    return GestureDetector(
      onLongPress: isDeletable ? () {
  _showDeleteConfirmationDialog(message);
} : null,
      onTap: () {
        // Mark message as read if it's not from current user and not already read
        if (!isMe && !isRead) {
          _controller.markMessageAsRead(message.id); // Use message.id, not conversation.id
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasAttachments) ...[
                      _buildAttachments(message.attachments!),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatMessageTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            isRead ? Icons.done_all : Icons.done,
                            size: 12,
                            color: isRead ? Colors.blue.shade200 : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe)
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments(List<Attachment> attachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attachments.map((attachment) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getAttachmentIcon(attachment.type ?? 'file'),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  attachment.filename ?? 'Attachment',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getAttachmentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
        return Icons.description;
      default:
        return Icons.attach_file;
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              _showAttachmentOptions();
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onChanged: _onMessageChanged,
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          Obx(() {
            if (_controller.isSendingMessage.value) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return IconButton(
              icon: Icon(
                Icons.send,
                color: _isTyping ? Colors.blue : Colors.grey,
              ),
              onPressed: _isTyping ? _sendMessage : null,
            );
          }),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Photo'),
                onTap: () {
                  Get.back();
                  // TODO: Implement image picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  // TODO: Implement camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Document'),
                onTap: () {
                  Get.back();
                  // TODO: Implement document picker
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(ChatMessage message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.deleteMessage(message.id);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

  void _showConversationInfo() {
    final conversation = _controller.selectedConversation.value;
    if (conversation == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Conversation Info'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Title: ${conversation.title}'),
                const SizedBox(height: 8),
                Text('Type: ${conversation.type}'),
                const SizedBox(height: 8),
                Text('Participants: ${conversation.participants.length}'),
                const SizedBox(height: 8),
                Text('Created: ${_formatDateTime(conversation.createdAt)}'),
                const SizedBox(height: 8),
                if (conversation.lastMessageAt != null)
                  Text('Last message: ${_formatDateTime(conversation.lastMessageAt!)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);

    if (messageDay == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}