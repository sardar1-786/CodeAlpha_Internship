# AI Video Agent — Complete Windows Setup Guide

**Sirf free resources use karta hai | 100% free stack**

Yeh guide Aliyan ke liye likhi gayi hai jo n8n Windows pe locally chala raha hai.
(Instructions English mein hain, Urdu hints bhi hain jahan zaroori tha.)

---

## Table of Contents

1. [What You Will Build](#1-what-you-will-build)
2. [Required Tools](#2-required-tools)
3. [Step 1 — Install Python](#step-1--install-python)
4. [Step 2 — Install gTTS](#step-2--install-gtts)
5. [Step 3 — Install ffmpeg](#step-3--install-ffmpeg)
6. [Step 4 — Install n8n](#step-4--install-n8n)
7. [Step 5 — Create Output & Scripts Folders](#step-5--create-output--scripts-folders)
8. [Step 6 — Get Free API Keys](#step-6--get-free-api-keys)
9. [Step 7 — Set Environment Variables in n8n](#step-7--set-environment-variables-in-n8n)
10. [Step 8 — Import the Workflow into n8n](#step-8--import-the-workflow-into-n8n)
11. [Step 9 — Run the Workflow](#step-9--run-the-workflow)
12. [Step 10 — Manually Upload to YouTube Shorts](#step-10--manually-upload-to-youtube-shorts)
13. [Troubleshooting](#troubleshooting)
14. [Customization Tips](#customization-tips)

---

## 1. What You Will Build

Ek fully automated n8n workflow jo:

- **Script** likhega (AI, HuggingFace free API se)
- **Voice-over** banayega (Python + gTTS — bilkul free)
- **Background video** download karega (Pixabay free API se)
- **Final vertical MP4 (1080×1920)** banayega (ffmpeg se — open-source)
- **YouTube title/description/tags** generate karega (AI se)
- Output aapko de dega taake aap manually YouTube pe upload kar sakein

> **Total cost: $0 (zero)**

---

## 2. Required Tools

| Tool | Version | Free? |
|------|---------|-------|
| Python | 3.9+ | ✅ Yes |
| pip (Python package manager) | latest | ✅ Yes |
| gTTS (Python library) | latest | ✅ Yes |
| ffmpeg | 6.x+ | ✅ Yes (open-source) |
| n8n | latest | ✅ Yes (self-hosted) |
| Node.js | 18+ | ✅ Yes |
| HuggingFace account | — | ✅ Free tier |
| Pixabay account | — | ✅ Free tier |

---

## Step 1 — Install Python

**Python install karna** (agar pehle se nahi hai):

1. Go to: https://www.python.org/downloads/windows/
2. Click **"Download Python 3.x.x"** (latest version).
3. Run the installer.
4. **IMPORTANT:** ✅ Check the box **"Add Python to PATH"** before clicking Install.
   - *Yeh step miss mat karna — PATH mein add karna zaroori hai.*
5. Click **"Install Now"**.

**Verify installation** (CMD ya PowerShell mein):
```cmd
python --version
```
Aapko kuch aisa dikhega: `Python 3.11.5`

Agar nahi dikhta, restart karein Windows ya manually PATH mein add karein.

---

## Step 2 — Install gTTS

gTTS (Google Text-to-Speech) ek free Python library hai jo text ko MP3 mein convert karti hai.

**CMD ya PowerShell open karein** (`Win + R` → type `cmd` → Enter):

```cmd
pip install gtts
```

**Test karein:**
```cmd
python -c "from gtts import gTTS; print('gTTS OK')"
```
Output: `gTTS OK` — matlab install ho gaya. ✅

---

## Step 3 — Install ffmpeg

ffmpeg ek powerful open-source video/audio processing tool hai.

### Option A — Winget (Easy, Windows 10/11)
```cmd
winget install ffmpeg
```
Agar winget available hai to yeh sabse aasan tareeqa hai.

### Option B — Manual Download
1. Go to: https://ffmpeg.org/download.html
2. Under "Windows" section → click **"Windows builds from gyan.io"** or **"BtbN/FFmpeg-Builds"**.
3. Download the **"full"** build (e.g., `ffmpeg-master-latest-win64-gpl.zip`).
4. Extract to a folder, e.g., `C:\ffmpeg\`
5. **Add to PATH:**
   - Press `Win + X` → **System** → **Advanced system settings** → **Environment Variables**
   - Under "System variables", find `Path` → click **Edit**
   - Click **New** → type `C:\ffmpeg\bin`
   - Click **OK** on all dialogs
6. **Restart CMD**, then test:

```cmd
ffmpeg -version
```
Aapko version info dikhegi. ✅

---

## Step 4 — Install n8n

n8n Node.js pe chalta hai, pehle Node.js install karein.

### 4a — Install Node.js
1. Go to: https://nodejs.org/
2. Download **LTS version** (e.g., 20.x LTS).
3. Run installer with default settings.
4. Verify:
   ```cmd
   node --version
   npm --version
   ```

### 4b — Install n8n
```cmd
npm install -g n8n
```
*Yeh 2-5 minutes le sakta hai.*

### 4c — Start n8n
```cmd
n8n start
```
Browser mein open ho jaega: `http://localhost:5678`

Pehli baar account banana hoga (local account, no payment needed).

> **Tip:** n8n ko background mein chalane ke liye:
> ```cmd
> start /B n8n start
> ```
> Ya phir ek alag CMD window mein chalaein aur minimize kar dein.

---

## Step 5 — Create Output & Scripts Folders

Workflow ko kuch folders chahiye files save karne ke liye.

**CMD mein run karein:**
```cmd
mkdir C:\n8n-video-agent\output
mkdir C:\n8n-video-agent\scripts
```

**Ab scripts copy karein** (repository se):
1. Repository clone karein ya files directly download karein.
2. `scripts/tts_gtts.py` → copy to `C:\n8n-video-agent\scripts\tts_gtts.py`
3. `scripts/render_short_ffmpeg.bat` → copy to `C:\n8n-video-agent\scripts\render_short_ffmpeg.bat`

**Final folder structure:**
```
C:\n8n-video-agent\
├── output\          ← workflow yahan MP3, MP4 files save karega
└── scripts\
    ├── tts_gtts.py
    └── render_short_ffmpeg.bat
```

---

## Step 6 — Get Free API Keys

### 6a — HuggingFace API Key (Script generation)

1. Go to: https://huggingface.co/join
2. Create a free account.
3. Go to: https://huggingface.co/settings/tokens
4. Click **"New token"** → Name it `n8n-video-agent` → Role: **Read** → Click **Generate**.
5. Copy the token (starts with `hf_...`).
6. Save it somewhere safe — aap isko environment variable mein daalenge.

> Free tier mein ~30,000 requests/month milti hain. ✅

### 6b — Pixabay API Key (Background videos)

1. Go to: https://pixabay.com/accounts/register/
2. Create a free account and verify your email.
3. Go to: https://pixabay.com/api/docs/
4. Your API key is shown there (after login).
5. Copy the API key (a long number+letter string).

> Free tier: ~5,000 requests/hour ✅

---

## Step 7 — Set Environment Variables in n8n

n8n apne environment variables `.env` file ya system variables se read karta hai.

### Option A — Using `.env` file (Recommended)

1. Find n8n's data folder. Usually:
   ```
   C:\Users\<YourUsername>\.n8n\
   ```
2. Create a file there named `.env` (no extension):
   ```
   C:\Users\<YourUsername>\.n8n\.env
   ```
3. Add these lines to the file (replace with your actual values):
   ```env
   HF_API_KEY=hf_your_actual_token_here
   PIXABAY_API_KEY=your_pixabay_api_key_here
   OUTPUT_DIR=C:\n8n-video-agent\output
   SCRIPTS_DIR=C:\n8n-video-agent\scripts
   VIDEO_TOPIC=success mindset motivation
   ```
4. Restart n8n:
   ```cmd
   Ctrl+C   (stop n8n)
   n8n start
   ```

### Option B — Windows System Environment Variables

1. Press `Win + X` → **System** → **Advanced system settings** → **Environment Variables**
2. Under "User variables" → click **New** for each variable:

   | Variable Name | Variable Value |
   |---------------|----------------|
   | `HF_API_KEY` | `hf_xxxxxxxxxxxx` |
   | `PIXABAY_API_KEY` | `12345678-abcde...` |
   | `OUTPUT_DIR` | `C:\n8n-video-agent\output` |
   | `SCRIPTS_DIR` | `C:\n8n-video-agent\scripts` |

3. Click **OK**, then restart n8n.

---

## Step 8 — Import the Workflow into n8n

1. Open n8n in your browser: `http://localhost:5678`
2. In the left sidebar, click **"Workflows"**.
3. Click the **"+"** button (top right area).
4. Select **"Import from File"** (or look for an import option in the menu).
5. Browse to and select:
   ```
   n8n/ai-video-agent-workflow.json
   ```
   (from this repository)
6. The workflow will open with all 16 nodes pre-configured.
7. Click **"Save"** (top right, or `Ctrl+S`).

---

## Step 9 — Run the Workflow

1. In the workflow canvas, click the **"Execute Workflow"** button (▶ triangle button).
2. The workflow will run step by step. Watch the progress — each node will turn green when it succeeds.

**What happens:**
| Step | What n8n Does |
|------|--------------|
| Set Config | Sets topic = "success mindset motivation" |
| Generate Script | Calls HuggingFace AI → gets a 45-sec script |
| Parse Script | Cleans up the AI response |
| Build File Paths | Creates timestamped filenames |
| Save Script TXT | Writes script to `C:\n8n-video-agent\output\script_<ts>.txt` |
| Generate TTS Audio | Runs Python → creates `voice_<ts>.mp3` |
| Search Pixabay | Finds a background video for your topic |
| Download BG Video | Downloads it to `bg_video_<ts>.mp4` |
| Render Final Video | ffmpeg combines video + audio → `final_short_<ts>.mp4` |
| Generate Metadata | AI writes YouTube title, description, tags |
| Output Summary | Shows you the final video path + metadata |

**Total time:** ~1-3 minutes (depending on API response time).

After workflow runs, check:
```
C:\n8n-video-agent\output\
```
You will see:
- `script_<timestamp>.txt` — the AI-written script
- `voice_<timestamp>.mp3` — the voice-over
- `bg_video_<timestamp>.mp4` — the downloaded background video
- `final_short_<timestamp>.mp4` — **your final YouTube Short** ✅

---

## Step 10 — Manually Upload to YouTube Shorts

Your video is now ready! Upload it to YouTube:

1. Go to: https://studio.youtube.com/
2. Click **"Create"** (top right) → **"Upload video"**.
3. Select your `final_short_<timestamp>.mp4`.
4. Copy the **title** from the n8n Output Summary node.
5. Copy the **description** (with hashtags) from the Output Summary node.
6. Add the **tags** from the Output Summary node.
7. Set visibility to **"Public"** (or "Scheduled" for later).
8. Click **"Publish"**.

> **YouTube Shorts tip:** Videos in vertical 9:16 format under 60 seconds
> are automatically shown as Shorts. Your video is already 1080×1920. ✅

---

## Troubleshooting

### "python is not recognized..."
- Python PATH mein nahi hai. Re-install Python aur "Add to PATH" option zaroor check karein.
- Ya try karein: `py --version`

### "gtts module not found"
```cmd
pip install gtts
```

### "ffmpeg is not recognized..."
- ffmpeg bin folder PATH mein add karein (Step 3 dekhen).
- CMD restart karein.

### n8n Execute Command "access denied"
- n8n ko administrator mode mein start karein:
  - Right-click CMD → "Run as Administrator" → `n8n start`

### HuggingFace API returns error
- Check karo ke `HF_API_KEY` environment variable set hai.
- HuggingFace free tier mein model loading time ho sakta hai (30-60 seconds wait).
- Agar model busy ho to thoda wait karke dobara try karein.
- Alternative model: change `HF_MODEL_URL` to:
  `https://api-inference.huggingface.co/models/google/flan-t5-xxl`

### Pixabay returns no results
- Check karo ke `PIXABAY_API_KEY` set hai.
- Topic change karke try karein (e.g., "nature sunset" instead of a specific phrase).
- Workflow mein fallback video URL lagaya gaya hai — wo use hoga agar Pixabay fail ho.

### ffmpeg video render fails
- Check karo ke `bg_video_<ts>.mp4` actually exist karta hai `output` folder mein.
- Command Prompt mein manually test karein:
  ```cmd
  ffmpeg -i "C:\n8n-video-agent\output\bg_video_xxx.mp4" -version
  ```

### Output folder not found
```cmd
mkdir C:\n8n-video-agent\output
mkdir C:\n8n-video-agent\scripts
```

---

## Customization Tips

### Change the video topic
- `.env` file mein `VIDEO_TOPIC` update karein:
  ```env
  VIDEO_TOPIC=morning routine habits
  ```
- Ya workflow mein **"Set Config"** node pe click karein → `topic` field change karein.

### Change the AI model
```env
HF_MODEL_URL=https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2
```
Other free models to try:
- `https://api-inference.huggingface.co/models/tiiuae/falcon-7b-instruct`
- `https://api-inference.huggingface.co/models/google/flan-t5-xxl`

### Change TTS voice language
Open `scripts/tts_gtts.py`, line with `lang="en"`:
```python
tts = gTTS(text=text, lang="ur", slow=False)  # Urdu voice
```
Available languages: `en` (English), `ur` (Urdu), `hi` (Hindi), etc.

### Add text overlay to video
In the **"Render Final Video (ffmpeg)"** node, the command can be extended with `drawtext` filter to add subtitles/captions (advanced ffmpeg usage).

### Schedule automatic daily videos
1. Add a **Cron** node at the start instead of (or alongside) the Manual Trigger.
2. Set it to run daily at your preferred time, e.g., `0 19 * * *` (7 PM daily).
3. This way a new Short will be generated every day automatically.

---

## Summary of All Commands

```cmd
:: Install everything (run once)
pip install gtts
winget install ffmpeg

:: Create folders
mkdir C:\n8n-video-agent\output
mkdir C:\n8n-video-agent\scripts

:: Copy scripts from repo
copy scripts\tts_gtts.py C:\n8n-video-agent\scripts\
copy scripts\render_short_ffmpeg.bat C:\n8n-video-agent\scripts\

:: Start n8n
n8n start
:: Then open: http://localhost:5678
```

---

## Free Resources Used

| Purpose | Tool/API | Cost |
|---------|----------|------|
| Script writing | HuggingFace Inference API (zephyr-7b-beta) | Free |
| Text-to-Speech | gTTS (Google Translate TTS via Python) | Free |
| Background video | Pixabay Video API | Free |
| Video composition | ffmpeg (open source) | Free |
| Workflow automation | n8n (self-hosted) | Free |

**Total cost: $0** 🎉

---

*Made with ❤️ for Aliyan Abid (sardar1-786)*
