# n8n Workflows

This folder contains exported n8n workflow JSON files for the **CodeAlpha Internship** automation projects.

## Workflows

| File | Description |
|------|-------------|
| [`ai-video-agent-workflow.json`](./ai-video-agent-workflow.json) | Full AI video agent pipeline that generates a script, fetches stock footage, creates TTS audio, assembles a 9:16 vertical MP4 with ffmpeg, and uploads it to YouTube Shorts — using only free-tier services. |

## How to Import a Workflow

1. Open your n8n instance (cloud or self-hosted).
2. Go to **Workflows → Import from File**.
3. Select the `.json` file from this folder.
4. Configure the required credentials (see [`docs/ai-video-agent-setup.md`](../docs/ai-video-agent-setup.md)).
5. Activate or manually trigger the workflow.

## Notes

- All secret keys are stored in **n8n Credentials** or environment variables — never hardcoded.
- See the detailed setup guide in `docs/ai-video-agent-setup.md` before running any workflow.
