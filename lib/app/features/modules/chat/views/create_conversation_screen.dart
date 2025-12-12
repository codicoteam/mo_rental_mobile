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

      String? contextType;
      String? contextId;
      
      if (_selectedContextType != null && 
          _selectedContextType!.isNotEmpty &&
          _contextIdController.text.trim().isNotEmpty) {
        contextType = _selectedContextType;
        contextId = _contextIdController.text.trim();
      }

      final conversation = await _controller.createConversation(
        title: _titleController.text.trim(),
        participantIds: _participants,
        type: _selectedType ?? 'direct',
        contextType: contextType,
        contextId: contextId,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A1A)),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          'New Conversation',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF047BC1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.check_rounded, color: Colors.white),
              onPressed: _createConversation,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversation Title',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0.1,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g., Support - Damaged Tyre',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Color(0xFF047BC1),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.red.shade300,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 28),
              
              // Participants Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Participants',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Color(0xFF047BC1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF047BC1),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _participantController,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter participant ID',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Color(0xFF047BC1),
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF047BC1).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add_rounded, color: Colors.white, size: 24),
                          onPressed: _addParticipant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Participants List
              if (_participants.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: 18,
                            color: Color(0xFF047BC1),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Added Participants (${_participants.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _participants.map((participant) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF047BC1).withOpacity(0.15),
                                  Color(0xFF4F46E5).withOpacity(0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(0xFF047BC1).withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  participant,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF047BC1),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _removeParticipant(participant),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: Color(0xFF047BC1),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 28),
              
              // Type Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conversation Type',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0.1,
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Color(0xFF047BC1),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
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
                ],
              ),
              
              SizedBox(height: 28),
              
              // Context Type Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Context Type',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedContextType,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Color(0xFF047BC1),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
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
                        if (value == null) {
                          _contextIdController.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 28),
              
              // Context ID Field
              if (_selectedContextType != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedContextType!.toUpperCase()} ID',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _contextIdController,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter the ID',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Color(0xFF047BC1),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF4F46E5).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF4F46E5).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Color(0xFF4F46E5),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Must be a valid ObjectId format (24-character hex string)',
                              style: TextStyle(
                                color: Color(0xFF4F46E5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              
              SizedBox(height: 36),
              
              // Create Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF047BC1).withOpacity(0.35),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _createConversation,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Obx(() {
                        if (_controller.isLoading.value) {
                          return SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          );
                        }
                        return Text(
                          'Create Conversation',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Information Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF047BC1).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 20,
                            color: Color(0xFF047BC1),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'About Context Fields',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildInfoItem('Context Type and Context ID are optional'),
                    SizedBox(height: 10),
                    _buildInfoItem('Only provide them if this chat is related to a specific entity'),
                    SizedBox(height: 10),
                    _buildInfoItem('If you provide Context Type, you must also provide Context ID'),
                    SizedBox(height: 10),
                    _buildInfoItem(
                      'Context ID must be a valid ObjectId (e.g., 665a8c7be4f1c23b04d12345)',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isHighlight ? Color(0xFF4F46E5) : Color(0xFF047BC1),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isHighlight ? Color(0xFF4F46E5) : Colors.grey.shade700,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}