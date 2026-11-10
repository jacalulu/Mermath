"""Generate every spoken prompt as <id>.m4a into app/Mermath/Resources/Voice/.

The app (SynthSpeaker) prefers a bundled Voice/<id>.m4a over speech synthesis,
so running this once replaces the robot voice everywhere. The prompt list
mirrors app/Mermath/Audio/PromptScript.swift - keep them in sync.

Casting (two characters):
  crab      - Shelly the crab guide: every dive prompt, hint and cheer.
  narrator  - the gentle mermaid voice that frames the game: who-is-diving,
              hellos, chest, grotto.

Usage (the ElevenLabs key lives in .env.local via `elevenlabs onboard init`):
  set -a; source .env.local; set +a; python3 tools/make-voice.py
  GEMINI_API_KEY=... python3 tools/make-voice.py --provider gemini
Options: --only <id-prefix>  --force  --dry-run
Needs: pip install elevenlabs (see requirements.txt)
"""
import argparse, base64, json, os, struct, subprocess, sys, tempfile, urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VOICE_DIR = os.path.join(ROOT, 'app', 'Mermath', 'Resources', 'Voice')

WORD = {1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five',
        6: 'six', 7: 'seven', 8: 'eight', 9: 'nine', 10: 'ten',
        11: 'eleven', 12: 'twelve', 13: 'thirteen', 14: 'fourteen', 15: 'fifteen',
        16: 'sixteen', 17: 'seventeen', 18: 'eighteen', 19: 'nineteen', 20: 'twenty'}

CHILDREN = {'ophelia': 'Ophelia', 'daphne': 'Daphne', 'violet': 'Violet'}
ITEMS = {'starfishLamp': 'starfish lamp', 'kelpCurtain': 'kelp curtain', 'shellBed': 'shell bed'}


def prompts():
    """(id, text, character) for every line in PromptScript.swift."""
    out = []
    for n in range(1, 11):
        w = WORD[n]
        out.append((f'tide-listen-{n}', f'Find the number {w}!', 'crab'))
        out.append((f'tide-count-{n}', 'Count the bubbles! How many are there?', 'crab'))
        counting = ', '.join(WORD[i] for i in range(1, n + 1))
        out.append((f'hint-count-{n}', f'Count with me: {counting}!', 'crab'))
        out.append((f'praise-{n}', f'You found {w}!', 'crab'))
        out.append((f'tenth-pearl-{n}', f'You found {w}! That makes ten pearls! Open the chest!', 'crab'))
    for a in range(1, 10):
        for b in range(1, 11 - a):
            wa, wb, ws = WORD[a], WORD[b], WORD[a + b]
            first = ', '.join(WORD[i] for i in range(1, a + 1))
            rest = ', '.join(WORD[i] for i in range(a + 1, a + b + 1))
            out.append((f'reef-{a}-plus-{b}', f'What is {wa} and {wb}?', 'crab'))
            out.append((f'reef-hint-{a}-{b}', f'Count all the shells: {first}, and then {rest}!', 'crab'))
            out.append((f'reef-praise-{a}-{b}', f'{wa} and {wb} make {ws}!', 'crab'))
            out.append((f'reef-tenth-{a}-{b}', f'{wa} and {wb} make {ws}! That makes ten pearls! Open the chest!', 'crab'))
    # Intro cinematic
    out.append(('intro-1', 'Deep under the sea, three little mermaid sisters kept their treasures in a cozy grotto.', 'narrator'))
    out.append(('intro-2', 'One day, a great big whale swam by. And then. Aaah. Aaah. AAACHOO!', 'narrator'))
    out.append(('intro-3', 'The sneeze swept the treasures all across the sea!', 'narrator'))
    out.append(('intro-4', 'Oh no! The treasures washed away! Who is diving today?', 'crab'))
    # Treasure hunt
    out.append(('chest-map', 'And look! A treasure map!', 'narrator'))
    out.append(('hunt-intro', 'Follow the map! Can you find all the treasures?', 'crab'))
    out.append(('hunt-found', 'You found them all! Hooray!', 'crab'))
    # Deep Sea: counting by 2s and 5s
    out.append(('deep-intro', 'Welcome to the Deep Sea! Swim through the right ring!', 'crab'))
    for step, currents in ((2, (2, 4, 6, 8)), (5, (5, 10, 15))):
        by = 'twos' if step == 2 else 'fives'
        for c in currents:
            t2 = c + step
            out.append((f'deep-{step}-{c}', f'Count by {by}! What comes after {WORD[c]}?', 'crab'))
            counting = ', '.join(WORD[i] for i in range(step, t2 + 1, step))
            out.append((f'deep-hint-{step}-{t2}', f'Count with me: {counting}!', 'crab'))
    for t2 in (4, 6, 8, 10, 15, 20):
        out.append((f'deep-praise-{t2}', f"That's it! {WORD[t2].capitalize()}!", 'crab'))
        out.append((f'deep-tenth-{t2}', f'{WORD[t2].capitalize()}! That makes ten pearls! Open the chest!', 'crab'))
    out.append(('who-is-diving', 'Who is diving today?', 'narrator'))
    for key, name in CHILDREN.items():
        out.append((f'hello-{key}', f'Hello {name}! Where shall we dive?', 'narrator'))
    out.append(('chest-open', 'Ten pearls! The chest is open!', 'narrator'))
    for key, name in ITEMS.items():
        out.append((f'earned-{key}', f'You earned a {name}! Put it in your grotto!', 'narrator'))
    out.append(('my-grotto', 'Look at your grotto! Dive again to earn more treasures!', 'narrator'))
    return out


