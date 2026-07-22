export interface Env {
  OLLAMA_API_KEY: string;
  VM_OLLAMA_SECRET: string;
}

interface TranslateRequestBody {
  text: string;
  targetLanguageIso: string;
  targetCardContent?: string;
}

interface TranslationResponseDto {
  sourceText: string;
  translatedText: string;
  confidenceScore: number;
  confidenceTier: string;
  appliedFlags: string[];
  warningTokens: string[];
}

// All real inference now goes through the VM's Cloudflare Tunnel + shared-
// secret relay (cloud_relay_proxy.py), which forwards to whichever backend
// the path prefix names. "vm-ollama" hits the VM's own local Ollama
// (currently only used by /identify, a light task); fast1/fast2/fast3 hit
// Groq/Cerebras/OpenRouter respectively using real API keys already
// configured on the VM (see BACKENDS in cloud_relay_proxy.py).
const VM_BASE_URL = 'https://ollama-vm.pb-aim.com';
const VM_OLLAMA_MODEL = 'gemma4:12b-it-q8_0'; // /identify only — see handleIdentify

// 2026-07-21: every translation (not just low-resource/ancient languages)
// now runs three independent translators plus an arbiter, all on real fast
// cloud inference (Groq LPU / Cerebras wafer-scale / OpenRouter) instead of
// the VM's own CPU — CPU-only 12B inference measured at ~53s for a single
// call, which is a non-starter for a live-feeling app. Decision: accept
// real per-token cloud cost rather than fight VM hardware; if usage ever
// gets expensive enough to matter, that means real adoption, and the blog
// says so plainly (beta, compute-constrained).
//
// Each role is a BENCH (Bench Architecture, ported from shard-accelerator's
// core/bench.py / D:\shard-accelerator\BENCH_ARCHITECTURE.md) rather than a
// single fixed model: callBenchJson() below picks a random starting
// candidate per call and fails over sequentially through the rest on error.
// This isn't just error handling — every provider enforces real TPM (tokens
// per minute) limits, and rotating a role across 2 candidates on different
// providers means neither one takes every single call, buying real
// breathing room under sustained traffic even with no errors at all.
//
// Roles are deliberately different model families where possible so the
// three translators aren't just agreeing with themselves; the arbiter uses
// gpt-oss-120b (OpenAI's open-weight model, explicitly documented as
// multilingual-capable) hosted on two different providers as its own bench
// — same weights both places, the safest possible fallback pairing.
interface BenchCandidate {
  backend: 'fast1' | 'fast2' | 'fast3'; // Groq / Cerebras / OpenRouter
  model: string;
}

const ISOLATE_A_BENCH: BenchCandidate[] = [
  { backend: 'fast1', model: 'llama-3.3-70b-versatile' }, // Groq
  { backend: 'fast3', model: 'mistralai/mistral-small-2603' }, // OpenRouter rest partner
];
const ISOLATE_B_BENCH: BenchCandidate[] = [
  { backend: 'fast2', model: 'gemma-4-31b' }, // Cerebras
  { backend: 'fast1', model: 'llama-3.1-8b-instant' }, // Groq rest partner
];
const ISOLATE_C_BENCH: BenchCandidate[] = [
  { backend: 'fast3', model: 'qwen/qwen3.6-flash' }, // OpenRouter
  { backend: 'fast2', model: 'gemma-4-31b' }, // Cerebras rest partner
];
const ARBITER_BENCH: BenchCandidate[] = [
  { backend: 'fast2', model: 'gpt-oss-120b' }, // Cerebras — ~3000 T/sec
  { backend: 'fast1', model: 'openai/gpt-oss-120b' }, // Groq — same weights, different host
];

