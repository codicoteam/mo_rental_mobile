import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../bindings/chat_binding.dart';
import '../controllers/chat_controller.dart';
import 'chat_detail_screen.dart';

class CreateConversationScreen extends StatefulWidget {
  const CreateConversationScreen({super.key});

  @override
  State<CreateConversationScreen> createState() =>
      _CreateConversationScreenState();
}

class _CreateConversationScreenState extends State<CreateConversationScreen> {
  final ChatController _controller = Get.find<ChatController>();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _participantController = TextEditingController();
  final TextEditingController _contextIdController = TextEditingController();
  
  String? _selectedType = 'direct';
  String? _selectedContextType;
  
  final List<String> _participants = [];

  @override
  void dispose() {
    _titleController.dispose();
    _participantController.dispose();
    _contextIdController.dispose();
    super.dispose();
  }

  Future<void> _createConversation() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (_participants.isEmpty) {
        Get.snackbar(
          'Error',
          'Please add at least one participant',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // FIXED: Only include context if BOTH contextType AND contextId are provided
      String? contextType;
      String? contextId;
      
      if (_selectedContextType != null && 
          _selectedContextType!.isNotEmpty &&
          _contextIdController.text.trim().isNotEmpty) {
        contextType = _selectedContextType;
        contextId = _contextIdController.text.trim();
      }
      // Otherwise both will be null (not sent to API)

      final conversation = await _controller.createConversation(
        title: _titleController.text.trim(),
        participantIds: _participants,
        type: _selectedType ?? 'direct',
        contextType: contextType, // Will be null if not provided
        contextId: contextId,     // Will be null if not provided
      );

      if (conversation != null) {
        Get.back();
        Get.to(
          () => ChatDetailScreen(conversationId: conversation.id),
          binding: ChatBinding(),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _addParticipant() {
    final participant = _participantController.text.trim();
    if (participant.isNotEmpty && !_participants.contains(participant)) {
      setState(() {
        _participants.add(participant);
        _participantController.clear();
      });
    }
  }

  void _removeParticipant(String participant) {
    setState(() {
      _participants.remove(participant);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Conversation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _createConversation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  hintText: 'e.g., Support - Damaged Tyre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Participants
              const Text(
                'Participants*',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _participantController,
                      decoration: const InputDecoration(
                        hintText: 'Enter participant ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addParticipant,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Participants list
              if (_participants.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Added participants:'),
                    Wrap(
                      spacing: 8,
                      children: _participants.map((participant) {
                        return Chip(
                          label: Text(participant),
                          onDeleted: () => _removeParticipant(participant),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              
              // Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'direct',
                    child: Text('Direct Message'),
                  ),
                  DropdownMenuItem(
                    value: 'group',
                    child: Text('Group Chat'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // Context Type
              DropdownButtonFormField<String>(
                value: _selectedContextType,
                decoration: const InputDecoration(
                  labelText: 'Context Type (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('None'),
                  ),
                  DropdownMenuItem(
                    value: 'reservation',
                    child: Text('Reservation'),
                  ),
                  DropdownMenuItem(
                    value: 'support',
                    child: Text('Support Ticket'),
                  ),
                  DropdownMenuItem(
                    value: 'booking',
                    child: Text('Booking'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedContextType = value;
                    // Clear context ID when context type changes
                    if (value == null) {
                      _contextIdController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // Context ID (only shown when context type is selected)
              if (_selectedContextType != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _contextIdController,
                      decoration: InputDecoration(
                        labelText: '${_selectedContextType!.toUpperCase()} ID',
                        hintText: 'Enter the ID',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Note: This ID should be a valid ObjectId format (24-character hex string)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 30),
              
              // Create button
              ElevatedButton(
                onPressed: _createConversation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Obx(() {
                  if (_controller.isLoading.value) {
                    return const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    );
                  }
                  return const Text(
                    'Create Conversation',
                    style: TextStyle(fontSize: 16),
                  );
                }),
              ),
              
              // Information text
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About Context Fields:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Context Type and Context ID are optional',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• Only provide them if this chat is related to a specific entity',
                      style: TextStyle(fontSize: 12),
                    ),
                    const Text(
                      '• If you provide Context Type, you must also provide Context ID',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Context ID must be a valid ObjectId (e.g., 665a8c7be4f1c23b04d12345)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}