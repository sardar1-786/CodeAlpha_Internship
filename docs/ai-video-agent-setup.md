# AI YouTube Shorts Video Agent — Setup Guide

> **Overview:** This n8n workflow automatically generates and publishes short-form AI videos to YouTube Shorts using only **free-tier** services. It covers topic selection, LLM-based script writing, free TTS, stock video fetching, local ffmpeg video assembly, and YouTube Data API v3 upload.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Setup](#step-by-step-setup)
   - [1. n8n Installation](#1-n8n-installation)
   - [2. OpenRouter (Free LLM)](#2-openrouter-free-llm)
   - [3. Pexels (Free Stock Video)](#3-pexels-free-stock-video)
   - [4. TTS Setup (StreamElements — no key required)](#4-tts-setup-streamelements--no-key-required)
   - [5. ffmpeg Installation](#5-ffmpeg-installation)
   - [6. YouTube Data API v3 (Free)](#6-youtube-data-api-v3-free)
   - [7. Notification Webhook (Optional)](#7-notification-webhook-optional)
4. [Importing the Workflow](#importing-the-workflow)
5. [Environment Variables & n8n Credentials](#environment-variables--n8n-credentials)
6. [Running the Workflow](#running-the-workflow)
7. [Workflow Node Reference](#workflow-node-reference)
8. [Customization Tips](#customization-tips)
9. [Security Best Practices](#security-best-practices)
10. [Limitations & Known Issues](#limitations--known-issues)
11. [Reference Video Analysis](#reference-video-analysis)

---

## Architecture Overview

```
[Trigger] → [Topic Selector] → [LLM Script Gen] → [Parse Script & Scenes]
                                                          ↓              ↓
                                              [Fetch Pexels Videos]  [TTS Audio]
                                                          ↓              ↓
                                              [Collect Assets] → [Prepare FFmpeg]
                                                                        ↓
                                                              [Save Audio to Disk]
                                                                        ↓
                                                          [Run FFmpeg — Assemble MP4]
                                                                        ↓
                                                       [YouTube Resumable Upload Init]
                                                                        ↓
                                                          [Upload Video Bytes (PUT)]
                                                                        ↓
                                                    [Extract Video ID & Build URL]
                                                                        ↓
                                              [Send Notification] → [Final Summary]
```

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| **n8n** | Self-hosted (Docker or npm) **or** n8n Cloud free trial |
| **ffmpeg** | Must be installed on the machine where n8n runs |
| **Node.js ≥ 18** | Required if running n8n via npm |
| **Internet access** | For API calls to OpenRouter, Pexels, StreamElements, YouTube |

---

## Step-by-Step Setup

### 1. n8n Installation

#### Option A — Docker (recommended for self-hosting)

```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=changeme \
  docker.n8n.io/n8nio/n8n
```

Open `http://localhost:5678` in your browser.

#### Option B — npm

```bash
npm install -g n8n
n8n start
```

#### Option C — n8n Cloud (free trial)

Sign up at [https://app.n8n.cloud](https://app.n8n.cloud). No installation needed, but `Execute Command` node and local file system access are **not available** on n8n Cloud — use a self-hosted instance for full functionality including ffmpeg.

---

### 2. OpenRouter (Free LLM)

OpenRouter provides access to several free AI models (including Mistral 7B, Llama 3, Gemma) under a free tier with no credit card required for free models.

**Steps:**
1. Go to [https://openrouter.ai](https://openrouter.ai) and create a free account.
2. Navigate to **Keys** → **Create Key**.
3. Copy the API key (starts with `sk-or-...`).
4. In n8n, create a new **HTTP Header Auth** credential:
   - **Name:** `OpenRouter API Key`
   - **Header Name:** `Authorization`
   - **Header Value:** `Bearer sk-or-YOUR_KEY_HERE`

**Free models available (no credits required):**
- `mistralai/mistral-7b-instruct:free`
- `meta-llama/llama-3-8b-instruct:free`
- `google/gemma-7b-it:free`

> You can change the model in the **Generate Script (LLM)** node's body JSON under `"model"`.

---

### 3. Pexels (Free Stock Video)

Pexels offers a generous free API with access to thousands of royalty-free stock videos.

**Steps:**
1. Go to [https://www.pexels.com/api/](https://www.pexels.com/api/) and sign up for a free account.
2. Request an API key (approved instantly).
3. In n8n, create a new **HTTP Header Auth** credential:
   - **Name:** `Pexels API Key`
   - **Header Name:** `Authorization`
   - **Header Value:** `YOUR_PEXELS_API_KEY` (no "Bearer" prefix)

**Free tier limits:** 200 requests/hour, 20,000 requests/month. More than enough for daily video generation.

> **Alternative:** [Pixabay API](https://pixabay.com/api/docs/) is also free with similar limits.

---

### 4. TTS Setup (StreamElements — no key required)

The workflow uses the **StreamElements TTS API**, which is completely free and requires no API key.

**Endpoint used:**
```
POST https://api.streamelements.com/kappa/v2/speech
Body: { "voice": "Brian", "text": "Your script here" }
```

**Available voices (a selection):**
| Voice | Style |
|-------|-------|
| `Brian` | Neutral male (US) |
| `Amy` | Neutral female (UK) |
| `Emma` | Neutral female (UK) |
| `Justin` | Young male (US) |
| `Joanna` | Female (US) |

To change voice, edit the `voice` field in the **Text-to-Speech (StreamElements)** node.

> **Alternatives:**
> - [TikTok TTS (unofficial)](https://github.com/oscie57/tiktok-voice) — very natural voices, community API.
> - [Coqui TTS](https://github.com/coqui-ai/TTS) — open-source, self-hostable, multiple language support.

---

### 5. ffmpeg Installation

ffmpeg must be installed **on the same machine where n8n is running** because the workflow uses the `Execute Command` node.

#### Ubuntu / Debian

```bash
sudo apt update && sudo apt install -y ffmpeg
ffmpeg -version  # verify installation
```

#### macOS

```bash
brew install ffmpeg
```

#### Windows

Download from [https://ffmpeg.org/download.html](https://ffmpeg.org/download.html) and add `ffmpeg.exe` to your PATH.

#### Docker (include ffmpeg in n8n container)

Use a custom Dockerfile:

```dockerfile
FROM docker.n8n.io/n8nio/n8n
USER root
RUN apk add --no-cache ffmpeg
USER node
```

Build and run:

```bash
docker build -t n8n-with-ffmpeg .
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8n-with-ffmpeg
```

---

### 6. YouTube Data API v3 (Free)

The YouTube Data API is free within Google's quota limits (10,000 units/day by default, which covers ~6 video uploads/day).

#### Step 1: Create a Google Cloud Project

1. Go to [https://console.cloud.google.com/](https://console.cloud.google.com/)
2. Click **New Project** → give it a name (e.g. `ai-video-agent`) → **Create**

#### Step 2: Enable YouTube Data API v3

1. In your project, go to **APIs & Services → Library**
2. Search for **YouTube Data API v3** → click → **Enable**

#### Step 3: Create OAuth 2.0 Credentials

1. Go to **APIs & Services → Credentials → Create Credentials → OAuth client ID**
2. Configure the OAuth consent screen (External → fill name/email → Save)
3. Application type: **Web application**
4. Authorized redirect URIs: add `http://localhost:5678/rest/oauth2-credential/callback`
   (or your n8n cloud URL + `/rest/oauth2-credential/callback`)
5. Click **Create** → note your **Client ID** and **Client Secret**

#### Step 4: Add Credential in n8n

1. In n8n, go to **Credentials → New**
2. Search for **Google OAuth2 API** (or use **OAuth2 API** generic)
3. Fill in:
   - **Client ID:** your Google OAuth Client ID
   - **Client Secret:** your Google OAuth Client Secret
   - **Authorization URL:** `https://accounts.google.com/o/oauth2/auth`
   - **Access Token URL:** `https://oauth2.googleapis.com/token`
   - **Scope:** `https://www.googleapis.com/auth/youtube.upload https://www.googleapis.com/auth/youtube`
4. Click **Connect** and authorize with your Google account
5. Name it `YouTube OAuth2`

> **Important:** For the video to appear as a YouTube Short, it must be:
> - Vertical (9:16 aspect ratio, i.e. 1080×1920)
> - Under 60 seconds
> - The title or description may optionally contain `#Shorts`

---

### 7. Notification Webhook (Optional)

The workflow can send a completion notification to Discord, Slack, or any webhook endpoint.

**Discord:**
1. Go to your Discord server → Channel Settings → Integrations → Webhooks → New Webhook
2. Copy the webhook URL

**Slack:**
1. Go to [https://api.slack.com/messaging/webhooks](https://api.slack.com/messaging/webhooks) → Create an app → Enable Incoming Webhooks → copy URL

**Set in n8n:**
Set the environment variable `NOTIFICATION_WEBHOOK_URL` to your webhook URL (or leave it empty to skip — the node has `continueOnFail: true`).

---

## Importing the Workflow

1. Open your n8n instance.
2. Go to **Workflows → ⊕ Add Workflow → Import from File**.
3. Select `n8n/ai-video-agent-workflow.json` from this repository.
4. Review the imported nodes.
5. Open each node that requires credentials and attach the credentials you created above:
   - **Generate Script (LLM):** `OpenRouter API Key`
   - **Fetch Stock Videos (Pexels):** `Pexels API Key`
   - **YouTube: Init Resumable Upload:** `YouTube OAuth2`

---

## Environment Variables & n8n Credentials

| Variable / Credential | Where to Set | Description |
|-----------------------|--------------|-------------|
| `OpenRouter API Key` | n8n Credential (HTTP Header Auth) | OpenRouter `Authorization: Bearer <key>` header |
| `Pexels API Key` | n8n Credential (HTTP Header Auth) | Pexels `Authorization: <key>` header |
| `YouTube OAuth2` | n8n Credential (OAuth2 API) | Google OAuth2 client ID + secret for YouTube uploads |
| `NOTIFICATION_WEBHOOK_URL` | n8n Environment Variable or node param | Discord/Slack/Telegram webhook for completion alerts |

> **Never commit API keys to Git.** Always use n8n's built-in Credentials system or set values as environment variables passed into n8n at startup (e.g., `-e MY_KEY=value` in Docker).

---

## Running the Workflow

### Manual Run (test mode)

1. Open the imported workflow.
2. Click **Execute Workflow** (play button).
3. Optional: in the **Topic Selector** node, you can hardcode a `topic` value for testing.
4. Watch each node execute in sequence. Green = success, Red = error.

### Scheduled Run (daily automation)

1. **Disable** the `Manual Trigger` node (right-click → Disable).
2. **Enable** the `Daily Schedule (optional)` node.
3. Toggle the workflow to **Active** (top-right switch).
4. n8n will now automatically run the pipeline once every 24 hours.

### Pass a Custom Topic via Webhook

You can also add an `n8n-nodes-base.webhook` trigger node and send a POST request with `{ "topic": "Your Custom Topic" }` to run the agent on demand with a specific topic.

---

## Workflow Node Reference

| Node | Type | Purpose |
|------|------|---------|
| Manual Trigger | Trigger | Start workflow manually for testing |
| Daily Schedule | Trigger | Run workflow automatically every 24 hours |
| Topic Selector | Code | Randomly pick a topic from a predefined list (or use provided input) |
| Generate Script (LLM) | HTTP Request | Call OpenRouter free LLM to generate script + scene breakdown |
| Parse Script & Scenes | Code | Extract and structure LLM response JSON |
| Fetch Stock Videos (Pexels) | HTTP Request | Fetch portrait stock videos matching the first scene's visual description |
| Collect Visual Assets | Code | Extract usable video URLs from Pexels response |
| Text-to-Speech (StreamElements) | HTTP Request | Convert script text to MP3 audio (free, no auth) |
| Prepare FFmpeg Command | Code | Build the ffmpeg CLI command for video assembly |
| Save Audio to Disk | Code | Write TTS audio binary to a temp file for ffmpeg |
| Run FFmpeg (Assemble Video) | Execute Command | Run ffmpeg to produce final 1080×1920 MP4 |
| Check FFmpeg Result | Code | Validate ffmpeg exit code; prepare YouTube metadata |
| YouTube: Init Resumable Upload | HTTP Request | Start resumable YouTube upload session (returns upload URL) |
| Prepare Video Upload | Code | Extract upload URL, read file size |
| YouTube: Upload Video Bytes | HTTP Request | Send raw MP4 bytes to YouTube resumable upload URL |
| Extract Video ID | Code | Parse uploaded video ID and build YouTube Shorts URL |
| Send Notification | HTTP Request | POST completion message to Discord/Slack/Telegram webhook |
| Final Summary | Code | Log and return final status + published URL |

---

## Customization Tips

### Change Content Style / Niche

Edit the **system prompt** inside the **Generate Script (LLM)** node's body JSON.

Examples:
- Change `"motivational or educational"` → `"horror facts"` for creepy facts content.
- Add `"always mention a specific emoji after each fact"` for emoji-heavy Shorts style.

### Add Subtitles / Captions

To burn subtitles into the video, modify the ffmpeg command in **Prepare FFmpeg Command** to use the `drawtext` filter:

```bash
ffmpeg -i input.mp4 -i audio.mp3 \
  -filter_complex "[0:v]scale=1080:1920,crop=1080:1920,drawtext=text='%{eif\:n\:d}':fontsize=48:fontcolor=white:x=(w-text_w)/2:y=h-100[v]" \
  -map "[v]" -map 1:a -shortest output.mp4
```

For word-level animated subtitles, consider **FFmpeg's `ass` subtitle filter** or tools like [Whisper](https://github.com/openai/whisper) (free, open-source) to auto-generate `.srt` files.

### Use a Different LLM

Change the `model` field in the **Generate Script (LLM)** node:
- `meta-llama/llama-3-8b-instruct:free` (Meta's Llama 3)
- `google/gemma-7b-it:free` (Google Gemma)

For HuggingFace Inference API (alternative):
- Base URL: `https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2`
- Header: `Authorization: Bearer hf_YOUR_TOKEN`

### Use Pixabay Instead of Pexels

Change the **Fetch Stock Videos** node URL to:
```
https://pixabay.com/api/videos/?key=YOUR_PIXABAY_KEY&q={{ encodeURIComponent($json.scenes[0].visual) }}&video_type=film&per_page=5
```

---

## Security Best Practices

1. **Never commit API keys.** This repo contains no real keys — only node templates.
2. Store all secrets in **n8n Credentials** (encrypted at rest by n8n).
3. For self-hosted n8n, set `N8N_ENCRYPTION_KEY` environment variable to a strong random string.
4. Rotate your API keys periodically.
5. Use the **least-privilege principle**: the YouTube OAuth scope only requests `youtube.upload`, not full account access.
6. Enable **n8n Basic Auth** or OAuth when exposing n8n on the internet.

---

## Limitations & Known Issues

| Limitation | Notes |
|-----------|-------|
| ffmpeg must be on n8n host | n8n Cloud does not support `Execute Command`. Use self-hosted n8n. |
| Single stock clip per video | Current workflow fetches one Pexels clip. Extend with multiple clips + ffmpeg concat for scene-by-scene cutting. |
| StreamElements TTS rate limits | No documented rate limits, but avoid sending very long texts (>500 chars). Split into scenes if needed. |
| OpenRouter free tier rate limits | ~20 requests/minute on free models. One video generation = 1 request. |
| YouTube upload quota | Default 10,000 units/day. One upload ≈ 1600 units. Max ~6 uploads/day without quota increase request. |
| Video quality | Free stock footage + basic ffmpeg assembly is functional but not studio-quality. |
| No error recovery | For production, add n8n **Error Workflow** and retry logic. |

---

## Reference Video Analysis

**Reference Short:** [https://www.youtube.com/shorts/E4sxmoEYhqg](https://www.youtube.com/shorts/E4sxmoEYhqg)

Based on the URL format and common patterns in viral AI Shorts:

| Attribute | Assumed Style | How This Workflow Matches |
|-----------|--------------|--------------------------|
| Duration | Under 60 seconds | Script prompt limits to ~120-150 words (~45-55s spoken) |
| Aspect ratio | 9:16 vertical | ffmpeg outputs 1080×1920 |
| Content style | Facts / motivational / educational | LLM prompt engineered for hook + facts + CTA |
| Visual style | Stock footage with text overlays | Pexels portrait videos + optional `drawtext` subtitles |
| Pacing | Fast-paced, energetic | Short sentences in script prompt, scene-based structure |
| Audio | Voice-over driven | StreamElements TTS for natural-sounding narration |
| Engagement | Strong hook in first 3 seconds | Explicit "HOOK" section in LLM system prompt |

> **Assumption:** The reference video follows the "5 facts / tips" format popular in motivational and educational Shorts channels, with a fast-paced voice-over narration over dynamic stock footage backgrounds, large on-screen text, and a closing call-to-action asking viewers to follow or subscribe.
