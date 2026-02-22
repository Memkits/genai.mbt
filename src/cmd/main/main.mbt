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
    Some(arr) =>
      match arr.get(0) {
        Some(@genai.Text(t)) => t.text.unwrap_or("(empty)")
        Some(_) => "(non-text output)"
        None => "(empty outputs)"
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
        example_system_instruction(ai)
      })
    }),
  )
}