// Real, observed failure: models (isolates AND the arbiter alike) confused
// 'arc' (Aramaic) with Arabic, and 'egy' (Ancient Egyptian) with Egyptian
// Arabic (the unrelated modern dialect) — both are similar-looking codes
// next to a much more famous language, and both isolates AND the arbiter
// shared the same wrong assumption, so multi-isolate arbitration alone
// couldn't catch it: consensus among participants with the same
// misunderstanding just produces confident wrong output. This needs
// explicit disambiguation in the prompt, not more arbitration.
const LANGUAGE_DISAMBIGUATION: Record<string, string> = {
  lat: 'Classical Latin, the language of ancient Rome — NOT any modern Romance language.',
  vat: 'Ecclesiastical Latin, the liturgical Latin of the Catholic Church — related to but not identical to Classical Latin, and NOT modern Italian.',
  grc: 'Classical/Ancient Greek, the language of ancient Athens — NOT Modern Greek.',
  arc: "Aramaic (ISO 639-3 code 'arc') — the ancient Semitic language of the Achaemenid Empire and the Peshitta Bible, related to Hebrew and Syriac. This is NOT Arabic despite the similar-looking code/name. Never output Arabic for this request. If asked to judge or compare candidates for this language: fluent, correctly-written Modern Standard Arabic is NOT an acceptable substitute for Aramaic no matter how coherent it reads — it is simply the wrong language and must be rejected in favor of an actual (even if imperfect or romanized) Aramaic attempt.",
  egy: "Ancient Egyptian (ISO 639-3 code 'egy') — the hieroglyphic-descended language of pharaonic Egypt, rendered as phonetic transcription since there is no synthesized script output. This is NOT Egyptian Arabic (the modern spoken dialect of the country of Egypt today) — those are unrelated languages that happen to share the word 'Egyptian'. Never output any form of Arabic for this request.",
};

// Auto-generated by find_confusable_v2.ps1 from assets/data/languages.json.
// Pairs where ISO codes are near-identical (edit distance 1, or share 2 of 3
// letters) AND language names share a 2+ character prefix. This is a proactive
// screen, not individually verified for every pair the way LANGUAGE_DISAMBIGUATION
// above is (arc/ara was found this way, then hand-verified via live testing) --
// treat entries here as "worth a caution clause", not confirmed live bugs.
const CONFUSABLE_CODES: Record<string, { iso: string; name: string }[]> = {
  ara: [{ iso: 'arc', name: 'Aramaic' }],
  arc: [{ iso: 'ara', name: 'Arabic' }],
  gub: [{ iso: 'guj', name: 'Gujarati' }],
  guj: [{ iso: 'gub', name: 'Guajajara' }],
  hid: [{ iso: 'hin', name: 'Hindi' }],
  hin: [{ iso: 'hid', name: 'Hidatsa' }],
  kam: [{ iso: 'kau', name: 'Kanuri' }, { iso: 'kaz', name: 'Kazakh' }],
  kau: [{ iso: 'kam', name: 'Kamba' }, { iso: 'kaz', name: 'Kazakh' }],
  kaz: [{ iso: 'kam', name: 'Kamba' }, { iso: 'kau', name: 'Kanuri' }],
  kha: [{ iso: 'khk', name: 'Khalkha' }, { iso: 'khm', name: 'Khmer' }],
  khk: [{ iso: 'kha', name: 'Khasi' }, { iso: 'khm', name: 'Khmer' }],
  khm: [{ iso: 'khk', name: 'Khalkha' }, { iso: 'kha', name: 'Khasi' }],
  kor: [{ iso: 'kos', name: 'Kosraean' }],
  kos: [{ iso: 'kor', name: 'Korean' }],
  lat: [{ iso: 'lkt', name: 'Lakhota' }],
  lbj: [{ iso: 'lbu', name: 'Labu' }],
  lbu: [{ iso: 'lbj', name: 'Ladakhi' }, { iso: 'lhu', name: 'Lahu' }],
  lhu: [{ iso: 'lbu', name: 'Labu' }],
  lkt: [{ iso: 'lat', name: 'Latin' }],
  mhx: [{ iso: 'mpx', name: 'Mangap-Mbula' }],
  mpx: [{ iso: 'mhx', name: 'Maru' }],
  myh: [{ iso: 'myn', name: 'Mayan' }],
  myn: [{ iso: 'myh', name: 'Makah' }],
  nah: [{ iso: 'naq', name: 'Nama' }, { iso: 'nav', name: 'Navajo' }],
  naq: [{ iso: 'nah', name: 'Nahuatl' }, { iso: 'nav', name: 'Navajo' }],
  nav: [{ iso: 'nah', name: 'Nahuatl' }, { iso: 'naq', name: 'Nama' }],
  pad: [{ iso: 'pao', name: 'Paiute' }, { iso: 'pan', name: 'Panjabi' }],
  pan: [{ iso: 'pao', name: 'Paiute' }, { iso: 'pwn', name: 'Paiwan' }, { iso: 'pad', name: 'Paumari' }],
  pao: [{ iso: 'ppo', name: 'Paamese' }, { iso: 'pan', name: 'Panjabi' }, { iso: 'pad', name: 'Paumari' }],
  pol: [{ iso: 'por', name: 'Portuguese' }],
  por: [{ iso: 'pol', name: 'Polish' }],
  ppo: [{ iso: 'pao', name: 'Paiute' }],
  pwn: [{ iso: 'pan', name: 'Panjabi' }],
  sag: [{ iso: 'san', name: 'Sanskrit' }],
  san: [{ iso: 'sag', name: 'Sango' }],
  sob: [{ iso: 'som', name: 'Somali' }],
  som: [{ iso: 'sob', name: 'So' }],
  swa: [{ iso: 'swe', name: 'Swedish' }],
  swe: [{ iso: 'swa', name: 'Swahili' }],
  tee: [{ iso: 'tel', name: 'Telugu' }],
  tel: [{ iso: 'tee', name: 'Tepehua' }],
  tha: [{ iso: 'ths', name: 'Thakali' }, { iso: 'thp', name: 'Thompson' }],
  thp: [{ iso: 'tha', name: 'Thai' }, { iso: 'ths', name: 'Thakali' }],
  ths: [{ iso: 'tha', name: 'Thai' }, { iso: 'thp', name: 'Thompson' }],
  wba: [{ iso: 'wbl', name: 'Wakhi' }],
  wbl: [{ iso: 'wba', name: 'Warao' }],
  yae: [{ iso: 'yao', name: 'Yao' }],
  yao: [{ iso: 'yae', name: 'Yaruro' }],
};

