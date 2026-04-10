# n8n — AI Video Agent Folder

This folder contains the **n8n workflow** for the AI-powered YouTube Shorts
generator.

## Files

| File | Description |
|------|-------------|
| `ai-video-agent-workflow.json` | Complete importable n8n workflow (16 nodes) |

## What the Workflow Does

```
Manual Trigger
    ↓
Set Config  (topic, output_dir, scripts_dir, HF model URL)
    ↓
Generate Script  (HuggingFace Inference API → zephyr-7b-beta)
    ↓
Parse Script Response  (extract clean script text)
    ↓
Build File Paths  (timestamp-based paths for all temp/output files)
    ↓
Script Text → Binary  (convert text to binary for file save)
    ↓
Save Script TXT File  (write script.txt to OUTPUT_DIR)
    ↓
Generate TTS Audio  (python tts_gtts.py → voice_<ts>.mp3)
    ↓
Search Pixabay Videos  (free stock video matching the topic)
    ↓
Extract Video URL  (pick best result)
    ↓
Download Background Video  (save to OUTPUT_DIR)
    ↓
Save Background Video  (write bg_video_<ts>.mp4 to disk)
    ↓
Render Final Video  (render_short_ffmpeg.bat → final_short_<ts>.mp4)
    ↓
Generate YouTube Metadata  (HuggingFace → title + description + tags)
    ↓
Parse Metadata  (extract JSON from LLM response)
    ↓
Output Summary  (final_video_path, youtube_title, youtube_description, youtube_tags)
```

## Quick Import into n8n

1. Open your local n8n: `http://localhost:5678`
2. Click **"Workflows"** in the left sidebar.
3. Click the **"+"** button (New Workflow) → then **"Import from File"**.
4. Select `n8n/ai-video-agent-workflow.json` from this repository.
5. Configure environment variables (see `docs/ai-video-agent-setup.md`).
6. Click **"Execute Workflow"** (▶ button) to test manually.

## Required Environment Variables

Set these in your n8n environment **before** running the workflow:

| Variable | Description | Example |
|----------|-------------|---------|
| `HF_API_KEY` | HuggingFace Inference API key (free) | `hf_xxxxxxxxxxxx` |
| `PIXABAY_API_KEY` | Pixabay free API key | `12345678-abcde...` |
| `OUTPUT_DIR` | Folder where all output files are saved | `C:\n8n-video-agent\output` |
| `SCRIPTS_DIR` | Folder where helper scripts are located | `C:\n8n-video-agent\scripts` |
| `VIDEO_TOPIC` | (Optional) Override the default video topic | `morning routine habits` |
| `HF_MODEL_URL` | (Optional) Override the HuggingFace model endpoint | see below |

Default HF model: `https://api-inference.huggingface.co/models/HuggingFaceH4/zephyr-7b-beta`

## Helper Scripts (in `/scripts` folder)

| Script | Purpose |
|--------|---------|
| `scripts/tts_gtts.py` | Text-to-Speech via gTTS (Google Translate TTS) |
| `scripts/render_short_ffmpeg.bat` | Compose vertical 9:16 MP4 using ffmpeg |

## Full Setup Guide

See **`docs/ai-video-agent-setup.md`** for step-by-step Windows setup
instructions including how to install Python, pip, gTTS, and ffmpeg.
