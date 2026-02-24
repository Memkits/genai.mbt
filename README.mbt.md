# tiye/genai

> **This project is AI-generated.**  
> The code and documentation were produced with GitHub Copilot and are maintained with AI assistance.  
> PRs are welcome — please include a runnable example in `src/cmd/main/main.mbt` that exercises the new feature, so the AI agent can verify correctness by running it.

MoonBit bindings for the [Google Gemini **Interactions API**](https://ai.google.dev/api/interactions-api)
(JS backend, Node.js).

Tracked SDK: [`@google/genai`](https://github.com/googleapis/js-genai) **v1.42.0**

---

## Scope

This package covers **only** the Interactions API (`ai.interactions.*`).
The following surfaces are **intentionally excluded** and will not be added:

| Excluded surface                            | Reason                           |
| ------------------------------------------- | -------------------------------- |
| `generateContent` / `generateContentStream` | Legacy stateless API             |
| `Chat` helper class                         | Wrapper around `generateContent` |
| `Live` (WebSocket streaming)                | Different transport model        |
| `Models`, `Files`, `Caches`, `Operations`   | Out of scope                     |

If you need those surfaces, use the JS SDK directly or a different binding package.

---

## Implementation status

### Client

| Feature                                             | Status  | Notes                                |
| --------------------------------------------------- | ------- | ------------------------------------ |
| `GoogleGenAI::new(api_key)`                         | ✅ done |                                      |
| `GoogleGenAI::new_with_base_url(api_key, base_url)` | ✅ done | For reverse-proxy / internal network |

### `interactions.*` methods

| JS method                     | MoonBit method                              | Status             | Notes                                   |
| ----------------------------- | ------------------------------------------- | ------------------ | --------------------------------------- |
| `interactions.create(params)` | `ai.interactions_create(params)`            | ✅ done            | null fields are stripped before sending |
| `interactions.create(stream)` | `ai.interactions_create_stream(params, cb)` | ✅ done            | SSE callback-based streaming            |
| `interactions.get(id)`        | `ai.interactions_get(id)`                   | ✅ done            |                                         |
| `interactions.cancel(id)`     | `ai.interactions_cancel(id)`                | ✅ done            |                                         |
| `interactions.delete(id)`     | `ai.interactions_delete(id)`                | ✅ done            |                                         |
| `interactions.list(...)`      | —                                           | ❌ not implemented | Not yet in SDK stable surface           |
| Tool-result submission        | —                                           | ❌ not implemented | Required for `RequiresAction` flow      |

### `CreateParams` field coverage

| Field                     | Type                | Status     | Notes                                                        |
| ------------------------- | ------------------- | ---------- | ------------------------------------------------------------ |
| `model`                   | `String`            | ✅ done    |                                                              |
| `input`                   | `Input`             | ✅ done    | `Plain` / `Parts` / `Turns` variants                         |
| `previous_interaction_id` | `String?`           | ✅ done    |                                                              |
| `store`                   | `Bool?`             | ✅ done    |                                                              |
| `system_instruction`      | `String?`           | ✅ done    |                                                              |
| `generation_config`       | `GenerationConfig?` | ✅ done    | see below                                                    |
| `tools`                   | `Array[Tool]?`      | ✅ done    | `Function` / `GoogleSearch` / `CodeExecution` / `URLContext` / `ComputerUse` / `MCPServer` / `FileSearch` |
| `response_modalities`     | `Array[String]?`    | ✅ done    | `"text"` / `"image"` / `"audio"`                             |
| `response_format`         | `Json?`             | ✅ done    | pass a JSON Schema                                           |
| `response_mime_type`      | `String?`           | ✅ done    |                                                              |
| `background`              | `Bool?`             | ✅ done    | For async long-running interactions + `cancel` (**untested**) |
| `stream`                  | `Bool?`             | ✅ done    | Prefer `interactions_create_stream` instead                   |

### `GenerationConfig` field coverage

| Field                | Type                   | Status     |
| -------------------- | ---------------------- | ---------- | ---------------------------------- |
| `max_output_tokens`  | `Int?`                 | ✅ done    |
| `temperature`        | `Double?`              | ✅ done    |
| `top_p`              | `Double?`              | ✅ done    |
| `seed`               | `Int?`                 | ✅ done    |
| `stop_sequences`     | `Array[String]?`       | ✅ done    |
| `thinking_level`     | `String?`              | ✅ done    |
| `thinking_summaries` | `String?`              | ✅ done    |
| `speech_config`      | `Array[SpeechConfig]?` | ✅ done    |                                              |
| `image_config`       | `ImageConfig?`         | ✅ done    | `aspect_ratio`, `image_size` (**untested**)  |
| `tool_choice`        | `Json?`                | ✅ done    | Free-form JSON for `mode` etc. (**untested**)|

### `Interaction` (response) field coverage

| Field                     | Type                | Status     | Notes                                |
| ------------------------- | ------------------- | ---------- | ------------------------------------ |
| `id`                      | `String`            | ✅ done    |                                      |
| `status`                  | `InteractionStatus` | ✅ done    |                                      |
| `model`                   | `String?`           | ✅ done    |                                      |
| `outputs`                 | `Array[Content]?`   | ✅ done    |                                      |
| `previous_interaction_id` | `String?`           | ✅ done    |                                      |
| `role`                    | `String?`           | ✅ done    |                                      |
| `usage`                   | `Usage?`            | ✅ done    |                                      |
| `created`                 | `String?`           | ✅ done    | ISO 8601                             |
| `updated`                 | `String?`           | ✅ done    | ISO 8601                             |
| `agent`                   | `String?`           | ✅ done    | Agent name (e.g. deep-research) (**untested**) |

### Content block coverage

| Variant                | Encode | Decode | Notes                         |
| ---------------------- | ------ | ------ | ----------------------------- |
| `Text`                 | ✅     | ✅     | includes `annotations`        |
| `Image`                | ✅     | ✅     | base64 `data` or `uri`        |
| `Audio`                | ✅     | ✅     | base64 `data` or `uri`        |
| `Document`             | ✅     | ✅     | **untested** — PDF/doc input  |
| `Video`                | ✅     | ✅     | **untested** — video input    |
| `Thought`              | ✅     | ✅     | signature + summary           |
| `FunctionCall`         | ✅     | ✅     |                               |
| `FunctionResult`       | ✅     | ✅     |                               |
| `CodeExecutionCall`    | ✅     | ✅     | **untested**                  |
| `CodeExecutionResult`  | ✅     | ✅     | **untested**                  |
| `GoogleSearchCall`     | ✅     | ✅     | **untested**                  |
| `GoogleSearchResult`   | ✅     | ✅     | **untested**                  |
| `URLContextCall`       | ✅     | ✅     | **untested**                  |
| `URLContextResult`     | ✅     | ✅     | **untested**                  |
| `MCPServerToolCall`    | ✅     | ✅     | **untested**                  |
| `MCPServerToolResult`  | ✅     | ✅     | **untested**                  |
| `FileSearchCall`       | ✅     | ✅     | **untested**                  |
| `FileSearchResult`     | ✅     | ✅     | **untested**                  |

### Streaming support

| Feature                                        | Status  | Notes                                       |
| ---------------------------------------------- | ------- | ------------------------------------------- |
| `interactions_create_stream(params, on_event)` | ✅ done | Callback-based SSE streaming                |
| `parse_event(json_str)`                        | ✅ done | Decodes SSE JSON into `InteractionEvent`    |
| `InteractionEvent` enum                        | ✅ done | Start / StatusUpdate / ContentStart / Delta / Stop / Complete / Error / Unknown |

### Promise / async utilities

| Function                          | Status                                                                |
| --------------------------------- | --------------------------------------------------------------------- |
| `promise_and_then(p, f)`          | ✅ done                                                               |
| `promise_seq(p, f)`               | ✅ done                                                               |
| `promise_unit()`                  | ✅ done                                                               |
| `run_async(p)`                    | ✅ done                                                               |
| `get_env(key)`                    | ✅ done                                                               |
| Promise error handling in MoonBit | ❌ missing — `JSPromise` rejection is untyped; no `catch` binding yet |

### Tests

| Area                                 | Status     |
| ------------------------------------ | ---------- |
| Unit tests (`genai_test.mbt`)        | ❌ empty   |
| White-box tests (`genai_wbtest.mbt`) | ❌ empty   |
| Encode round-trip tests              | ❌ missing |
| Decode round-trip tests              | ❌ missing |
| Snapshot tests                       | ❌ missing |

---

## Examples (`src/cmd/main/main.mbt`)

| Example                            | Covered features                                | Status      |
| ---------------------------------- | ----------------------------------------------- | ----------- |
| Single-turn text                   | `Input::Plain`, basic create + parse            | ✅ verified |
| Stateful multi-turn                | `previous_interaction_id`, `store`              | ✅ verified |
| System instruction                 | `system_instruction`                            | ✅ verified |
| Google Search tool                 | `Tool::GoogleSearch`, grounded responses        | ✅ verified |
| Structured JSON output             | `response_format` / `response_mime_type`        | ✅ verified |
| Thinking (extended)                | `thinking_level`, `Thought` content parsing     | ✅ verified |
| Streaming                          | `interactions_create_stream`, `parse_event`     | ✅ verified |
| `Input::Parts` (multimodal)        | `Image`, `Audio` content blocks                 | ❌ missing  |
| `Input::Turns` (stateless history) | client-managed conversation                     | ❌ missing  |
| Function calling                   | `Tool::Function`, `RequiresAction` flow         | ❌ missing  |
| Background interaction             | `background: true` + `interactions_cancel`      | ❌ missing  |
| `interactions_get`                 | retrieve by id                                  | ❌ missing  |
| `interactions_delete`              | delete by id                                    | ❌ missing  |

---

## Known gaps (priority order for contributors)

1. **`JSPromise` rejection binding** — add `promise_catch` FFI so MoonBit code can handle rejected promises in a typed way.
2. **Function-call round-trip example** — `RequiresAction` → submit tool results → `Completed`.
3. **Tests** — encode/decode round-trips for all content types; snapshot tests for `encode_create_params`.
4. **`interactions.list`** — once the SDK stabilises a list endpoint.
5. **Runtime verification** of untested features — `ComputerUse`, `MCPServer`, `FileSearch` tools; `Document`/`Video` content; `ImageConfig`; multi-speaker `SpeechConfig.speaker`; `background` interactions.

---

## SDK version tracking

When upgrading `@google/genai`, check the following in `node_modules/@google/genai/dist/index.d.ts` (or the yarn cache zip):

- `BaseCreateModelInteractionParams` — new fields → add to `CreateParams` + encoder
- `GenerationConfig_2` — new fields → add to `GenerationConfig` + encoder
- `Interaction` response type — new fields → add to struct + decoder
- `Content_2` union — new variants → add to `Content` enum + encode/decode

Reference: `/tmp/genai.d.ts` was extracted from `@google/genai@1.42.0`.

---

## Requirements

- **MoonBit build target**: `js` (Node.js)
- **npm package**: [`@google/genai`](https://github.com/googleapis/js-genai) ≥ 1.42.0

```sh
yarn add @google/genai        # Yarn PnP (used in this repo)
# or
npm install @google/genai
```

---

## Quick start

```moonbit nocheck
let ai = GoogleGenAI::new(get_env("GEMINI_API_KEY"))
// or, via a reverse proxy:
// let ai = GoogleGenAI::new_with_base_url(key, "https://your-proxy.example.com")

run_async(promise_and_then(
  ai.interactions_create({
    model: "gemini-2.5-flash",
    input: Input::Plain("Why is the sky blue?"),
    previous_interaction_id: None,
    generation_config: None,
    tools: None,
    response_modalities: None,
    response_format: None,
    response_mime_type: None,
    system_instruction: None,
    store: None,
    background: None,
    stream: None,
  }),
  fn(json) {
    let ia = parse_interaction(json) catch { e => { println(e); return promise_unit() } }
    println(ia.id)
    promise_unit()
  },
))
```

Build and run:

```sh
moon build --target js
GEMINI_API_KEY=<key> node --require ./.pnp.cjs \
  ./_build/js/debug/build/cmd/main/main.js
```
