import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/features/data/services/api_service.dart';
import '../../app/features/data/models/chat_models/chat_models.dart';

class ChatRepository {
  late final ApiService _apiService;
  final GetStorage _storage = GetStorage();

  ChatRepository() {
    _apiService = Get.find<ApiService>();
  }

  // Get auth token
  String? _getAuthToken() {
    return _storage.read('auth_token');
  }

  // Get conversations list - FIXED
  // Get conversations list - STRAIGHT FIX
  Future<List<ChatConversation>> getConversations() async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login.');
      }

      print('📡 Fetching conversations...');

      // BYPASS THE BROKEN ApiService - use http directly
      final url =
          Uri.parse('http://13.61.185.238:5050/api/v1/chats/conversations');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      print('📊 HTTP Response Status: ${response.statusCode}');
      print('📄 HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse.containsKey('data')) {
          final List<dynamic> conversationsData = jsonResponse['data'];
          final conversations = conversationsData
              .map((json) =>
                  ChatConversation.fromJson(json as Map<String, dynamic>))
              .toList();

          print('✅ Successfully loaded ${conversations.length} conversations');
          return conversations;
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Repository error in getConversations: $e');
      rethrow;
    }
  }

  // Get single conversation by ID - FIXED
 // Get single conversation by ID - FIXED
Future<ChatConversation> getConversationById(String conversationId) async {
  try {
    final token = _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    print('📡 Fetching conversation: $conversationId');

    // BYPASS THE BROKEN ApiService - use http directly
    final url = Uri.parse('http://13.61.185.238:5050/api/v1/chats/conversations/$conversationId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    );

    print('📊 HTTP Response Status: ${response.statusCode}');
    print('📄 HTTP Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
        final conversation = ChatConversation.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        print('✅ Successfully loaded conversation: ${conversation.id}');
        return conversation;
      } else {
        throw Exception('API returned success: false');
      }
    } else {
      throw Exception('Request failed with status ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Repository error in getConversationById: $e');
    rethrow;
  }
}

  // Create new conversation - FIXED
  Future<ChatConversation> createConversation(
    CreateConversationRequest request,
  ) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('📤 Creating conversation...');
      print('📦 Request: ${request.toJson()}');

      final response = await _apiService.post<dynamic>(
        '/api/v1/chats/conversations',
        request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Create Conversation Response - Success: ${response.success}');
      print('📊 Create Conversation Response - Message: ${response.message}');
      print('📊 Create Conversation Response - Data: ${response.data}');

      if (response.success && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> data =
              response.data! as Map<String, dynamic>;

          if (data.containsKey('data')) {
            final conversation =
                ChatConversation.fromJson(data['data'] as Map<String, dynamic>);
            print('✅ Conversation created successfully: ${conversation.id}');
            return conversation;
          } else {
            // If data is not nested, use the response directly
            final conversation = ChatConversation.fromJson(data);
            print('✅ Conversation created successfully: ${conversation.id}');
            return conversation;
          }
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to create conversation: ${response.message}');
      }
    } catch (e) {
      print('❌ Repository error in createConversation: $e');
      rethrow;
    }
  }

  // Get messages for a conversation - FIXED
  // Get messages for a conversation - FIXED