# ---------------- ElevenLabs (SDK; reads ELEVENLABS_API_KEY from the env) ----------------

ELEVEN_CAST = {'crab': 'Jessica', 'narrator': 'Sarah'}  # premade voices, by first name
ELEVEN_MODEL = 'eleven_v4'  # v4 supports only stability/similarity settings


def eleven_client():
    from elevenlabs import ElevenLabs
    return ElevenLabs()


def eleven_voices(client):
    """Premade voices only (Voice Library voices 402 on free plans), keyed by
    first name: the dashboard lists them as 'Jessica - Playful, Bright, Warm'."""
    return {v.name.split(' - ')[0].strip(): v.voice_id
            for v in client.voices.get_all().voices if v.category == 'premade'}


def eleven_tts(client, voice_id, text, path_mp3):
    from elevenlabs import VoiceSettings
    audio = client.text_to_speech.convert(
        text=text,
        voice_id=voice_id,
        model_id=ELEVEN_MODEL,
        output_format='mp3_44100_128',
        voice_settings=VoiceSettings(stability=0.5, similarity_boost=0.75),
    )
    with open(path_mp3, 'wb') as f:
        for chunk in audio:
            f.write(chunk)


# ---------------- Gemini ----------------

GEMINI_CAST = {'crab': 'Puck', 'narrator': 'Sulafat'}
GEMINI_MODEL = 'gemini-2.5-flash-preview-tts'
STYLE = {'crab': 'Say this like a bouncy, friendly little crab talking to a small child, warm and clear, not too fast: ',
         'narrator': 'Say this like a gentle storybook narrator talking to a small child, warm and clear, not too fast: '}


def gemini_tts(key, voice, character, text, path_wav):
    body = json.dumps({
        'contents': [{'parts': [{'text': STYLE[character] + text}]}],
        'generationConfig': {
            'responseModalities': ['AUDIO'],
            'speechConfig': {'voiceConfig': {'prebuiltVoiceConfig': {'voiceName': voice}}},
        },
    }).encode()
    req = urllib.request.Request(
        f'https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent',
        data=body, headers={'x-goog-api-key': key, 'content-type': 'application/json'})
    data = json.load(urllib.request.urlopen(req))
    pcm = base64.b64decode(data['candidates'][0]['content']['parts'][0]['inlineData']['data'])
    with open(path_wav, 'wb') as f:  # 24 kHz 16-bit mono PCM -> WAV
        f.write(struct.pack('<4sI4s4sIHHIIHH4sI', b'RIFF', 36 + len(pcm), b'WAVE', b'fmt ',
                            16, 1, 1, 24000, 48000, 2, 16, b'data', len(pcm)))
        f.write(pcm)


def to_m4a(src, dst):
    subprocess.run(['afconvert', '-f', 'm4af', '-d', 'aac', '-b', '64000', src, dst],
                   check=True, capture_output=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--provider', choices=['elevenlabs', 'gemini'], default='elevenlabs')
    ap.add_argument('--only', help='only ids starting with this prefix')
    ap.add_argument('--force', action='store_true', help='regenerate existing files')
    ap.add_argument('--dry-run', action='store_true')
    args = ap.parse_args()

    todo = [(i, t, c) for i, t, c in prompts() if not args.only or i.startswith(args.only)]
    os.makedirs(VOICE_DIR, exist_ok=True)
    if args.dry_run:
        for i, t, c in todo:
            print(f'{c:9} {i:24} {t}')
        print(len(todo), 'prompts')
        return

    if args.provider == 'elevenlabs':
        if not os.environ.get('ELEVENLABS_API_KEY'):
            sys.exit('set ELEVENLABS_API_KEY (the CLI onboarding put it in .env.local)')
        client = eleven_client()
        ids = eleven_voices(client)
        cast = {}
        for who, name in ELEVEN_CAST.items():
            if name not in ids:
                sys.exit(f'voice {name!r} not in this account; available: {", ".join(sorted(ids))}')
            cast[who] = ids[name]
    else:
        key = os.environ.get('GEMINI_API_KEY') or sys.exit('set GEMINI_API_KEY')

    done = skipped = 0
    for pid, text, character in todo:
        dst = os.path.join(VOICE_DIR, pid + '.m4a')
        if os.path.exists(dst) and not args.force:
            skipped += 1
            continue
        with tempfile.NamedTemporaryFile(suffix='.mp3' if args.provider == 'elevenlabs' else '.wav',
                                         delete=False) as tmp:
            raw = tmp.name
        try:
            if args.provider == 'elevenlabs':
                eleven_tts(client, cast[character], text, raw)
            else:
                gemini_tts(key, GEMINI_CAST[character], character, text, raw)
            to_m4a(raw, dst)
        finally:
            os.unlink(raw)
        done += 1
        print(f'{done + skipped}/{len(todo)} {pid}', flush=True)
    print(f'done: {done} generated, {skipped} already there -> {VOICE_DIR}')


if __name__ == '__main__':
    main()
