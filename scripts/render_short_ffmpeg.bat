@echo off
:: =============================================================================
:: render_short_ffmpeg.bat
:: =============================================================================
:: Composes a vertical YouTube Shorts-style MP4 (1080x1920, 9:16) by
:: combining a background video clip with a voice-over MP3.
::
:: Usage:
::   render_short_ffmpeg.bat "<bg_video>" "<voice_mp3>" "<output_mp4>"
::
:: Arguments:
::   %1  Full path to background video file (any format ffmpeg supports)
::   %2  Full path to voice-over audio file (MP3/WAV/AAC)
::   %3  Full path for the rendered output MP4
::
:: Requirements:
::   - ffmpeg must be installed and available on PATH
::     Download: https://ffmpeg.org/download.html  (add bin/ folder to PATH)
::
:: What this script does:
::   1. Scales the background video to 1080x1920 (vertical), cropping if needed.
::   2. Mixes in the voice-over audio track.
::   3. Trims the output to the shorter of the video or audio (-shortest).
::   4. Encodes with libx264 (video) + AAC (audio) — universally supported.
::
:: Exit codes:
::   0  — success (output file written)
::   1  — missing arguments
::   other — ffmpeg error code
:: =============================================================================

SETLOCAL EnableDelayedExpansion

SET "BG_VIDEO=%~1"
SET "VOICE_AUDIO=%~2"
SET "OUTPUT_MP4=%~3"

:: ---- Validate arguments ----
IF "%BG_VIDEO%"=="" (
    echo [render_short_ffmpeg] ERROR: Argument 1 (background video path) is missing.
    exit /b 1
)
IF NOT EXIST "%BG_VIDEO%" (
    echo [render_short_ffmpeg] ERROR: Background video not found: %BG_VIDEO%
    exit /b 1
)
IF "%VOICE_AUDIO%"=="" (
    echo [render_short_ffmpeg] ERROR: Argument 2 (voice MP3 path) is missing.
    exit /b 1
)
IF NOT EXIST "%VOICE_AUDIO%" (
    echo [render_short_ffmpeg] ERROR: Voice audio not found: %VOICE_AUDIO%
    exit /b 1
)
IF "%OUTPUT_MP4%"=="" (
    echo [render_short_ffmpeg] ERROR: Argument 3 (output MP4 path) is missing.
    exit /b 1
)

:: ---- Ensure output directory exists ----
FOR %%F IN ("%OUTPUT_MP4%") DO SET "OUT_DIR=%%~dpF"
IF NOT EXIST "%OUT_DIR%" (
    MKDIR "%OUT_DIR%"
    echo [render_short_ffmpeg] Created output directory: %OUT_DIR%
)

echo [render_short_ffmpeg] Starting video composition...
echo   Background : %BG_VIDEO%
echo   Voice-over : %VOICE_AUDIO%
echo   Output     : %OUTPUT_MP4%
echo.

:: ---- Run ffmpeg ----
:: -vf filter chain:
::   scale=1080:1920:force_original_aspect_ratio=increase
::       -> upscale keeping aspect ratio so smallest dim >= target
::   crop=1080:1920
::       -> centre-crop to exact 1080x1920
::   setsar=1
::       -> fix sample-aspect-ratio so players display correctly
::
:: -map 0:v:0  -> take video stream from input 0 (background)
:: -map 1:a:0  -> take audio stream from input 1 (voice-over)
:: -shortest   -> stop when shorter stream ends (avoids silent padding)

ffmpeg -y ^
  -i "%BG_VIDEO%" ^
  -i "%VOICE_AUDIO%" ^
  -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1" ^
  -c:v libx264 -preset fast -crf 23 ^
  -c:a aac -b:a 128k ^
  -map 0:v:0 -map 1:a:0 ^
  -shortest ^
  "%OUTPUT_MP4%"

IF %ERRORLEVEL% NEQ 0 (
    echo [render_short_ffmpeg] ERROR: ffmpeg exited with code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

echo.
echo [render_short_ffmpeg] SUCCESS: Video rendered.
echo OUTPUT_VIDEO=%OUTPUT_MP4%
exit /b 0
