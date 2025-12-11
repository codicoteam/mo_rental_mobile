import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../app/features/data/models/chat_models/chat_models.dart';

class ChatRepository {
  final GetStorage _storage = GetStorage();

  ChatRepository();

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
      final url = Uri.parse(
          'http://13.61.185.238:5050/api/v1/chats/conversations/$conversationId');
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
          final conversation = ChatConversation.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);
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

      // BYPASS THE BROKEN ApiService - use http directly
      final url =
          Uri.parse('http://13.61.185.238:5050/api/v1/chats/conversations');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📊 HTTP Response Status: ${response.statusCode}');
      print('📄 HTTP Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse.containsKey('data')) {
          final conversation = ChatConversation.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);
          print('✅ Conversation created successfully: ${conversation.id}');
          return conversation;
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Request failed with status ${response.statusCode}');
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
      final url = Uri.parse(
          'http://13.61.185.238:5050/api/v1/chats/conversations/$conversationId/messages');
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
            jsonResponse.containsKey('data') &&
            jsonResponse['data'] is List) {
          final List<dynamic> messagesData = jsonResponse['data'];
          final messages = messagesData
              .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
              .toList();
          print('✅ Successfully loaded ${messages.length} messages');
          return messages;
        } else {
          // Try alternative format
          if (jsonResponse.containsKey('messages') &&
              jsonResponse['messages'] is List) {
            final List<dynamic> messagesData = jsonResponse['messages'];
            final messages = messagesData
                .map((json) =>
                    ChatMessage.fromJson(json as Map<String, dynamic>))
                .toList();
            print(
                '✅ Successfully loaded ${messages.length} messages from messages field');
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

      // BYPASS THE BROKEN ApiService - use http directly
      final url = Uri.parse(
          'http://13.61.185.238:5050/api/v1/chats/conversations/$conversationId/messages');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('📊 HTTP Response Status: ${response.statusCode}');
      print('📄 HTTP Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse.containsKey('data')) {
          return ChatMessage.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Repository error in sendMessage: $e');
      rethrow;
    }
  }

  // Send message to conversation (NEW endpoint) - FIXED
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

      // BYPASS THE BROKEN ApiService - use http directly
      final url = Uri.parse('http://13.61.185.238:5050/api/v1/chats/messages');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📊 HTTP Response Status: ${response.statusCode}');
      print('📄 HTTP Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse.containsKey('data')) {
          final message = ChatMessage.fromJson(
              jsonResponse['data'] as Map<String, dynamic>);
          print('✅ Message sent successfully: ${message.id}');
          return message;
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Repository error in sendMessageToConversation: $e');
      rethrow;
    }
  }

  // Get all messages in a conversation - FIXED
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

      // BYPASS THE BROKEN ApiService - use http directly
      final url = Uri.parse(
          'http://13.61.185.238:5050/api/v1/chats/conversations/$conversationId/messages');
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
            jsonResponse.containsKey('data') &&
            jsonResponse['data'] is List) {
          final List<dynamic> messagesData = jsonResponse['data'];
          final messages = messagesData
              .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
              .toList();
          print('✅ Successfully loaded ${messages.length} messages');
          return messages;
        } else {
          // Try alternative format
          if (jsonResponse.containsKey('messages') &&
              jsonResponse['messages'] is List) {
            final List<dynamic> messagesData = jsonResponse['messages'];
            final messages = messagesData
                .map((json) =>
                    ChatMessage.fromJson(json as Map<String, dynamic>))
                .toList();
            print(
                '✅ Successfully loaded ${messages.length} messages from messages field');
            return messages;
          }
          print('⚠️ No messages data found in response');
          return [];
        }
      } else {
        throw Exception('Request failed with status ${response.statusCode}');
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

      // Validate that messageId is a valid ObjectId (24-character hex string)
      if (!_isValidObjectId(messageId)) {
        print('❌ Invalid message ID format: $messageId');
        throw Exception(
            'Invalid message ID format. Must be a 24-character hex string.');
      }

      print('📤 Marking message as read: $messageId');

      // BYPASS THE BROKEN ApiService - use http directly
      // Use POST method as shown in the Swagger documentation
      final url = Uri.parse(
          'http://13.61.185.238:5050/api/v1/chats/messages/$messageId/read');
      final response = await http.post(
        // Changed from .put to .post
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      print('📊 HTTP Response Status: ${response.statusCode}');
      print('📄 HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          print('✅ Message marked as read: $messageId');
          return true;
        } else {
          print('❌ Failed to mark message as read: ${jsonResponse['message']}');
          return false;
        }
      } else {
        print('❌ Request failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Repository error in markMessageAsRead: $e');
      return false;
    }
  }

// Delete message - FIXED
// In ChatRepository class - FIXED deleteMessage method
Future<bool> deleteMessage(String messageId) async {
  try {
    final token = _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    // IMPORTANT: Don't validate ObjectId format here - let the backend handle it
    // The backend error shows it's expecting an ObjectId, so we need to ensure
    // we're passing a valid message ID, not a conversation ID
    print('🗑️ Deleting message with ID: $messageId');

    // BYPASS THE BROKEN ApiService - use http directly
    final url = Uri.parse(
        'http://13.61.185.238:5050/api/v1/chats/messages/$messageId');
    final response = await http.delete(
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

      if (jsonResponse['success'] == true) {
        print('✅ Message deleted successfully: $messageId');
        return true;
      } else {
        print('❌ Failed to delete message: ${jsonResponse['message']}');
        return false;
      }
    } else {
      print('❌ Request failed with status ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('❌ Repository error in deleteMessage: $e');
    return false;
  }
}

// Helper method to validate MongoDB ObjectId
  bool _isValidObjectId(String id) {
    // MongoDB ObjectId is a 24-character hex string
    final regex = RegExp(r'^[0-9a-fA-F]{24}$');
    return regex.hasMatch(id);
  }
}
