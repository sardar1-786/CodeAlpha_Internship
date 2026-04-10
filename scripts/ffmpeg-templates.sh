#!/usr/bin/env bash
# =============================================================================
# ffmpeg Templates for AI YouTube Shorts Video Assembly
# =============================================================================
# These scripts demonstrate how to assemble vertical (9:16) MP4 videos
# suitable for YouTube Shorts using only free, open-source ffmpeg.
#
# Requirements:
#   - ffmpeg installed (https://ffmpeg.org/download.html)
#   - Input files: background video, TTS audio MP3
#
# All paths below are examples — adjust to match your actual file locations.
# =============================================================================

set -e

# ---------------------------------------------------------------------------
# Variables (adjust before running)
# ---------------------------------------------------------------------------
INPUT_VIDEO="input_background.mp4"   # Stock footage from Pexels / Pixabay
INPUT_AUDIO="tts_audio.mp3"          # TTS-generated voice-over
OUTPUT_FILE="output_shorts.mp4"      # Final 9:16 vertical video
SUBTITLE_TEXT="5 Facts That Will Blow Your Mind"  # On-screen title text
FONT_SIZE=72
TEXT_COLOR="white"
SHADOW_COLOR="black"
WIDTH=1080
HEIGHT=1920
# Frame rate: 30 fps is broadly compatible (NTSC/web). Change to 25 for PAL
# or 24 for film-style content.
FPS=30

# ---------------------------------------------------------------------------
# Template 1: Basic vertical crop + audio overlay
# ---------------------------------------------------------------------------
# Crops/scales any input video to 1080x1920 (9:16) and adds the TTS audio.
# The video ends when the audio ends (-shortest flag).
# ---------------------------------------------------------------------------
basic_vertical_with_audio() {
  echo "[Template 1] Basic vertical video with TTS audio..."
  ffmpeg -y \
    -i "$INPUT_VIDEO" \
    -i "$INPUT_AUDIO" \
    -filter_complex \
      "[0:v]scale=${WIDTH}:${HEIGHT}:force_original_aspect_ratio=increase,\
crop=${WIDTH}:${HEIGHT},\
setsar=1[v]" \
    -map "[v]" \
    -map "1:a" \
    -shortest \
    -c:v libx264 -preset fast -crf 23 \
    -c:a aac -b:a 128k \
    "$OUTPUT_FILE"
  echo "Done: $OUTPUT_FILE"
}

# ---------------------------------------------------------------------------
# Template 2: Vertical crop + audio + centered title text overlay
# ---------------------------------------------------------------------------
# Adds a white title text with a semi-transparent black background box
# centered horizontally in the upper-middle portion of the frame.
# ---------------------------------------------------------------------------
vertical_with_title_text() {
  echo "[Template 2] Vertical video with centered title text..."
  ffmpeg -y \
    -i "$INPUT_VIDEO" \
    -i "$INPUT_AUDIO" \
    -filter_complex \
      "[0:v]scale=${WIDTH}:${HEIGHT}:force_original_aspect_ratio=increase,\
crop=${WIDTH}:${HEIGHT},\
setsar=1,\
drawtext=text='${SUBTITLE_TEXT}':\
fontsize=${FONT_SIZE}:\
fontcolor=${TEXT_COLOR}:\
shadowcolor=${SHADOW_COLOR}:\
shadowx=3:\
shadowy=3:\
x=(w-text_w)/2:\
y=h/4:\
line_spacing=20[v]" \
    -map "[v]" \
    -map "1:a" \
    -shortest \
    -c:v libx264 -preset fast -crf 23 \
    -c:a aac -b:a 128k \
    "$OUTPUT_FILE"
  echo "Done: $OUTPUT_FILE"
}

# ---------------------------------------------------------------------------
# Template 3: Ken Burns pan/zoom effect (image as background)
# ---------------------------------------------------------------------------
# If you have a static image instead of a video (e.g., from an image
# generation API), this template animates it with a slow zoom-in (Ken Burns).
# Duration is derived from the TTS audio length.
# ---------------------------------------------------------------------------
image_with_ken_burns_and_audio() {
  local INPUT_IMAGE="background_image.jpg"
  echo "[Template 3] Image + Ken Burns zoom + TTS audio..."

  # Get audio duration in seconds
  DURATION=$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$INPUT_AUDIO")

  # Compute total frames from duration and frame rate
  TOTAL_FRAMES=$(echo "$DURATION * $FPS" | bc | cut -d. -f1)

  ffmpeg -y \
    -loop 1 -i "$INPUT_IMAGE" \
    -i "$INPUT_AUDIO" \
    -r "$FPS" \
    -filter_complex \
      "[0:v]scale=8000:-1,\
zoompan=z='min(zoom+0.0005,1.5)':\
d=${TOTAL_FRAMES}:\
x='iw/2-(iw/zoom/2)':\
y='ih/2-(ih/zoom/2)':\
s=${WIDTH}x${HEIGHT},\
setsar=1[v]" \
    -map "[v]" \
    -map "1:a" \
    -t "$DURATION" \
    -c:v libx264 -preset fast -crf 23 \
    -c:a aac -b:a 128k \
    "$OUTPUT_FILE"
  echo "Done: $OUTPUT_FILE"
}

