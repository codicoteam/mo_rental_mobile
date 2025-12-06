import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class Participant {
  final String userId;
  final String roleAtTime;
  final DateTime joinedAt;

  Participant({
    required this.userId,
    required this.roleAtTime,
    required this.joinedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user_id'] ?? '',
      roleAtTime: json['role_at_time'] ?? '',
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role_at_time': roleAtTime,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

class ChatConversation {
  final String id;
  final String title;
  final List<Participant> participants;
  final String type;
  final String? contextType;
  final String? contextId;
  final String createdBy;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation({
    required this.id,
    required this.title,
    required this.participants,
    required this.type,
    this.contextType,
    this.contextId,
    required this.createdBy,
    this.lastMessageAt,
    this.lastMessagePreview,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => Participant.fromJson(p))
          .toList() ?? [],
      type: json['type'] ?? '',
      contextType: json['context_type'],
      contextId: json['context_id'],
      createdBy: json['created_by'] ?? '',
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      lastMessagePreview: json['last_message_preview'],
      isArchived: json['is_archived'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participants': participants.map((p) => p.toJson()).toList(),
      'type': type,
      'context_type': contextType,
      'context_id': contextId,
      'created_by': createdBy,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message_preview': lastMessagePreview,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CreateConversationRequest {
  final String? title;
  final List<String>? participantIds;
  final String? type;
  final String? contextType;
  final String? contextId;

  CreateConversationRequest({
    this.title,
    this.participantIds,
    this.type,
    this.contextType,
    this.contextId,
  });

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) {
    return CreateConversationRequest(
      title: json['title'],
      participantIds: json['participant_ids'] == null
          ? null
          : List<String>.from(json['participant_ids']!),
      type: json['type'],
      contextType: json['context_type'],
      contextId: json['context_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'participant_ids': participantIds,
      'type': type,
      'context_type': contextType,
      'context_id': contextId,
    };
  }
}

class Attachment {
  final String? type;
  final String? url;
  final String? filename;

  Attachment({
    this.type,
    this.url,
    this.filename,
  });

  factory Attachment.fromRawJson(String str) => Attachment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    type: json["type"],
    url: json["url"],
    filename: json["filename"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "url": url,
    "filename": filename,
  };
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType;
  final List<Attachment>? attachments;
  final List<String>? readBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.attachments,
    this.readBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      messageType: json['message_type'] ?? 'text',
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => Attachment.fromJson(a))
              .toList()
          : null,
      readBy: json['read_by'] != null
          ? List<String>.from(json['read_by'])
          : null,
      isDeleted: json['is_deleted'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'read_by': readBy,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isReadByCurrentUser {
    final currentUserId = GetStorage().read('user_data')?['_id'] ?? '';
    return readBy?.contains(currentUserId) ?? false;
  }
}

class SendMessageRequest {
  final String conversationId;
  final String content;
  final List<Attachment>? attachments;

  SendMessageRequest({
    required this.conversationId,
    required this.content,
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'content': content,
      if (attachments != null && attachments!.isNotEmpty)
        'attachments': attachments!.map((a) => a.toJson()).toList(),
    };
  }
}

class MessagesResponse {
  final bool success;
  final String message;
  final ChatMessage? data;

  MessagesResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ChatMessage.fromJson(json['data']) : null,
    );
  }
}

class MessagesListResponse {
  final bool success;
  final String message;
  final List<ChatMessage> data;

  MessagesListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MessagesListResponse.fromJson(Map<String, dynamic> json) {
    return MessagesListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ChatMessage.fromJson(item))
          .toList() ?? [],
    );
  }
}