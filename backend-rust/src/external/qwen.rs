use reqwest::Client;
use serde::{Deserialize, Serialize};
use tracing::{error, info, warn};

#[derive(Clone)]
pub struct QwenService {
    client: Client,
    api_key: String,
    api_url: String,
}

#[derive(Serialize)]
struct QwenRequest {
    model: String,
    input: QwenInput,
    parameters: QwenParameters,
}

#[derive(Serialize)]
struct QwenInput {
    messages: Vec<QwenMessage>,
}

#[derive(Serialize)]
struct QwenMessage {
    role: String,
    content: String,
}

#[derive(Serialize)]
struct QwenParameters {
    temperature: f32,
    max_tokens: i32,
    top_p: f32,
}

#[derive(Deserialize)]
struct QwenResponse {
    output: Option<QwenOutput>,
    code: Option<String>,
    message: Option<String>,
}

#[derive(Deserialize)]
struct QwenOutput {
    choices: Option<Vec<QwenChoice>>,
    text: Option<String>,
}

#[derive(Deserialize)]
struct QwenChoice {
    message: QwenChoiceMessage,
}

#[derive(Deserialize)]
struct QwenChoiceMessage {
    content: String,
}

impl QwenService {
    const SYSTEM_PROMPT: &'static str = r#"你是一个专业的日程安排助手。你的任务是帮助用户管理日程安排。
当用户提供日程信息时，你需要：
1. 理解用户的日程安排意图
2. 提取关键信息（时间、地点、事件等）
3. 给出友好的确认，并告知用户日程已添加（不要说"我会帮你添加"，而是说"已为您添加"）
4. 如果信息不完整，礼貌地询问缺失的信息
5. 提醒用户可以在"日程"Tab中查看和管理日程
请用简洁、友好的语言回复用户。"#;

    pub fn new(api_key: String, api_url: String) -> Self {
        Self {
            client: Client::new(),
            api_key,
            api_url,
        }
    }

    pub async fn chat(&self, user_message: &str) -> Option<String> {
        info!("Calling Qwen API for message: {}", user_message);

        let request = QwenRequest {
            model: "qwen-turbo".to_string(),
            input: QwenInput {
                messages: vec![
                    QwenMessage {
                        role: "system".to_string(),
                        content: Self::SYSTEM_PROMPT.to_string(),
                    },
                    QwenMessage {
                        role: "user".to_string(),
                        content: user_message.to_string(),
                    },
                ],
            },
            parameters: QwenParameters {
                temperature: 0.7,
                max_tokens: 1000,
                top_p: 0.8,
            },
        };

        let response = self
            .client
            .post(&self.api_url)
            .header("Authorization", format!("Bearer {}", self.api_key))
            .header("X-DashScope-SSE", "disable")
            .header("Content-Type", "application/json")
            .json(&request)
            .send()
            .await;

        match response {
            Ok(resp) => {
                if resp.status().is_success() {
                    match resp.json::<QwenResponse>().await {
                        Ok(qwen_resp) => {
                            // Check for errors
                            if let Some(code) = &qwen_resp.code {
                                if code != "Success" {
                                    let error_msg = qwen_resp
                                        .message
                                        .unwrap_or_else(|| "Unknown error".to_string());
                                    error!("Qwen API returned error: {}", error_msg);
                                    return None;
                                }
                            }

                            // Extract content from response
                            if let Some(output) = qwen_resp.output {
                                // Try choices first
                                if let Some(choices) = output.choices {
                                    if let Some(first_choice) = choices.first() {
                                        return Some(first_choice.message.content.clone());
                                    }
                                }
                                // Fall back to text
                                if let Some(text) = output.text {
                                    return Some(text);
                                }
                            }

                            warn!("Could not parse Qwen response");
                            None
                        }
                        Err(e) => {
                            error!("Failed to parse Qwen response: {}", e);
                            None
                        }
                    }
                } else {
                    error!("Qwen API call failed with status: {}", resp.status());
                    None
                }
            }
            Err(e) => {
                error!("Qwen API request error: {}", e);
                None
            }
        }
    }
}
