use std::env;

#[derive(Clone)]
pub struct Config {
    pub server_host: String,
    pub server_port: u16,
    pub database_url: String,
    pub qwen_api_key: String,
    pub qwen_api_url: String,
}

impl Config {
    pub fn from_env() -> Self {
        dotenvy::dotenv().ok();

        Self {
            server_host: env::var("SERVER_HOST").unwrap_or_else(|_| "0.0.0.0".to_string()),
            server_port: env::var("SERVER_PORT")
                .unwrap_or_else(|_| "8080".to_string())
                .parse()
                .unwrap_or(8080),
            database_url: env::var("DATABASE_URL")
                .unwrap_or_else(|_| "sqlite:./data/uchannel.db".to_string()),
            qwen_api_key: env::var("QWEN_API_KEY")
                .unwrap_or_else(|_| "sk-bbdf41fb73044d66b46976a1df35abbe".to_string()),
            qwen_api_url: env::var("QWEN_API_URL")
                .unwrap_or_else(|_| {
                    "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"
                        .to_string()
                }),
        }
    }
}
