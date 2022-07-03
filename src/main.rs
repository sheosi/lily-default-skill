use std::collections::HashMap;

use vap_skill_framework::{Skill, PlainCapability, RequestStr};
use futures::StreamExt;
#[cfg(debug_assertions)]
use dotenv::dotenv;
use std::env;

#[cfg(debug_assertions)]
fn load_env() {
    dotenv().ok();
}

#[cfg(not(debug_assertions))]
fn load_env() {
}

fn load_key(name: &str) -> String {
    env::var(name).unwrap_or_else(|_|{println!("This program needs '{}' set for it to work", name);panic!()}) 
}

#[tokio::main]
async fn main() {
    load_env();
    let api_key = load_key("API_KEY");
    
    let (mut skill, mut skill_in) = Skill::new("default", "com.sheosi.lily-default", "assets").unwrap();
    loop {
        let req = skill_in.next().await.unwrap();
        match req.request.as_str() {
            RequestStr::Intent("hello", _) => {
                println!("Got hello");
                    let mut cap_data = HashMap::new();
                    cap_data.insert("text".into(), "hi there!!!".into());
                    skill.answer(&req, vec![PlainCapability {
                        name: "voice".into(),
                        cap_data
                    }]).unwrap();
            }
            _ => {println!("Miaaaau")}
        }
    }
}