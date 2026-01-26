package com.uchannel.repository;

import com.uchannel.model.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 消息仓库接口
 */
@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    
    /**
     * 根据会话ID查找所有消息，按时间排序
     */
    List<Message> findByConversationIdOrderByTimestampAsc(String conversationId);
    
    /**
     * 删除会话的所有消息
     */
    void deleteByConversationId(String conversationId);
}
