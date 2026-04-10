#!/usr/bin/env python3
"""
TTS Script using gTTS (Google Text-to-Speech)
============================================
Usage:
    python tts_gtts.py <text_source> <output_mp3>

Arguments:
    text_source  : Either a path to a .txt file OR the text string itself.
                   If the argument is an existing file path, the script reads
                   the text from that file. Otherwise it uses the argument
                   directly as the text.
    output_mp3   : Full path where the generated MP3 should be saved.

Examples:
    python tts_gtts.py "C:\\output\\script.txt" "C:\\output\\voice.mp3"
    python tts_gtts.py "This is a test sentence." "C:\\output\\voice.mp3"

Install dependency:
    pip install gtts
"""

import sys
import os


def main():
    if len(sys.argv) < 3:
        print("ERROR: Not enough arguments.")
        print("Usage: python tts_gtts.py <text_file_or_text> <output_mp3>")
        sys.exit(1)

    text_input = sys.argv[1]
    output_path = sys.argv[2]

    # Determine if the first argument is a file path or raw text
    if os.path.isfile(text_input):
        with open(text_input, "r", encoding="utf-8") as f:
            text = f.read().strip()
        print(f"[tts_gtts] Reading script from file: {text_input}")
    else:
        text = text_input.strip()
        print(f"[tts_gtts] Using inline text ({len(text)} characters).")

    if not text:
        print("ERROR: Empty text — nothing to convert to speech.")
        sys.exit(1)

    # Ensure the output directory exists
    output_dir = os.path.dirname(os.path.abspath(output_path))
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)
        print(f"[tts_gtts] Created output directory: {output_dir}")

    # Generate speech with gTTS
    try:
        from gtts import gTTS  # noqa
    except ImportError:
        print("ERROR: 'gtts' package is not installed.")
        print("Fix: pip install gtts")
        sys.exit(1)

    try:
        tts = gTTS(text=text, lang="en", slow=False)
        tts.save(output_path)
        print(f"SUCCESS: Audio saved to {output_path}")
        # Print a machine-readable marker so the n8n Execute Command node
        # can easily parse the output path from stdout.
        print(f"OUTPUT_AUDIO={output_path}")
        sys.exit(0)
    except Exception as exc:
        print(f"ERROR: gTTS failed — {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
