import google.generativeai as genai
import os
from dotenv import load_dotenv

# Load env from the same directory as this script or parent
load_dotenv()

api_key = os.getenv('GEMINI_API_KEY')
if not api_key:
    # Try loading from parent .env if running from backend dir
    load_dotenv('../.env')
    api_key = os.getenv('GEMINI_API_KEY')

if not api_key:
    print("Error: GEMINI_API_KEY not found")
    exit(1)

print(f"Using API Key: {api_key[:5]}...{api_key[-3:]}")

genai.configure(api_key=api_key)

print("Listing available models...")
try:
    for m in genai.list_models():
        if 'generateContent' in m.supported_generation_methods:
            print(f"- {m.name}")
except Exception as e:
    print(f"Error listing models: {e}")
