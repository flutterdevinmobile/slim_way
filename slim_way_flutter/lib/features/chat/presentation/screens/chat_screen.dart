import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_flutter/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/features/home/presentation/blocs/summary_bloc/summary_bloc.dart';
import 'package:slim_way_client/slim_way_client.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    
    final summaryState = context.read<SummaryBloc>().state;
    DailyLog? dailyLog;
    if (summaryState is SummarySuccess) {
      dailyLog = summaryState.summary;
    }
    
    context.read<ChatBloc>().add(ChatMessageSent(text,
        dailyLog: dailyLog, languageCode: context.locale.languageCode));

    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return BlocBuilder<ChatBloc, ChatState>(
          builder: (context, chatState) {
            final messages = chatState.chatMessages;

            return Scaffold(
              appBar: AppBar(
                title: Text('chat.title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: messages.isEmpty 
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _buildMessageBubble(message.text, message.isUser, isDark);
                          },
                        ),
                  ),
                  if (chatState is ChatPrepare) _buildThinkingIndicator(),
                  _buildSuggestedActions(isDark),
                  _buildInputArea(isDark),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestedActions(bool isDark) {
    final summaryState = context.read<SummaryBloc>().state;
    if (summaryState is! SummarySuccess) return const SizedBox.shrink();
    
    final log = summaryState.summary;
    final suggestions = <String>[];

    if (log == null) {
      suggestions.add("chat.suggest.goals");
      suggestions.add("chat.suggest.first_meal");
    } else {
      if ((log.waterMl ?? 0) < 1000) suggestions.add("chat.suggest.water");
      if (log.foodCal > 2000) suggestions.add("chat.suggest.calories");
      if ((log.protein ?? 0) < 50) suggestions.add("chat.suggest.protein");
      suggestions.add("chat.suggest.analyze");
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ActionChip(
              label: Text(suggestions[index].tr(),
                  style: const TextStyle(fontSize: 12)),
              backgroundColor: AppTheme.green.withValues(alpha: 0.05),
              side: BorderSide(color: AppTheme.green.withValues(alpha: 0.1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                context.read<ChatBloc>().add(ChatMessageSent(suggestions[index].tr(),
                    dailyLog: log,
                    languageCode: context.locale.languageCode));
                _scrollToBottom();
              },
            ),
          );
        },
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppTheme.green.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, size: 64, color: AppTheme.green),
          ),
          const SizedBox(height: 24),
          Text(
            'chat.empty_title'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'chat.empty_msg'.tr(),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.green : (isDark ? AppTheme.darkGray : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 12, height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.green),
          ),
          const SizedBox(width: 12),
          Text('chat.thinking'.tr(),
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'chat.hint'.tr(),
                filled: true,
                fillColor: AppTheme.green.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.green, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