Future<List<ChatMessage>> getConversationMessages(
  String conversationId, {
  int page = 1,
  int limit = 50,
}) async {
  try {
    final token = _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    print('📡 Fetching messages for conversation: $conversationId');

    // BYPASS THE BROKEN ApiService - use http directly
    final url = Uri.parse('http://13.61.185.238:5050/api/v1/chats/conversations/$conversationId/messages');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    );

    print('📊 HTTP Response Status: ${response.statusCode}');
    print('📄 HTTP Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        final List<dynamic> messagesData = jsonResponse['data'];
        final messages = messagesData
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
        print('✅ Successfully loaded ${messages.length} messages');
        return messages;
      } else {
        // Try alternative format
        if (jsonResponse.containsKey('messages') && jsonResponse['messages'] is List) {
          final List<dynamic> messagesData = jsonResponse['messages'];
          final messages = messagesData
              .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
              .toList();
          print('✅ Successfully loaded ${messages.length} messages from messages field');
          return messages;
        }
        print('⚠️ No messages data found in response');
        return [];
      }
    } else {
      throw Exception('Request failed with status ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Repository error in getConversationMessages: $e');
    rethrow;
  }
}

  // Send message (old endpoint) - FIXED
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
    List<String>? attachments,
  }) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = {
        'content': content,
        'message_type': messageType,
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments,
      };

      final response = await _apiService.post<dynamic>(
        '/api/v1/chats/conversations/$conversationId/messages',
        body,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.success && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> data =
              response.data! as Map<String, dynamic>;

          if (data.containsKey('data')) {
            return ChatMessage.fromJson(data['data'] as Map<String, dynamic>);
          } else {
            return ChatMessage.fromJson(data);
          }
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to send message: ${response.message}');
      }
    } catch (e) {
      print('❌ Repository error in sendMessage: $e');
      rethrow;
    }
  }

  // Send message to conversation (NEW endpoint) - FIXED
  Future<ChatMessage> sendMessageToConversation(
    SendMessageRequest request,
  ) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('📤 Sending message to conversation: ${request.conversationId}');
      print('📝 Content: ${request.content}');

      final response = await _apiService.post<dynamic>(
        '/api/v1/chats/messages',
        request.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Send Message Response - Success: ${response.success}');
      print('📊 Send Message Response - Message: ${response.message}');
      print('📊 Send Message Response - Data: ${response.data}');

      if (response.success && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> data =
              response.data! as Map<String, dynamic>;

          if (data.containsKey('data')) {
            final message =
                ChatMessage.fromJson(data['data'] as Map<String, dynamic>);
            print('✅ Message sent successfully: ${message.id}');
            return message;
          } else {
            final message = ChatMessage.fromJson(data);
            print('✅ Message sent successfully: ${message.id}');
            return message;
          }
        }
        throw Exception('Invalid response format');
      } else {
        // Handle MongoDB ObjectId error
        if (response.message.contains('Cast to ObjectId failed')) {
          throw Exception(
            'Invalid conversation ID format. Please check the ID and try again.',
          );
        }
        throw Exception('Failed to send message: ${response.message}');
      }
    } catch (e) {
      print('❌ Repository error in sendMessageToConversation: $e');
      rethrow;
    }
  }

  // Get all messages in a conversation - FIXED
  Future<List<ChatMessage>> getMessagesByConversationId(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('📡 Fetching messages for conversation: $conversationId');

      final response = await _apiService.get<dynamic>(
        '/api/v1/chats/conversations/$conversationId/messages',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      print('📊 Get Messages Response - Success: ${response.success}');
      print('📊 Get Messages Response - Data: ${response.data}');

      if (response.success && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> data =
              response.data! as Map<String, dynamic>;

          if (data.containsKey('data') && data['data'] is List) {
            final List<dynamic> messagesData = data['data'] as List<dynamic>;
            final messages = messagesData
                .map((json) =>
                    ChatMessage.fromJson(json as Map<String, dynamic>))
                .toList();
            print(
                '✅ Successfully loaded ${messages.length} messages from data field');
            return messages;
          } else if (data.containsKey('messages') && data['messages'] is List) {
            final List<dynamic> messagesData =
                data['messages'] as List<dynamic>;
            final messages = messagesData
                .map((json) =>
                    ChatMessage.fromJson(json as Map<String, dynamic>))
                .toList();
            print(
                '✅ Successfully loaded ${messages.length} messages from messages field');
            return messages;
          }
        }

        // If response.data is already a list
        if (response.data is List) {
          final List<dynamic> messagesData = response.data as List<dynamic>;
          final messages = messagesData
              .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
              .toList();
          print('✅ Successfully loaded ${messages.length} messages');
          return messages;
        }

        print('⚠️ No messages data found in response');
        return [];
      } else {
        throw Exception('Failed to load messages: ${response.message}');
      }
    } catch (e) {
      print('❌ Repository error in getMessagesByConversationId: $e');
      rethrow;
    }
  }

  // Mark message as read - FIXED
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _apiService.put<dynamic>(
        '/api/v1/chats/messages/$messageId/read',
        {},
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.success) {
        print('✅ Message marked as read: $messageId');
        return true;
      } else {
        print('❌ Failed to mark message as read: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ Repository error in markMessageAsRead: $e');
      return false;
    }
  }

  // Delete message - FIXED
  Future<bool> deleteMessage(String messageId) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _apiService.delete<dynamic>(
        '/api/v1/chats/messages/$messageId',
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      if (response.success) {
        print('✅ Message deleted: $messageId');
        return true;
      } else {
        print('❌ Failed to delete message: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ Repository error in deleteMessage: $e');
      return false;
    }
  }
}