function languageClause(targetLanguageIso: string): string {
  const disambiguation = LANGUAGE_DISAMBIGUATION[targetLanguageIso];
  if (disambiguation) {
    return `${targetLanguageIso} — ${disambiguation}`;
  }
  // Broader, unverified screen: still worth a caution even without a
  // hand-written explanation, since we know this shape of collision is real
  // (that's exactly how arc/ara was found before it got a full entry above).
  const confusables = CONFUSABLE_CODES[targetLanguageIso];
  if (confusables && confusables.length > 0) {
    const list = confusables.map((c) => `'${c.iso}' (${c.name})`).join(', ');
    return `${targetLanguageIso} — CAUTION: this ISO code is easily confused with ${list}, a different, unrelated language. Do not substitute one for the other.`;
  }
  return targetLanguageIso;
}

// Ported verbatim from OnlineOpenAiRealtimeTranslationService.translateText()
// in the Flutter app (lib/data/services/openai_realtime_service.dart) so
// dev-time output via this Worker matches the OpenAI-backed path's behavior.
function buildSystemPrompt(targetLanguageIso: string, targetCardContent: string): string {
  return `You are a gpt-realtime-translate fallback text translator.
Translate the input text cleanly into the target language ${languageClause(targetLanguageIso)}.
Target grammar/vocabulary constraints are: ${targetCardContent}.
If the text contains highly high-stakes terms (hospital, doctor, medical, court, law, arrest), append 'MEDICAL_DOMAIN' or 'LEGAL_DOMAIN' to the flags.
Output strictly JSON conforming to:
{
  "sourceText": "...",
  "translatedText": "...",
  "confidenceScore": 0.98,
  "confidenceTier": "CLEAN",
  "appliedFlags": [],
  "warningTokens": []
}`;
}

