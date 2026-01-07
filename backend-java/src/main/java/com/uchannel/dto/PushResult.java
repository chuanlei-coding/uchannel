package com.uchannel.dto;

/**
 * 推送结果DTO
 */
public class PushResult {
    private boolean success;
    private String messageId;
    private String error;
    private Integer successCount;
    private Integer failureCount;

    private PushResult(boolean success) {
        this.success = success;
    }

    public static PushResult success(String messageId) {
        PushResult result = new PushResult(true);
        result.messageId = messageId;
        return result;
    }

    public static PushResult failure(String error) {
        PushResult result = new PushResult(false);
        result.error = error;
        return result;
    }

    public static PushResult batchResult(int successCount, int failureCount) {
        PushResult result = new PushResult(true);
        result.successCount = successCount;
        result.failureCount = failureCount;
        return result;
    }

    // Getters and Setters
    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public Integer getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(Integer successCount) {
        this.successCount = successCount;
    }

    public Integer getFailureCount() {
        return failureCount;
    }

    public void setFailureCount(Integer failureCount) {
        this.failureCount = failureCount;
    }
}

