///|
// Google Gemini Interactions API — runnable examples.
//
// Requires GEMINI_API_KEY in the environment.
// Set GEMINI_BASE_URL to route through a reverse proxy (e.g. internal network).
// Build and run:
//
//   moon build --target js
//   GEMINI_API_KEY=<key> GEMINI_BASE_URL=https://ja3.chenyong.life \
//     node --require ./.pnp.cjs \
//     ./_build/js/debug/build/cmd/main/main.js

// ── Helper ────────────────────────────────────────────────────────────────

///|
/// Extract the first text block from an interaction's outputs.
fn extract_text(interaction : @genai.Interaction) -> String {
  match interaction.outputs {
    Some(arr) => {
      for c in arr {
        match c {
          @genai.Text(t) => return t.text.unwrap_or("(empty)")
          _ => continue
        }
      }
      "(no text block found)"
    }
    None => "(no outputs)"
  }
}

// ── Example 1: Single-turn text ───────────────────────────────────────────

///|
/// Minimal single-turn text interaction — mirrors the basic "create" example
/// from ai.google.dev/api/interactions-api.
fn example_simple_text(ai : @genai.GoogleGenAI) -> @genai.JSPromise[Unit] {
  @genai.promise_and_then(
    ai.interactions_create({
      model: "gemini-2.5-flash",
      input: @genai.Input::Plain("Explain how AI works in a few words."),
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
    fn(json_str) {
      let msg = try {
        let ia = @genai.parse_interaction(json_str)
        "id=\{ia.id}  reply=\{extract_text(ia)}"
      } catch {
        e => "parse error: \{e}"
      }
      println("[simple_text] \{msg}")
      @genai.promise_unit()
    },
  )
}

// ── Example 2: Stateful multi-turn ───────────────────────────────────────

///|
/// Two-turn stateful conversation: the second request passes
/// `previous_interaction_id` so the model retains context from the first turn.
fn example_stateful_multi_turn(
  ai : @genai.GoogleGenAI,
) -> @genai.JSPromise[Unit] {
  @genai.promise_and_then(
    ai.interactions_create({
      model: "gemini-2.5-flash",
      input: @genai.Input::Plain("My name is Alice. Remember it."),
      previous_interaction_id: None,
      generation_config: None,
      tools: None,
      response_modalities: None,
      response_format: None,
      response_mime_type: None,
      system_instruction: None,
      store: Some(true),
      background: None,
      stream: None,
    }),
    fn(json1) {
      let first_id = @genai.parse_interaction(json1).id catch { _ => "" }
      println("[multi_turn] turn 1 id=\{first_id}")
      @genai.promise_and_then(
        ai.interactions_create({
          model: "gemini-2.5-flash",
          input: @genai.Input::Plain("What is my name?"),
          previous_interaction_id: Some(first_id),
          generation_config: None,
          tools: None,
          response_modalities: None,
          response_format: None,
          response_mime_type: None,
          system_instruction: None,
          store: Some(true),
          background: None,
          stream: None,
        }),
        fn(json2) {
          let msg = try {
            let ia = @genai.parse_interaction(json2)
            "id=\{ia.id}  reply=\{extract_text(ia)}"
          } catch {
            e => "parse error: \{e}"
          }
          println("[multi_turn] turn 2 \{msg}")
          @genai.promise_unit()
        },
      )
    },
  )
}

// ── Example 3: System instruction ────────────────────────────────────────

///|
/// Pass `system_instruction` to constrain the model's response style.
fn example_system_instruction(
  ai : @genai.GoogleGenAI,
) -> @genai.JSPromise[Unit] {
  @genai.promise_and_then(
    ai.interactions_create({
      model: "gemini-2.5-flash",
      input: @genai.Input::Plain("Hello! Who are you?"),
      previous_interaction_id: None,
      generation_config: None,
      tools: None,
      response_modalities: None,
      response_format: None,
      response_mime_type: None,
      system_instruction: Some(
        "You are a helpful assistant that replies only in haiku.",
      ),
      store: None,
      background: None,
      stream: None,
    }),
    fn(json_str) {
      let msg = try {
        let ia = @genai.parse_interaction(json_str)
        "id=\{ia.id}  reply=\{extract_text(ia)}"
      } catch {
        e => "parse error: \{e}"
      }
      println("[system_instruction] \{msg}")
      @genai.promise_unit()
    },
  )
}

// ── Main: run examples in sequence ───────────────────────────────────────

// ── Example 4: Google Search tool ─────────────────────────────────────────

///|
/// Use the built-in Google Search tool so the model can ground its answer
/// with real-time web information.
fn example_google_search(ai : @genai.GoogleGenAI) -> @genai.JSPromise[Unit] {
  @genai.promise_and_then(
    ai.interactions_create({
      model: "gemini-2.5-flash",
      input: @genai.Input::Plain(
        "What is the current weather in Tokyo right now?",
      ),
      previous_interaction_id: None,
      generation_config: None,
      tools: Some([@genai.Tool::GoogleSearch]),
      response_modalities: None,
      response_format: None,
      response_mime_type: None,
      system_instruction: None,
      store: None,
      background: None,
      stream: None,
    }),
    fn(json_str) {
      let msg = try {
        let ia = @genai.parse_interaction(json_str)
        let n = match ia.outputs {
          Some(arr) => arr.length()
          None => 0
        }
        "id=\{ia.id}  outputs=\{n}  text=\{extract_text(ia)}"
      } catch {
        e => "parse error: \{e}"
      }
      println("[google_search] \{msg}")
      @genai.promise_unit()
    },
  )
}

// ── Example 5: Structured JSON output ──────────────────────────────────────

///|
/// Request a JSON response that conforms to a given schema.
fn example_structured_json(ai : @genai.GoogleGenAI) -> @genai.JSPromise[Unit] {
  let schema : Json = {
    "type": "object",
    "properties": {
      "name": { "type": "string" },
      "capital": { "type": "string" },
      "population": { "type": "number" },
    },
    "required": Json::array(["name", "capital", "population"].map(Json::string)),
  }
  @genai.promise_and_then(
    ai.interactions_create({
      model: "gemini-2.5-flash",
      input: @genai.Input::Plain("Tell me about Japan."),
      previous_interaction_id: None,
      generation_config: None,
      tools: None,
      response_modalities: None,
      response_format: Some(schema),
      response_mime_type: Some("application/json"),
      system_instruction: None,
      store: None,
      background: None,
      stream: None,
    }),
    fn(json_str) {
      let msg = try {
        let ia = @genai.parse_interaction(json_str)
        "id=\{ia.id}  json=\{extract_text(ia)}"
      } catch {
        e => "parse error: \{e}"
      }
      println("[structured_json] \{msg}")
      @genai.promise_unit()
    },
  )
}

// ── Example 6: Thinking (extended thinking) ─────────────────────────────────

///|
/// Enable extended thinking with `thinking_level: "low"` to get more
/// reasoned answers.
fn example_thinking(ai : @genai.GoogleGenAI) -> @genai.JSPromise[Unit] {
  @genai.promise_and_then(
    ai.interactions_create({
      model: "gemini-2.5-flash",
      input: @genai.Input::Plain("What is 123 * 456 + 789?"),
      previous_interaction_id: None,
      generation_config: Some({
        max_output_tokens: None,
        temperature: None,
        top_p: None,
        seed: None,
        stop_sequences: None,
        thinking_level: Some("low"),
        thinking_summaries: Some("auto"),
        speech_config: None,
        image_config: None,
        tool_choice: None,
      }),
      tools: None,
      response_modalities: None,
      response_format: None,
      response_mime_type: None,
      system_instruction: None,
      store: None,
      background: None,
      stream: None,
    }),
    fn(json_str) {
      let msg = try {
        let ia = @genai.parse_interaction(json_str)
        let n = match ia.outputs {
          Some(arr) => arr.length()
          None => 0
        }
        // Check for thought content in outputs
        let has_thought = match ia.outputs {
          Some(arr) =>
            arr
            .iter()
            .any(fn(c) {
              match c {
                @genai.Thought(_) => true
                _ => false
              }
            })
          None => false
        }
        "id=\{ia.id}  outputs=\{n}  has_thought=\{has_thought}  text=\{extract_text(ia)}"
      } catch {
        e => "parse error: \{e}"
      }
      println("[thinking] \{msg}")
      @genai.promise_unit()
    },
  )
}

// ── Example 7: Streaming ────────────────────────────────────────────────────

///|
/// Stream a response and print each SSE event type as it arrives.
fn example_streaming(ai : @genai.GoogleGenAI) -> @genai.JSPromise[Unit] {
  let event_count : Ref[Int] = { val: 0 }
  let text_buf : Ref[String] = { val: "" }
  ai.interactions_create_stream(
    {
      model: "gemini-2.5-flash",
      input: @genai.Input::Plain("Count from 1 to 5, one per line."),
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
    },
    fn(event_json) {
      event_count.val = event_count.val + 1
      let evt = @genai.parse_event(event_json) catch {
        e => {
          println("[streaming]   event parse error: \{e}")
          return
        }
      }
      match evt {
        @genai.InteractionStart(_) =>
          println("[streaming]   event: interaction.start")
        @genai.StatusUpdate(s) =>
          println("[streaming]   event: status_update → \{s}")
        @genai.ContentStart(idx, ct) =>
          println("[streaming]   event: content.start idx=\{idx} type=\{ct}")
        @genai.ContentDelta(idx, delta) => {
          // Try extracting text from delta
          match delta {
            Object(m) =>
              match m.get("text") {
                Some(String(t)) => text_buf.val = text_buf.val + t
                _ => ()
              }
            _ => ()
          }
          ignore(idx)
        }
        @genai.ContentStop(idx) =>
          println("[streaming]   event: content.stop idx=\{idx}")
        @genai.InteractionComplete(_) =>
          println("[streaming]   event: interaction.complete")
        @genai.Error(e) => println("[streaming]   event: error \{e}")
        @genai.Unknown(t, _) => println("[streaming]   event: unknown(\{t})")
      }
    },
  )
  |> @genai.promise_seq(fn() {
    println(
      "[streaming] done: \{event_count.val} events, text=\"\{text_buf.val}\"",
    )
    @genai.promise_unit()
  })
}

// ── Main: run all examples in sequence ───────────────────────────────────

///|
fn main {
  let api_key = @genai.get_env("GEMINI_API_KEY")
  let base_url = @genai.get_env("GEMINI_BASE_URL")
  let ai = if base_url == "" {
    @genai.GoogleGenAI::new(api_key)
  } else {
    @genai.GoogleGenAI::new_with_base_url(api_key, base_url)
  }
  @genai.run_async(
    @genai.promise_seq(example_simple_text(ai), fn() {
      @genai.promise_seq(example_stateful_multi_turn(ai), fn() {
        @genai.promise_seq(example_system_instruction(ai), fn() {
          @genai.promise_seq(example_google_search(ai), fn() {
            @genai.promise_seq(example_structured_json(ai), fn() {
              @genai.promise_seq(example_thinking(ai), fn() {
                example_streaming(ai)
              })
            })
          })
        })
      })
    }),
  )
}