// Judges three independently-produced candidate translations of the same
// source sentence. Word-order/synonym variation is expected and fine — only
// a real difference in meaning, register (e.g. a candidate isn't actually in
// the requested language/era), or a grammatical error should count as
// disagreement. "consensus" replaces the old binary agree/disagree now that
// there are three candidates instead of two: "full" (all three substantively
// agree), "majority" (two of three agree, one is an outlier), or "split"
// (no real agreement — all three differ or are unreliable).
function buildArbiterSystemPrompt(targetLanguageIso: string): string {
  return `You are an arbitration judge comparing three independently-produced translations of the same source sentence into the target language ${languageClause(targetLanguageIso)}.
Determine how much they substantively agree in meaning and grammatical correctness — differences in word order or synonym choice are FINE and do not count as disagreement.
Set consensus="full" if all three are substantively equivalent and each is coherent, correct text in the target language.
Set consensus="majority" if two of the three substantively agree and the third is a real outlier (different meaning, wrong register, not real/coherent text in the target language, or wrong language entirely).
Set consensus="split" if there is no real two-way agreement — all three differ substantively, or the ones that superficially match are each unreliable (gibberish, garbled characters, wrong language). Do not let a broken candidate "win" by default just because another is also broken.
The user message is a JSON object: {"sourceText": "...", "candidateA": "...", "candidateB": "...", "candidateC": "..."}.
CRITICAL: "bestTranslation" must contain the ACTUAL FULL TRANSLATED TEXT you are recommending — copy the real sentence out of whichever candidate you prefer (or write your own corrected version if none are fully right but the intent is clear). Never write the literal words "candidateA"/"candidateB"/"candidateC" as the value — those are field labels, not a translation, and doing so is a critical error.
When consensus is "majority" or "split", also set "disputedSpan" to the SPECIFIC source-language word or short phrase the disagreement is actually about (e.g. "train station"), if the disagreement is localized to one term rather than the whole sentence — most disagreements are. Set it to null only if the whole sentence is genuinely unreliable (e.g. one or more candidates are a different language entirely) rather than a single disputed term.
Output strictly JSON conforming to:
{
  "consensus": "full",
  "bestTranslation": "...",
  "disputedSpan": null,
  "reasoning": "short note, especially if consensus is not full",
  "confidenceScore": 0.95
}`;
}

// The arbiter model has, in testing, sometimes returned the literal string
// "candidateA"/"candidateB"/"candidateC" (the field label) instead of
// substituting the actual translated text despite explicit prompt
// instructions not to. Guard against that specific failure rather than
// trust the model's compliance.
function resolveBestTranslation(
  raw: string | undefined,
  candidateA: string,
  candidateB: string,
  candidateC: string,
): string {
  const trimmed = (raw ?? '').trim();
  const lower = trimmed.toLowerCase();
  if (lower === 'candidatea') return candidateA;
  if (lower === 'candidateb') return candidateB;
  if (lower === 'candidatec') return candidateC;
  return trimmed || candidateA;
}

// Providers' OpenAI-compatible endpoints don't all guarantee strict
// response_format: json_object support — extract the first JSON object from
// the response text rather than assume the whole message body is bare JSON.
function extractJson(text: string): Record<string, unknown> | null {
  const match = text.match(/\{[\s\S]*\}/);
  if (!match) return null;
  try {
    return JSON.parse(match[0]);
  } catch {
    return null;
  }
}

async function callOnce(
  backend: 'fast1' | 'fast2' | 'fast3' | 'ollama',
  model: string,
  system: string,
  userContent: string,
  env: Env,
): Promise<Record<string, unknown> | null> {
  const url = `${VM_BASE_URL}/${backend}/v1/chat/completions`;
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Soutuk-Secret': env.VM_OLLAMA_SECRET,
      },
      body: JSON.stringify({
        model,
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: userContent },
        ],
      }),
    });
    if (!response.ok) return null;
    const decoded = (await response.json()) as { choices: { message: { content: string } }[] };
    const content = decoded.choices?.[0]?.message?.content ?? '';
    return extractJson(content);
  } catch {
    return null;
  }
}

// Bench Architecture (ported from shard-accelerator, see comment above
// ISOLATE_A_BENCH): pick a random starting candidate — a stateless
// approximation of round-robin that still spreads load across a Worker's
// concurrent, independent invocations — then fail over sequentially through
// the rest of the bench if a candidate errors or a provider rate-limits.
// Only returns null if every candidate in the bench failed.
async function callBenchJson(
  bench: BenchCandidate[],
  system: string,
  userContent: string,
  env: Env,
): Promise<Record<string, unknown> | null> {
  const start = Math.floor(Math.random() * bench.length);
  for (let i = 0; i < bench.length; i++) {
    const candidate = bench[(start + i) % bench.length];
    const result = await callOnce(candidate.backend, candidate.model, system, userContent, env);
    if (result) return result;
  }
  return null;
}