# ---------------------------------------------------------------------------
# Template 4: Multi-clip concatenation (scene-by-scene)
# ---------------------------------------------------------------------------
# Concatenates multiple short video clips (one per scene) into a single
# vertical video, then adds the full TTS audio track on top.
# Pass clip filenames as arguments: ./ffmpeg-templates.sh clip1.mp4 clip2.mp4 ...
# ---------------------------------------------------------------------------
multi_clip_concat_with_audio() {
  echo "[Template 4] Multi-clip concat + TTS audio..."

  # Use mktemp for safe, unique temporary paths (avoids race conditions)
  local CONCAT_FILE
  CONCAT_FILE=$(mktemp /tmp/concat_list.XXXXXX.txt)
  local CONCAT_OUTPUT
  CONCAT_OUTPUT=$(mktemp /tmp/concat_output.XXXXXX.mp4)

  for clip in "$@"; do
    # Each clip is first scaled/cropped to 9:16
    local out
    out=$(mktemp /tmp/clip_XXXXXX.mp4)
    ffmpeg -y -i "$clip" \
      -vf "scale=${WIDTH}:${HEIGHT}:force_original_aspect_ratio=increase,crop=${WIDTH}:${HEIGHT},setsar=1" \
      -c:v libx264 -preset fast -crf 23 -an \
      "$out"
    echo "file '$out'" >> "$CONCAT_FILE"
  done

  # Concatenate all scaled clips
  ffmpeg -y -f concat -safe 0 -i "$CONCAT_FILE" \
    -c copy "$CONCAT_OUTPUT"

  # Add TTS audio
  ffmpeg -y \
    -i "$CONCAT_OUTPUT" \
    -i "$INPUT_AUDIO" \
    -map "0:v" -map "1:a" \
    -shortest \
    -c:v copy -c:a aac -b:a 128k \
    "$OUTPUT_FILE"

  # Clean up temp files
  rm -f "$CONCAT_FILE" "$CONCAT_OUTPUT"

  echo "Done: $OUTPUT_FILE"
}

# ---------------------------------------------------------------------------
# Template 5: Add dark overlay + subtitle burn-in from SRT file
# ---------------------------------------------------------------------------
# Adds a semi-transparent dark overlay over the video (improves text
# readability), then burns an SRT subtitle file into the video.
# Useful when you generate subtitles via OpenAI Whisper or similar tools.
# ---------------------------------------------------------------------------
vertical_with_subtitles() {
  local SRT_FILE="subtitles.srt"
  echo "[Template 5] Vertical video with dark overlay + SRT subtitles..."
  ffmpeg -y \
    -i "$INPUT_VIDEO" \
    -i "$INPUT_AUDIO" \
    -filter_complex \
      "[0:v]scale=${WIDTH}:${HEIGHT}:force_original_aspect_ratio=increase,\
crop=${WIDTH}:${HEIGHT},\
setsar=1,\
subtitles=${SRT_FILE}:force_style='FontSize=52,PrimaryColour=&H00FFFFFF,\
OutlineColour=&H00000000,Outline=3,Shadow=2,Alignment=2,MarginV=80'[v]" \
    -map "[v]" \
    -map "1:a" \
    -shortest \
    -c:v libx264 -preset fast -crf 23 \
    -c:a aac -b:a 128k \
    "$OUTPUT_FILE"
  echo "Done: $OUTPUT_FILE"
}

# ---------------------------------------------------------------------------
# Template 6: Thumbnail extraction (first frame as cover image)
# ---------------------------------------------------------------------------
# YouTube Shorts benefits from a custom thumbnail. This extracts the
# first frame of the finished video as a JPEG thumbnail.
# ---------------------------------------------------------------------------
extract_thumbnail() {
  local THUMB_OUTPUT="thumbnail.jpg"
  echo "[Template 6] Extracting thumbnail from output video..."
  ffmpeg -y \
    -i "$OUTPUT_FILE" \
    -vframes 1 \
    -q:v 2 \
    "$THUMB_OUTPUT"
  echo "Thumbnail saved: $THUMB_OUTPUT"
}

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
# Uncomment the template you want to test, then run:
#   chmod +x scripts/ffmpeg-templates.sh
#   ./scripts/ffmpeg-templates.sh
#
# Or call specific templates from n8n's Execute Command node, e.g.:
#   ffmpeg -y -i "{{ $json.videoUrl }}" -i "{{ $json.audioPath }}" \
#     -filter_complex "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1[v]" \
#     -map "[v]" -map "1:a" -shortest -c:v libx264 -preset fast -crf 23 \
#     -c:a aac -b:a 128k "{{ $json.outputPath }}"
# ---------------------------------------------------------------------------

# Default: run Template 1 (basic) when script is executed directly
basic_vertical_with_audio
