import os
import wave
import pyaudio
import requests
import subprocess
from openai import OpenAI

# Configuration
OLLAMA_MODEL = "hermes3:8b"
WHISPER_MODEL_PATH = "./models/ggml-base.en.bin"
PIPER_VOICE_PATH = "./models/en_US-lessac-medium.onnx"
WAKE_WORD = "hey hermes"

# Initialize local OpenAI-compatible client routing to Ollama
client = OpenAI(base_url="http://localhost:11434/v1", api_key="sk-local")

def record_audio(filename="input.wav", record_seconds=5):
    """Records audio from the microphone."""
    chunk = 1024
    format = pyaudio.paInt16
    channels = 1
    rate = 16000
    
    p = pyaudio.PyAudio()
    stream = p.open(format=format, channels=channels, rate=rate, input=True, frames_per_buffer=chunk)
    
    print("🎙️ Listening...")
    frames = []
    for _ in range(0, int(rate / chunk * record_seconds)):
        data = stream.read(chunk)
        frames.append(data)
        
    stream.stop_stream()
    stream.close()
    p.terminate()
    
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(channels)
        wf.setsampwidth(p.get_sample_size(format))
        wf.setframerate(rate)
        wf.writeframes(b''.join(frames))

def transcribe_audio():
    """Uses whisper.cpp to transcribe the recorded audio."""
    print("⚙️ Transcribing...")
    result = subprocess.run(
        ["whisper-cpp", "-m", WHISPER_MODEL_PATH, "-f", "input.wav", "-nt"],
        capture_output=True, text=True
    )
    return result.stdout.strip()

def ask_hermes(prompt):
    """Sends the transcribed text to Hermes 3 via Ollama."""
    print(f"🧠 Asking Hermes: {prompt}")
    response = client.chat.completions.create(
        model=OLLAMA_MODEL,
        messages=[
            {"role": "system", "content": "You are Hermes, a concise, highly capable AI assistant. Provide short, spoken-style responses."},
            {"role": "user", "content": prompt}
        ],
        max_tokens=150
    )
    return response.choices.message.content

def speak_response(text):
    """Uses Piper TTS to synthesize and play the response."""
    print(f"🔊 Speaking: {text}")
    # Pipe text into Piper, then pipe the raw audio into aplay (Linux audio player)
    cmd = f'echo "{text}" | piper --model {PIPER_VOICE_PATH} --output_raw | aplay -r 22050 -f S16_LE -t raw -'
    os.system(cmd)

def main_loop():
    """The always-on execution loop."""
    print("🚀 System initialized. Awaiting manual trigger (Wake Word engine integration pending).")
    while True:
        # In a full production environment, openWakeWord would block here until triggered
        input("Press Enter to simulate Wake Word detection...")
        
        record_audio()
        user_text = transcribe_audio()
        
        if user_text:
            hermes_reply = ask_hermes(user_text)
            speak_response(hermes_reply)

if __name__ == "__main__":
    main_loop()
