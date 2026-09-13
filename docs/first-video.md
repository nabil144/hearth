# First video

How to get from Met stills to one cartoon short without turning the nightly lesson into a film.

## What we are making

A 40 to 60 second short for chapter 4. Three cartoon stills. Voice over. A question at the end. Link under the video: https://nabil144.github.io/hearth/web/?lesson=greek-04

That is one of the plan's ten "most people can't name Zeus's siblings" videos. It is not the in-app lesson. The app keeps beat-by-beat stills, a check, a variant, and recall. A single film has no place to pause for the family check.

## Why Fal, and how you connect it

Fal hosts an official MCP at `https://mcp.fal.ai/mcp`. The MCP is free. You pay only for model runs on your key.

In Cursor: Command Palette, "Open MCP settings", add this to the **user** `mcp.json` (usually `~/.cursor/mcp.json`). Do not commit the key.

```json
{
  "mcpServers": {
    "fal-ai": {
      "url": "https://mcp.fal.ai/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_FAL_KEY"
      }
    }
  }
}
```

Restart Cursor. A new session should see Fal tools (`search_models`, `get_model_schema`, `get_pricing`, `run_model`, and the job tools). Ask it to search illustration or Flux models, check price, then generate from `content/prompts.json`.

If the tools do not appear, the key is wrong or the server was added to the project file instead of the user file. Fix that before writing prompts by hand into a website.

## Order of work

Do these in order. Tick them in [STATUS.md](STATUS.md) when they land.

1. **Connect Fal MCP.** Owner. Session cannot generate until this is true.
2. **Lock a style and a model.** One paragraph in `content/prompts.json` (`style`). One Fal `endpoint_id` after a search. While testing, pick a cheap illustration endpoint (Recraft 20b, Flux schnell), not Recraft V3 or Pro. Not a photoreal one. Generate two test faces of Kronos. If they do not look like kin, pick another cheap model.
3. **Generate the three short stills.** Prompts already drafted in `content/prompts.json` under `firstVideo.shots`. Every still in a short is the same size as a real vertical video: `imageSize` in `prompts.json`, currently `portrait_16_9` (1024x1820). Do not mix landscape into the set. Save files to `web/shorts/siblings-0.jpg` and so on. Write the Fal URL and the local path back into the json. Do not replace `web/stills/` yet. Those Met files still run the POC.
4. **Voice.** `node tools/tts.mjs --short` reads each shot's `spoken` field and writes `web/shorts/<id>.mp3`. Same Cartesia voice and hash skip as the lesson clips. Do not use the full chapter-4 beat 0 mp3.
5. **Assemble.** `node tools/assemble.mjs` (or `node tools/assemble.mjs pocVideo`). ffmpeg on this machine. 1080x1920. Each still holds for its clip. Zoom is slow and continuous across the whole voice (`1` to `1.16`). All shots are portrait. Hard cuts. No lip sync. No image-to-video model on the first cut. CapCut on a phone is optional polish after the mp4 exists. There is no official CapCut MCP worth adding.
6. **Watch it.** If a face changes mid-short, regenerate that still with the same model and a tighter prompt. Do not switch models mid-set.
7. **Only after the short exists.** Optionally generate cartoon stills for every `still` beat in chapters 3 to 5 and point `beat.still.src` at them. The player does not change. Credits become "Hearth, after the Theogony" instead of the Met line.

## Style lock

Reuse this paragraph at the front of every prompt. Edit it in `content/prompts.json` only, then copy it here if it changes.

Flat painted illustration. Bold contour, limited earth palette, no photoreal skin, no cinematic lighting, no Marvel or God of War armor, no modern clothes. Figures in profile or three-quarter like a Greek vase that someone cleaned up. Night interior, warm dark ground.

Forbidden in every prompt: photoreal, 3D render, movie still, hammer, lightning superhero pose, "hyper detailed eyes".

## What not to do

- Do not generate a full-chapter mp4 for the iOS player. Split at the check if that idea comes back.
- Do not use Kling, Runway, or Fal video models for the first short.
- Do not scrape a children's book or Percy Jackson art as a style reference.
- Do not commit `FAL_KEY`, `.env`, or a project `mcp.json` that contains the bearer token.

## When a new session picks this up

Read [STATUS.md](STATUS.md). Open `content/prompts.json`. If `model` is still empty, search Fal first. If shots have `file` paths, those images exist. Generate only the shots whose `file` is null. If `firstVideo.file` is set, the mp4 exists. Watch it before changing the model. Update STATUS when a shot or the cut lands.
