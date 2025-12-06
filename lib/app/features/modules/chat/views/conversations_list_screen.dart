import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../domain/repositories/chat_repository.dart';
import '../../../data/models/chat_models/chat_models.dart';
import '../../../data/services/api_service.dart';
import '../../bindings/chat_binding.dart';
import '../controllers/chat_controller.dart';
import 'chat_detail_screen.dart';
import 'create_conversation_screen.dart';

class ConversationsListScreen extends StatelessWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already done
    if (!Get.isRegistered<ChatController>()) {
      // Make sure ApiService is available
      if (!Get.isRegistered<ApiService>()) {
        Get.put(ApiService(), permanent: true);
      }
      
      // Make sure ChatRepository is available
      if (!Get.isRegistered<ChatRepository>()) {
        Get.put(ChatRepository(), permanent: true);
      }
      
      // Initialize ChatController
      Get.put(ChatController(), permanent: true);
    }
    
    final ChatController controller = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchConversations,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => const CreateConversationScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controller.error.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchConversations,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // In your ConversationsListScreen build method:
if (controller.conversations.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.chat, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'No conversations yet',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const Text(
          'Start a new conversation to begin chatting',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            Get.to(() => const CreateConversationScreen());
          },
          icon: const Icon(Icons.add),
          label: const Text('New Conversation'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: controller.fetchConversations,
          child: const Text('Refresh'),
        ),
      ],
    ),
  );
}
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.conversations.length,
          itemBuilder: (context, index) {
            final conversation = controller.conversations[index];
            return _buildConversationTile(conversation);
          },
        );
      }),
    );
  }

  Widget _buildConversationTile(ChatConversation conversation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            conversation.title[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          conversation.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conversation.lastMessagePreview != null)
              Text(
                conversation.lastMessagePreview!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 4),
            Text(
              'Participants: ${conversation.participants.length}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (conversation.lastMessageAt != null)
              Text(
                _formatTime(conversation.lastMessageAt!),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            if (conversation.isArchived)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Archived',
                  style: TextStyle(fontSize: 8),
                ),
              ),
          ],
        ),
        onTap: () {
          Get.to(
            () => ChatDetailScreen(conversationId: conversation.id),
            binding: ChatBinding(),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}