function toTranslationDto(parsed: Record<string, unknown>, fallbackSource: string): TranslationResponseDto {
  return {
    sourceText: (parsed.sourceText as string) ?? fallbackSource,
    translatedText: (parsed.translatedText as string) ?? '',
    confidenceScore: (parsed.confidenceScore as number) ?? 0,
    confidenceTier: (parsed.confidenceTier as string) ?? 'UNCERTAIN',
    appliedFlags: (parsed.appliedFlags as string[]) ?? [],
    warningTokens: (parsed.warningTokens as string[]) ?? [],
  };
}

async function handleArbitratedTranslate(body: TranslateRequestBody, env: Env): Promise<Response> {
  const system = buildSystemPrompt(body.targetLanguageIso, body.targetCardContent ?? '');
  const [rawA, rawB, rawC] = await Promise.all([
    callBenchJson(ISOLATE_A_BENCH, system, body.text, env),
    callBenchJson(ISOLATE_B_BENCH, system, body.text, env),
    callBenchJson(ISOLATE_C_BENCH, system, body.text, env),
  ]);

  const succeeded = [rawA, rawB, rawC].filter((r): r is Record<string, unknown> => r !== null);
  if (succeeded.length === 0) {
    return Response.json(
      { error: 'All three translation isolates failed to return a usable translation' },
      { status: 502 },
    );
  }
  // Fewer than two successful candidates means there's nothing to actually
  // arbitrate between — a single clean translation beats none, so return it
  // directly rather than sending one candidate to the arbiter to "judge"
  // against itself.
  if (succeeded.length === 1) {
    return Response.json(toTranslationDto(succeeded[0], body.text));
  }

  const candidateA = (rawA?.translatedText as string) ?? '';
  const candidateB = (rawB?.translatedText as string) ?? '';
  const candidateC = (rawC?.translatedText as string) ?? '';

  const arbiterSystem = buildArbiterSystemPrompt(body.targetLanguageIso);
  const arbiterUser = JSON.stringify({ sourceText: body.text, candidateA, candidateB, candidateC });
  const arbiterParsed = await callBenchJson(ARBITER_BENCH, arbiterSystem, arbiterUser, env);

  // Arbiter failing shouldn't sink an otherwise-successful request — at
  // least two isolates already produced a candidate, so fall back to the
  // first successful one.
  if (!arbiterParsed) {
    return Response.json(toTranslationDto(succeeded[0], body.text));
  }

  const consensus = (arbiterParsed.consensus as string) ?? 'split';
  const combinedAppliedFlags = new Set<string>([
    ...((rawA?.appliedFlags as string[]) ?? []),
    ...((rawB?.appliedFlags as string[]) ?? []),
    ...((rawC?.appliedFlags as string[]) ?? []),
  ]);
  const bestTranslation = resolveBestTranslation(
    arbiterParsed.bestTranslation as string | undefined,
    candidateA,
    candidateB,
    candidateC,
  );

  if (consensus === 'full') {
    const result: TranslationResponseDto = {
      sourceText: body.text,
      translatedText: bestTranslation,
      confidenceScore: (arbiterParsed.confidenceScore as number) ?? 0.9,
      confidenceTier: 'CLEAN',
      appliedFlags: [...combinedAppliedFlags],
      warningTokens: [],
    };
    return Response.json(result);
  }

  // "majority" or "split" — escalate rather than silently pick a winner.
  // Still return a usable translatedText so the app has something to
  // display, but flag it so the app's warning banner surfaces the
  // uncertainty instead of hiding it. Scope the warning to the specific
  // disputed term when the arbiter identified one — most disagreements are
  // localized to one anachronistic/ambiguous word, not the whole sentence.
  const disputedSpan = (arbiterParsed.disputedSpan as string | null) ?? null;
  const reasoning = (arbiterParsed.reasoning as string) ?? '';
  const warningMessage = disputedSpan
    ? `Uncertain translation of "${disputedSpan}" — independent attempts disagreed on this term. ${reasoning}`.trim()
    : `Independent translation attempts disagreed and could not be reconciled with confidence. Candidate A: "${candidateA}" | Candidate B: "${candidateB}" | Candidate C: "${candidateC}". ${reasoning}`.trim();

  const result: TranslationResponseDto = {
    sourceText: body.text,
    translatedText: bestTranslation,
    confidenceScore: Math.min(consensus === 'majority' ? 0.75 : 0.6, (arbiterParsed.confidenceScore as number) ?? 0.5),
    confidenceTier: 'FLAG_FOR_REVIEW',
    appliedFlags: [...combinedAppliedFlags, 'TRANSLATION_DISAGREEMENT'],
    warningTokens: [warningMessage],
  };
  return Response.json(result);
}

