import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../domain/repositories/chat_repository.dart';
import '../../../data/models/chat_models/chat_models.dart';

class ChatController extends GetxController {
  late ChatRepository _repository;
  late GetStorage _storage;

  final RxList<ChatConversation> conversations = <ChatConversation>[].obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final Rx<ChatConversation?> selectedConversation =
      Rx<ChatConversation?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSendingMessage = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxString currentConversationId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _repository = Get.find<ChatRepository>();
    _storage = GetStorage();
    print('🎮 ChatController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    fetchConversations();
  }

  // Fetch conversations
  Future<void> fetchConversations() async {
    try {
      isLoading.value = true;
      error.value = '';

      final conversationList = await _repository.getConversations();
      conversations.value = conversationList;

      print('✅ Controller: Loaded ${conversationList.length} conversations');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error fetching conversations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch single conversation
  Future<void> fetchConversationById(String conversationId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final conversation =
          await _repository.getConversationById(conversationId);
      selectedConversation.value = conversation;

      // Also fetch messages
      await fetchMessages(conversationId);
    } catch (e) {
      error.value = e.toString();
      print('❌ Error fetching conversation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch messages for conversation
  Future<void> fetchMessages(String conversationId,
      {bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoadingMessages.value = true;
        currentPage.value = 1;
        messages.clear();
      } else {
        currentPage.value++;
      }

      error.value = '';
      currentConversationId.value = conversationId;

      final messageList = await _repository.getConversationMessages(
        conversationId,
        page: currentPage.value,
        limit: 20,
      );

      if (loadMore) {
        messages.addAll(messageList);
      } else {
        messages.value = messageList;
      }

      // Check if there are more messages to load
      hasMoreMessages.value = messageList.length >= 20;

      print(
          '✅ Controller: Loaded ${messages.length} messages for conversation $conversationId');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error fetching messages: $e');

      if (!loadMore) {
        messages.clear();
      }
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // Create new conversation
  Future<ChatConversation?> createConversation({
    String? title,
    List<String>? participantIds,
    String? type = 'direct',
    String? contextType,
    String? contextId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final request = CreateConversationRequest(
        title: title,
        participantIds: participantIds,
        type: type,
        contextType: contextType,
        contextId: contextId,
      );

      final conversation = await _repository.createConversation(request);

      // Add to list
      conversations.insert(0, conversation);
      selectedConversation.value = conversation;

      return conversation;
    } catch (e) {
      error.value = e.toString();
      print('❌ Error creating conversation: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Send message (original version - keeping your existing method signature)
  Future<ChatMessage?> sendMessage({
    required String content,
    String messageType = 'text',
    List<String>? attachments,
  }) async {
    try {
      if (selectedConversation.value == null) {
        throw Exception('No conversation selected');
      }

      isSendingMessage.value = true;
      error.value = '';

      final message = await _repository.sendMessage(
        conversationId: selectedConversation.value!.id,
        content: content,
        messageType: messageType,
        attachments: attachments,
      );

      // Add to messages list (insert at beginning for chronological order)
      messages.insert(0, message);

      // Update conversation's last message preview
      final updatedConversation = selectedConversation.value!.copyWith(
        lastMessagePreview:
            content.length > 50 ? '${content.substring(0, 50)}...' : content,
        lastMessageAt: DateTime.now(),
      );
      selectedConversation.value = updatedConversation;

      print('✅ Message sent successfully: ${message.id}');
      return message;
    } catch (e) {
      error.value = e.toString();
      print('❌ Error sending message: $e');

      // Show error notification
      Get.snackbar(
        'Failed to Send',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return null;
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Send message with conversation ID parameter (alternative version)
  Future<ChatMessage?> sendMessageToConversation({
    required String conversationId,
    required String content,
    List<Attachment>? attachments,
  }) async {
    try {
      isSendingMessage.value = true;
      error.value = '';

      final request = SendMessageRequest(
        conversationId: conversationId,
        content: content,
        attachments: attachments,
      );

      final message = await _repository.sendMessageToConversation(request);

      // If this is the current conversation, add to messages list
      if (selectedConversation.value?.id == conversationId) {
        messages.insert(0, message);

        // Update conversation's last message preview
        final updatedConversation = selectedConversation.value?.copyWith(
          lastMessagePreview:
              content.length > 50 ? '${content.substring(0, 50)}...' : content,
          lastMessageAt: DateTime.now(),
        );
        selectedConversation.value = updatedConversation;
      }

      // Also update the conversation in the conversations list
      final index =
          conversations.indexWhere((conv) => conv.id == conversationId);
      if (index != -1) {
        final updatedConv = conversations[index].copyWith(
          lastMessagePreview:
              content.length > 50 ? '${content.substring(0, 50)}...' : content,
          lastMessageAt: DateTime.now(),
        );
        conversations[index] = updatedConv;
      }

      print('✅ Message sent successfully: ${message.id}');
      return message;
    } catch (e) {
      error.value = e.toString();
      print('❌ Error sending message: $e');

      // Show specific error for ObjectId format
      if (e.toString().contains('Invalid conversation ID format')) {
        Get.snackbar(
          'Invalid Conversation ID',
          'The conversation ID format is incorrect. Please check and try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Failed to Send',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return null;
    } finally {
      isSendingMessage.value = false;
    }
  }

 // Mark message as read - CORRECTED
Future<void> markMessageAsRead(String messageId) async {
  try {
    // Validate that we have a proper message ID (not conversation ID)
    if (messageId.contains('conv') || !_isValidObjectId(messageId)) {
      print('⚠️ Invalid message ID format: $messageId');
      return;
    }
    
    await _repository.markMessageAsRead(messageId);
    
    // Update local message state
    final index = messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final message = messages[index];
      final currentUserId = _getCurrentUserId();
      final updatedReadBy = List<String>.from(message.readBy ?? [])..add(currentUserId);
      final updatedMessage = ChatMessage(
        id: message.id,
        conversationId: message.conversationId,
        senderId: message.senderId,
        content: message.content,
        messageType: message.messageType,
        attachments: message.attachments,
        readBy: updatedReadBy,
        isDeleted: message.isDeleted,
        createdAt: message.createdAt,
        updatedAt: DateTime.now(),
      );
      messages[index] = updatedMessage;
    }
  } catch (e) {
    print('❌ Error marking message as read: $e');
  }
}

// Helper method to validate MongoDB ObjectId
bool _isValidObjectId(String id) {
  final regex = RegExp(r'^[0-9a-fA-F]{24}$');
  return regex.hasMatch(id);
}
  // Delete message
// In ChatController - Update deleteMessage method to refresh messages after deletion
Future<bool> deleteMessage(String messageId) async {
  try {
    print('\n🎮 ========== ATTEMPTING TO DELETE MESSAGE ==========');
    print('🎮 Message ID to delete: $messageId');
    
    // Find the message in local list
    final message = getMessageById(messageId);
    if (message == null) {
      print('❌ Message not found in local messages list');
      Get.snackbar(
        'Error',
        'Message not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    // Check if user is the sender
    if (!isCurrentUserSender(message)) {
      print('❌ User is not the sender, cannot delete this message');
      Get.snackbar(
        'Not Allowed',
        'You can only delete your own messages',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    
    print('🔄 Calling repository.deleteMessage($messageId)');
    
    final success = await _repository.deleteMessage(messageId);
    
    if (success) {
      print('✅ Repository returned success');
      
      // REFRESH THE MESSAGES FROM SERVER
      if (currentConversationId.value.isNotEmpty) {
        print('🔄 Refreshing messages from server...');
        await fetchMessages(currentConversationId.value);
      }
      
      Get.snackbar(
        'Success',
        'Message deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      print('❌ Repository returned failure');
      Get.snackbar(
        'Error',
        'Failed to delete message',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    
    return success;
  } catch (e) {
    print('🔥 Error deleting message: $e');
    Get.snackbar(
      'Error',
      'Failed to delete message: ${e.toString()}',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  }
}

  // Load more messages
  Future<void> loadMoreMessages() async {
    if (hasMoreMessages.value &&
        !isLoadingMessages.value &&
        currentConversationId.value.isNotEmpty) {
      await fetchMessages(currentConversationId.value, loadMore: true);
    }
  }

  // Search conversations
  List<ChatConversation> searchConversations(String query) {
    if (query.isEmpty) return conversations;

    return conversations.where((conversation) {
      return conversation.title.toLowerCase().contains(query.toLowerCase()) ||
          (conversation.lastMessagePreview
                  ?.toLowerCase()
                  .contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  // Clear selected conversation
  void clearSelectedConversation() {
    selectedConversation.value = null;
    clearMessages();
  }

  // Clear messages
  void clearMessages() {
    messages.clear();
    currentConversationId.value = '';
    currentPage.value = 1;
    hasMoreMessages.value = true;
  }

  // Get current user ID
  String _getCurrentUserId() {
    final userData = _storage.read('user_data') ?? {};
    return userData['_id'] ?? '';
  }

  // Check if user is sender of message
  bool isCurrentUserSender(ChatMessage message) {
    return message.senderId == _getCurrentUserId();
  }

  // Get message by ID
  ChatMessage? getMessageById(String messageId) {
    return messages.firstWhereOrNull((msg) => msg.id == messageId);
  }

  // Update message locally
  void updateMessage(ChatMessage updatedMessage) {
    final index = messages.indexWhere((msg) => msg.id == updatedMessage.id);
    if (index != -1) {
      messages[index] = updatedMessage;
    }
  }

  // Get unread message count for a conversation
  int getUnreadCount(String conversationId) {
    final currentUserId = _getCurrentUserId();
    return messages.where((message) {
      return message.conversationId == conversationId &&
          !(message.readBy?.contains(currentUserId) ?? false) &&
          message.senderId != currentUserId;
    }).length;
  }
}

// Extension for updating conversation
extension ChatConversationExtension on ChatConversation {
  ChatConversation copyWith({
    String? title,
    List<Participant>? participants,
    String? type,
    String? contextType,
    String? contextId,
    String? createdBy,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatConversation(
      id: id,
      title: title ?? this.title,
      participants: participants ?? this.participants,
      type: type ?? this.type,
      contextType: contextType ?? this.contextType,
      contextId: contextId ?? this.contextId,
      createdBy: createdBy ?? this.createdBy,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
