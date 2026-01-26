import React from 'react';
import {View, Text, StyleSheet} from 'react-native';
import {Message, MessageSender} from '../models/Message';
import {Colors} from '../utils/colors';

interface MessageItemProps {
  message: Message;
}

const MessageItem: React.FC<MessageItemProps> = ({message}) => {
  const isUser = message.sender === MessageSender.USER;
  const isSuggestion = message.sender === MessageSender.SUGGESTION;

  const formatTime = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true,
    });
  };

  if (isSuggestion) {
    return (
      <View style={styles.suggestionContainer}>
        <View style={styles.avatarContainer}>
          <View style={styles.vitaAvatar} />
        </View>
        <View style={styles.suggestionContent}>
          <Text style={styles.vitaLabel}>Vita</Text>
          <View style={styles.suggestionBubble}>
            <View style={styles.suggestionHeader}>
              <Text style={styles.autoIcon}>✨</Text>
              <Text style={styles.suggestionLabel}>建议操作</Text>
            </View>
            {message.scheduleTitle && (
              <View style={styles.scheduleCard}>
                <View style={styles.scheduleHeader}>
                  <Text style={styles.scheduleLabel}>今日建议</Text>
                  <Text style={styles.scheduleTime}>{message.scheduleTime}</Text>
                </View>
                <View style={styles.scheduleLine} />
                <Text style={styles.scheduleTitle}>{message.scheduleTitle}</Text>
                {message.scheduleLocation && (
                  <Text style={styles.scheduleLocation}>
                    {message.scheduleLocation}
                  </Text>
                )}
              </View>
            )}
            <Text style={styles.suggestionText}>{message.content}</Text>
          </View>
          <Text style={styles.timeText}>{formatTime(message.timestamp)}</Text>
        </View>
      </View>
    );
  }

  return (
    <View style={[styles.container, isUser && styles.userContainer]}>
      {!isUser && (
        <View style={styles.avatarContainer}>
          <View style={styles.vitaAvatar} />
        </View>
      )}
      <View style={styles.content}>
        {!isUser && <Text style={styles.vitaLabel}>Vita</Text>}
        <View
          style={[
            styles.bubble,
            isUser ? styles.userBubble : styles.assistantBubble,
          ]}>
          <Text
            style={[
              styles.messageText,
              isUser ? styles.userText : styles.assistantText,
            ]}>
            {message.content}
          </Text>
          {message.contentSecondary && !isUser && (
            <Text style={styles.secondaryText}>
              {message.contentSecondary}
            </Text>
          )}
        </View>
        <Text style={[styles.timeText, isUser && styles.userTimeText]}>
          {formatTime(message.timestamp)}
        </Text>
      </View>
      {isUser && (
        <View style={styles.avatarContainer}>
          <View style={styles.userAvatar} />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    marginVertical: 8,
    paddingHorizontal: 16,
  },
  userContainer: {
    justifyContent: 'flex-end',
  },
  avatarContainer: {
    width: 24,
    height: 24,
    marginHorizontal: 8,
    justifyContent: 'flex-start',
  },
  vitaAvatar: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: Colors.brandSage,
  },
  userAvatar: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: Colors.brandTeal,
  },
  content: {
    flex: 1,
    maxWidth: '75%',
  },
  vitaLabel: {
    fontSize: 12,
    color: Colors.brandSage,
    marginBottom: 4,
  },
  bubble: {
    padding: 16,
    borderRadius: 16,
    marginBottom: 4,
  },
  assistantBubble: {
    backgroundColor: Colors.darkSage,
    borderBottomLeftRadius: 0,
  },
  userBubble: {
    backgroundColor: Colors.bubbleUserLightGreen,
    alignSelf: 'flex-end',
  },
  messageText: {
    fontSize: 15,
    lineHeight: 21,
  },
  assistantText: {
    color: Colors.textWhite90,
  },
  userText: {
    color: Colors.textPrimary,
  },
  secondaryText: {
    fontSize: 15,
    color: Colors.textWhite80,
    marginTop: 8,
    lineHeight: 21,
  },
  timeText: {
    fontSize: 10,
    color: Colors.textWhite40,
    marginLeft: 4,
  },
  userTimeText: {
    textAlign: 'right',
    marginRight: 4,
  },
  suggestionContainer: {
    flexDirection: 'row',
    marginVertical: 8,
    paddingHorizontal: 16,
  },
  suggestionContent: {
    flex: 1,
    maxWidth: '85%',
  },
  suggestionBubble: {
    backgroundColor: Colors.glassSage,
    padding: 20,
    borderRadius: 16,
    borderBottomLeftRadius: 0,
    marginBottom: 4,
  },
  suggestionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  autoIcon: {
    fontSize: 16,
    marginRight: 8,
  },
  suggestionLabel: {
    fontSize: 11,
    color: Colors.textWhite60,
    letterSpacing: 0.1,
    fontWeight: 'bold',
    textTransform: 'uppercase',
  },
  scheduleCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    padding: 12,
    borderRadius: 8,
    marginBottom: 12,
  },
  scheduleHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  scheduleLabel: {
    fontSize: 13,
    color: Colors.textWhite80,
  },
  scheduleTime: {
    fontSize: 12,
    color: Colors.textWhite60,
  },
  scheduleLine: {
    width: 2,
    height: 24,
    backgroundColor: Colors.brandSage,
    marginLeft: 12,
    marginTop: 4,
  },
  scheduleTitle: {
    fontSize: 14,
    color: Colors.textWhite90,
    marginLeft: 12,
    marginTop: 4,
  },
  scheduleLocation: {
    fontSize: 12,
    color: Colors.textWhite60,
    marginLeft: 12,
    marginTop: 2,
  },
  suggestionText: {
    fontSize: 14,
    color: Colors.textWhite70,
    lineHeight: 20,
  },
});

export default MessageItem;