interface IdentifyRequestBody {
  transcript: string;
}

interface IdentifyResponseDto {
  detectedIso: string | null;
  detectedName: string | null;
  confidence: number;
  sufficientSample: boolean;
  reasoning: string;
}

// Used by Conversation Mode's handshake phase: Person Two speaks, the app
// transcribes without pinning a language (gpt-4o-transcribe handles
// multilingual audio fine but — unlike whisper-1 — doesn't expose a detected
// language field), then this identifies the language from the resulting
// text. Kept as a separate text-based step rather than trying to coax a
// language guess out of the transcription call itself.
//
// Left on the VM's own local Ollama rather than moved to the cloud benches
// above — it's a light, quick task (not the translation-quality path this
// session's cloud migration was actually about), and gemma4:12b-it-q8_0 is
// already sitting there for it.
function buildIdentifySystemPrompt(): string {
  return `You identify the language of a short transcribed utterance for a translation app's language-handshake step.
Respond with your best-guess ISO 639-3 code and English name for the language, a confidence score, and whether the sample is long/distinctive enough to be confident at all.
Set sufficientSample=false if the utterance is too short, too generic (e.g. just a name, a greeting common to many languages), or otherwise not enough signal to identify a language with reasonable confidence — do not force a guess dressed up as confident.
If you genuinely cannot narrow it below several plausible candidates, set confidence low and explain the ambiguity in reasoning rather than picking one arbitrarily.
The user message is a JSON object: {"transcript": "..."}.
Output strictly JSON conforming to:
{
  "detectedIso": "xyz",
  "detectedName": "Language Name",
  "confidence": 0.85,
  "sufficientSample": true,
  "reasoning": "short note on why, especially if confidence is low or sufficientSample is false"
}`;
}

async function handleIdentify(request: Request, env: Env): Promise<Response> {
  const body = (await request.json()) as IdentifyRequestBody;
  if (!body.transcript || !body.transcript.trim()) {
    return Response.json({ error: 'transcript is required' }, { status: 400 });
  }

  const system = buildIdentifySystemPrompt();
  const userContent = JSON.stringify({ transcript: body.transcript });
  const parsed = await callOnce('ollama', VM_OLLAMA_MODEL, system, userContent, env);

  if (!parsed) {
    return Response.json(
      {
        detectedIso: null,
        detectedName: null,
        confidence: 0,
        sufficientSample: false,
        reasoning: 'Language identification call failed or returned unparseable output.',
      } satisfies IdentifyResponseDto,
      { status: 200 },
    );
  }

  const result: IdentifyResponseDto = {
    detectedIso: (parsed.detectedIso as string | null) ?? null,
    detectedName: (parsed.detectedName as string | null) ?? null,
    confidence: (parsed.confidence as number) ?? 0,
    sufficientSample: (parsed.sufficientSample as boolean) ?? false,
    reasoning: (parsed.reasoning as string) ?? '',
  };
  return Response.json(result);
}

async function handleTranslate(request: Request, env: Env): Promise<Response> {
  const body = (await request.json()) as TranslateRequestBody;
  if (!body.text || !body.targetLanguageIso) {
    return Response.json({ error: 'text and targetLanguageIso are required' }, { status: 400 });
  }
  // Every language now goes through the three-translator + arbiter pipeline
  // — see the comment above ISOLATE_A_BENCH for why the old single-model
  // common-case path was retired.
  return await handleArbitratedTranslate(body, env);
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    try {
      if (url.pathname === '/translate') {
        return await handleTranslate(request, env);
      }
      if (url.pathname === '/identify') {
        return await handleIdentify(request, env);
      }
      return new Response('Not found', { status: 404 });
    } catch (e) {
      return Response.json({ error: String(e) }, { status: 500 });
    }
  },
} satisfies ExportedHandler<Env>;
