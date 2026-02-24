///|
// Google Gemini Interactions API — MoonBit JS-backend bindings.
//
// Only the Interactions API (ai.google.dev/api/interactions-api) is covered;
// the classic generateContent / Chat / Live APIs are intentionally out of scope.
//
// Requires the Node.js (JS) build target:
//   moon build --target js
//
// Depends on the `@google/genai` npm package (install with yarn / npm / pnpm).
// ---------------------------------------------------------------------------

// ── Opaque JS runtime handles ───────────────────────────────────────────────

///|
/// Opaque handle to the native `GoogleGenAI` JS object.
#external
pub(all) type JSGoogleGenAI

///|
/// Opaque handle to a JavaScript `Promise<A>`.
///
/// The type parameter `A` is phantom — it tracks what type the promise
/// resolves to in MoonBit's type system, but carries no runtime information.
#external
pub(all) type JSPromise[A]

// ── Error type ──────────────────────────────────────────────────────────────

///|
/// Error raised when parsing or decoding fails.
pub(all) suberror GenaiError {
  ParseFailed(String)
  MissingField(String)
  InvalidFormat(String)
} derive(Show)

// ── InteractionStatus ───────────────────────────────────────────────────────

///|
/// Possible states of an [`Interaction`] returned by the API.
pub(all) enum InteractionStatus {
  /// The interaction is still being generated.
  InProgress
  /// The interaction is waiting for a client-provided tool result.
  RequiresAction
  /// The interaction finished successfully.
  Completed
  Failed
  Cancelled
  Incomplete
} derive(Show, Eq)

// ── Content block types ─────────────────────────────────────────────────────

///|
/// An annotation (citation) attached to a [`TextContent`] block.
pub(all) struct Annotation {
  source : String?
  start_index : Int?
  end_index : Int?
} derive(Show)

///|
/// A text content block (`type: "text"`).
pub(all) struct TextContent {
  text : String?
  annotations : Array[Annotation]?
} derive(Show)

///|
/// An image content block (`type: "image"`).
///
/// Provide either `data` (base-64) together with `mime_type`, or a `uri`.
pub(all) struct ImageContent {
  data : String?
  mime_type : String?
  /// `"low"` | `"medium"` | `"high"` | `"ultra_high"`
  resolution : String?
  uri : String?
} derive(Show)

///|
/// An audio content block (`type: "audio"`).
///
/// Provide either `data` (base-64) together with `mime_type`, or a `uri`.
pub(all) struct AudioContent {
  data : String?
  mime_type : String?
  uri : String?
} derive(Show)

///|
/// A document content block (`type: "document"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct DocumentContent {
  data : String?
  mime_type : String?
  uri : String?
} derive(Show)

///|
/// A video content block (`type: "video"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct VideoContent {
  data : String?
  mime_type : String?
  resolution : String?
  uri : String?
} derive(Show)

///|
/// A thought content block (`type: "thought"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct ThoughtContent {
  signature : String?
  /// Summary content as raw JSON (array of text/image content blocks).
  summary : Json?
} derive(Show)

///|
/// A function-call content block (`type: "function_call"`).
pub(all) struct FunctionCallContent {
  id : String
  name : String
  arguments : Json
} derive(Show)

///|
/// A function-result content block (`type: "function_result"`).
pub(all) struct FunctionResultContent {
  call_id : String
  result : Json
  name : String?
  is_error : Bool?
} derive(Show)

///|
/// A code-execution call content block (`type: "code_execution_call"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct CodeExecutionCallContent {
  id : String
  /// Arguments as JSON (`{ "code": "...", "language": "..." }`).
  arguments : Json
} derive(Show)

///|
/// A code-execution result content block (`type: "code_execution_result"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct CodeExecutionResultContent {
  id : String
  output : String
} derive(Show)

///|
/// A Google Search call content block (`type: "google_search_call"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct GoogleSearchCallContent {
  id : String
  /// Arguments as JSON (`{ "query": "..." }`).
  arguments : Json
} derive(Show)

///|
/// A Google Search result content block (`type: "google_search_result"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct GoogleSearchResultContent {
  id : String
  /// Array of search results as JSON.
  result : Json
} derive(Show)

///|
/// A URL-context call content block (`type: "url_context_call"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct URLContextCallContent {
  id : String
  arguments : Json
} derive(Show)

///|
/// A URL-context result content block (`type: "url_context_result"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct URLContextResultContent {
  id : String
  result : Json
} derive(Show)

///|
/// An MCP server tool call content block (`type: "mcp_server_tool_call"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct MCPServerToolCallContent {
  id : String
  name : String
  arguments : Json
} derive(Show)

///|
/// An MCP server tool result content block (`type: "mcp_server_tool_result"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct MCPServerToolResultContent {
  id : String
  result : Json
} derive(Show)

///|
/// A file-search call content block (`type: "file_search_call"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct FileSearchCallContent {
  id : String
  arguments : Json
} derive(Show)

///|
/// A file-search result content block (`type: "file_search_result"`).
/// **Untested** — not yet verified at runtime.
pub(all) struct FileSearchResultContent {
  id : String
  result : Json
} derive(Show)

///|
/// Discriminated union of all content-block variants produced by / sent to
/// the model via the Interactions API.
pub(all) enum Content {
  Text(TextContent)
  Image(ImageContent)
  Audio(AudioContent)
  /// **Untested** — not yet verified at runtime.
  Document(DocumentContent)
  /// **Untested** — not yet verified at runtime.
  Video(VideoContent)
  /// **Untested** — not yet verified at runtime.
  Thought(ThoughtContent)
  FunctionCall(FunctionCallContent)
  FunctionResult(FunctionResultContent)
  /// **Untested** — not yet verified at runtime.
  CodeExecutionCall(CodeExecutionCallContent)
  /// **Untested** — not yet verified at runtime.
  CodeExecutionResult(CodeExecutionResultContent)
  /// **Untested** — not yet verified at runtime.
  GoogleSearchCall(GoogleSearchCallContent)
  /// **Untested** — not yet verified at runtime.
  GoogleSearchResult(GoogleSearchResultContent)
  /// **Untested** — not yet verified at runtime.
  URLContextCall(URLContextCallContent)
  /// **Untested** — not yet verified at runtime.
  URLContextResult(URLContextResultContent)
  /// **Untested** — not yet verified at runtime.
  MCPServerToolCall(MCPServerToolCallContent)
  /// **Untested** — not yet verified at runtime.
  MCPServerToolResult(MCPServerToolResultContent)
  /// **Untested** — not yet verified at runtime.
  FileSearchCall(FileSearchCallContent)
  /// **Untested** — not yet verified at runtime.
  FileSearchResult(FileSearchResultContent)
} derive(Show)

// ── Turn ────────────────────────────────────────────────────────────────────

///|
/// Content within a [`Turn`] — either a plain string or structured blocks.
pub(all) enum TurnContent {
  Plain(String)
  Parts(Array[Content])
} derive(Show)

///|
/// A single conversation turn (user **or** model).
pub(all) struct Turn {
  content : TurnContent?
  /// `"user"` or `"model"`
  role : String?
} derive(Show)

// ── Input ───────────────────────────────────────────────────────────────────

///|
/// Input accepted by [`GoogleGenAI::interactions_create`].
///
/// - `Plain(text)` — a single text string.
/// - `Parts(contents)` — one or more typed content blocks.
/// - `Turns(turns)` — a full conversation history (for stateless multi-turn).
pub(all) enum Input {
  Plain(String)
  Parts(Array[Content])
  Turns(Array[Turn])
} derive(Show)

// ── Usage ───────────────────────────────────────────────────────────────────

///|
/// Token-usage counters attached to a completed [`Interaction`].
pub(all) struct Usage {
  total_input_tokens : Int?
  total_output_tokens : Int?
  total_cached_tokens : Int?
} derive(Show)

// ── Tool declarations ────────────────────────────────────────────────────────

///|
/// A `function`-type tool declaration.
pub(all) struct FunctionTool {
  name : String
  description : String?
  /// JSON Schema object describing the function's parameters.
  parameters : Json?
} derive(Show)

///|
/// Configuration for the Computer-Use tool.
/// **Untested** — not yet verified at runtime.
pub(all) struct ComputerUseTool {
  /// The environment being operated (`"browser"`).
  environment : String?
  excluded_predefined_functions : Array[String]?
} derive(Show)

///|
/// Configuration for a remote MCP server tool.
/// **Untested** — not yet verified at runtime.
pub(all) struct MCPServerTool {
  /// The full URL for the MCP server endpoint.
  url : String?
  name : String?
  /// Authentication / custom headers as JSON object.
  headers : Json?
  /// Allowed tools configuration as JSON.
  allowed_tools : Json?
} derive(Show)

///|
/// Configuration for the File Search tool.
/// **Untested** — not yet verified at runtime.
pub(all) struct FileSearchTool {
  file_search_store_names : Array[String]?
  top_k : Int?
  metadata_filter : String?
} derive(Show)

///|
/// Built-in tool types that the model can use.
pub(all) enum Tool {
  /// A developer-defined function the model can invoke.
  Function(FunctionTool)
  /// Allow the model to search Google.
  GoogleSearch
  /// Allow the model to execute code.
  CodeExecution
  /// Allow the model to fetch and read URLs.
  URLContext
  /// Allow the model to interact with the computer.
  /// **Untested** — not yet verified at runtime.
  ComputerUse(ComputerUseTool)
  /// A remote MCP server that the model can call.
  /// **Untested** — not yet verified at runtime.
  MCPServer(MCPServerTool)
  /// Allow the model to search files.
  /// **Untested** — not yet verified at runtime.
  FileSearch(FileSearchTool)
} derive(Show)

// ── GenerationConfig ─────────────────────────────────────────────────────────

///|
/// A voice+language pair for speech output.
pub(all) struct SpeechConfig {
  voice : String?
  language : String?
  /// Speaker name for multi-speaker TTS.
  /// **Untested** — not yet verified at runtime.
  speaker : String?
} derive(Show)

///|
/// Configuration for image generation.
/// **Untested** — not yet verified at runtime.
pub(all) struct ImageConfig {
  /// `"1:1"` | `"2:3"` | `"3:2"` | `"3:4"` | `"4:3"` | `"4:5"` | `"5:4"` | `"9:16"` | `"16:9"` | `"21:9"`
  aspect_ratio : String?
  /// `"1K"` | `"2K"` | `"4K"`
  image_size : String?
} derive(Show)

///|
/// Optional generation configuration for an interaction.
pub(all) struct GenerationConfig {
  max_output_tokens : Int?
  temperature : Double?
  top_p : Double?
  seed : Int?
  stop_sequences : Array[String]?
  /// `"minimal"` | `"low"` | `"medium"` | `"high"`
  thinking_level : String?
  /// `"auto"` | `"none"`
  thinking_summaries : String?
  speech_config : Array[SpeechConfig]?
  /// Configuration for image generation.
  /// **Untested** — not yet verified at runtime.
  image_config : ImageConfig?
  /// Tool choice configuration as JSON.
  /// **Untested** — not yet verified at runtime.
  tool_choice : Json?
} derive(Show)

// ── CreateParams ─────────────────────────────────────────────────────────────

///|
/// Parameters for `interactions.create`.
pub(all) struct CreateParams {
  /// The Gemini model to use, e.g. `"gemini-2.5-flash"`.
  model : String
  /// Input sent to the model.
  input : Input
  /// ID of the previous interaction for stateful conversation threads.
  previous_interaction_id : String?
  generation_config : GenerationConfig?
  tools : Array[Tool]?
  /// Requested response modalities: `"text"`, `"image"`, `"audio"`.
  response_modalities : Array[String]?
  /// Enforce a JSON response format (pass a JSON Schema as `Json`).
  response_format : Json?
  response_mime_type : String?
  system_instruction : String?
  /// Whether to persist this interaction server-side. Default: `true`.
  store : Bool?
  /// Run the interaction in the background (for agents / deep-research).
  /// **Untested** — not yet verified at runtime.
  background : Bool?
  /// Whether to stream the response. Use `interactions_create_stream` instead.
  /// **Untested** — not yet verified at runtime.
  stream : Bool?
} derive(Show)

// ── Interaction (response) ───────────────────────────────────────────────────

///|
/// The Interaction resource returned by the API.
pub(all) struct Interaction {
  /// Unique identifier for this interaction.
  id : String
  status : InteractionStatus
  model : String?
  /// The model's response content blocks.
  outputs : Array[Content]?
  previous_interaction_id : String?
  role : String?
  usage : Usage?
  /// ISO 8601 creation timestamp.
  created : String?
  /// ISO 8601 last-update timestamp.
  updated : String?
  /// The name of the agent, if an agent was used.
  /// **Untested** — not yet verified at runtime.
  agent : String?
} derive(Show)

// ── GoogleGenAI client ───────────────────────────────────────────────────────

///|
/// A `GoogleGenAI` client wrapping the `@google/genai` JS SDK.
///
/// Only the Interactions API surface is exposed here. Example:
///
/// ```moonbit nocheck
/// let ai = GoogleGenAI::new("YOUR_GEMINI_API_KEY")
///
/// let p = ai.interactions_create({
///   model: "gemini-2.5-flash",
///   input: Input::Plain("Hello!"),
///   previous_interaction_id: None,
///   generation_config: None,
///   tools: None,
///   response_modalities: None,
///   response_format: None,
///   response_mime_type: None,
///   system_instruction: None,
///   store: None,
/// })
/// // `p` is `JSPromise[String]` — resolves to a JSON-encoded Interaction
/// ```
pub(all) struct GoogleGenAI {
  priv js : JSGoogleGenAI
}

// ── Low-level JS FFI ─────────────────────────────────────────────────────────

///|
extern "js" fn ffi_new_client(api_key : String) -> JSGoogleGenAI =
  #| (apiKey) => { const {GoogleGenAI} = require('@google/genai'); return new GoogleGenAI({apiKey}); }

///|
extern "js" fn ffi_new_client_with_base_url(
  api_key : String,
  base_url : String,
) -> JSGoogleGenAI =
  #| (apiKey, baseUrl) => {
  #|   const { GoogleGenAI } = require('@google/genai')
  #|   return new GoogleGenAI({ apiKey, httpOptions: { baseUrl } })
  #| }

///|
/// Calls `client.interactions.create(params)` and serialises the resolved
/// `Interaction` to a JSON string.
extern "js" fn ffi_interactions_create(
  client : JSGoogleGenAI,
  params_json : String,
) -> JSPromise[String] =
  #| (client, p) => {
  #|   const strip = v => {
  #|     if (Array.isArray(v)) return v.map(strip)
  #|     if (v !== null && typeof v === 'object')
  #|       return Object.fromEntries(
  #|         Object.entries(v)
  #|           .filter(([, x]) => x !== null)
  #|           .map(([k, x]) => [k, strip(x)])
  #|       )
  #|     return v
  #|   }
  #|   return client.interactions.create(strip(JSON.parse(p)))
  #|     .then(r => JSON.stringify(r))
  #| }

///|
/// Calls `client.interactions.get(id)` and serialises the result.
extern "js" fn ffi_interactions_get(
  client : JSGoogleGenAI,
  id : String,
) -> JSPromise[String] =
  #| (client, id) => client.interactions.get(id).then(r => JSON.stringify(r))

///|
/// Calls `client.interactions.cancel(id)` and serialises the result.
extern "js" fn ffi_interactions_cancel(
  client : JSGoogleGenAI,
  id : String,
) -> JSPromise[String] =
  #| (client, id) => client.interactions.cancel(id).then(r => JSON.stringify(r))

///|
/// Calls `client.interactions.delete(id)`.
extern "js" fn ffi_interactions_delete(
  client : JSGoogleGenAI,
  id : String,
) -> JSPromise[Unit] =
  #| (client, id) => client.interactions.delete(id)

// ── JSON serialisation helpers (CreateParams → String) ───────────────────────

// ─── encode helpers ───────────────────────────────────────────────────────

///|
fn opt_str(s : String?) -> Json {
  match s {
    Some(v) => Json::string(v)
    None => null
  }
}

///|
fn opt_int(n : Int?) -> Json {
  match n {
    Some(v) => Json::number(v.to_double())
    None => null
  }
}

///|
fn opt_double(d : Double?) -> Json {
  match d {
    Some(v) => Json::number(v)
    None => null
  }
}

///|
fn opt_bool(b : Bool?) -> Json {
  match b {
    Some(v) => Json::boolean(v)
    None => null
  }
}

///|
fn encode_annotation(a : Annotation) -> Json {
  {
    "source": opt_str(a.source),
    "start_index": opt_int(a.start_index),
    "end_index": opt_int(a.end_index),
  }
}

///|
fn encode_content(c : Content) -> Json {
  match c {
    Text(t) =>
      {
        "type": Json::string("text"),
        "text": opt_str(t.text),
        "annotations": match t.annotations {
          None => null
          Some(arr) => Json::array(arr.map(encode_annotation))
        },
      }
    Image(img) =>
      {
        "type": Json::string("image"),
        "data": opt_str(img.data),
        "mime_type": opt_str(img.mime_type),
        "resolution": opt_str(img.resolution),
        "uri": opt_str(img.uri),
      }
    Audio(aud) =>
      {
        "type": Json::string("audio"),
        "data": opt_str(aud.data),
        "mime_type": opt_str(aud.mime_type),
        "uri": opt_str(aud.uri),
      }
    FunctionCall(fc) =>
      {
        "type": Json::string("function_call"),
        "id": Json::string(fc.id),
        "name": Json::string(fc.name),
        "arguments": fc.arguments,
      }
    FunctionResult(fr) =>
      {
        "type": Json::string("function_result"),
        "call_id": Json::string(fr.call_id),
        "result": fr.result,
        "name": opt_str(fr.name),
        "is_error": opt_bool(fr.is_error),
      }
    Document(doc) =>
      {
        "type": Json::string("document"),
        "data": opt_str(doc.data),
        "mime_type": opt_str(doc.mime_type),
        "uri": opt_str(doc.uri),
      }
    Video(vid) =>
      {
        "type": Json::string("video"),
        "data": opt_str(vid.data),
        "mime_type": opt_str(vid.mime_type),
        "resolution": opt_str(vid.resolution),
        "uri": opt_str(vid.uri),
      }
    Thought(t) =>
      {
        "type": Json::string("thought"),
        "signature": opt_str(t.signature),
        "summary": t.summary.unwrap_or(null),
      }
    CodeExecutionCall(c) =>
      {
        "type": Json::string("code_execution_call"),
        "id": Json::string(c.id),
        "arguments": c.arguments,
      }
    CodeExecutionResult(c) =>
      {
        "type": Json::string("code_execution_result"),
        "id": Json::string(c.id),
        "output": Json::string(c.output),
      }
    GoogleSearchCall(c) =>
      {
        "type": Json::string("google_search_call"),
        "id": Json::string(c.id),
        "arguments": c.arguments,
      }
    GoogleSearchResult(c) =>
      {
        "type": Json::string("google_search_result"),
        "id": Json::string(c.id),
        "result": c.result,
      }
    URLContextCall(c) =>
      {
        "type": Json::string("url_context_call"),
        "id": Json::string(c.id),
        "arguments": c.arguments,
      }
    URLContextResult(c) =>
      {
        "type": Json::string("url_context_result"),
        "id": Json::string(c.id),
        "result": c.result,
      }
    MCPServerToolCall(c) =>
      {
        "type": Json::string("mcp_server_tool_call"),
        "id": Json::string(c.id),
        "name": Json::string(c.name),
        "arguments": c.arguments,
      }
    MCPServerToolResult(c) =>
      {
        "type": Json::string("mcp_server_tool_result"),
        "id": Json::string(c.id),
        "result": c.result,
      }
    FileSearchCall(c) =>
      {
        "type": Json::string("file_search_call"),
        "id": Json::string(c.id),
        "arguments": c.arguments,
      }
    FileSearchResult(c) =>
      {
        "type": Json::string("file_search_result"),
        "id": Json::string(c.id),
        "result": c.result,
      }
  }
}

///|
fn encode_turn_content(tc : TurnContent) -> Json {
  match tc {
    Plain(s) => Json::string(s)
    Parts(arr) => Json::array(arr.map(encode_content))
  }
}

///|
fn encode_turn(t : Turn) -> Json {
  {
    "content": match t.content {
      Some(tc) => encode_turn_content(tc)
      None => null
    },
    "role": opt_str(t.role),
  }
}

///|
fn encode_input(input : Input) -> Json {
  match input {
    Plain(s) => Json::string(s)
    Parts(arr) => Json::array(arr.map(encode_content))
    Turns(arr) => Json::array(arr.map(encode_turn))
  }
}

///|
fn encode_function_tool(f : FunctionTool) -> Json {
  {
    "type": Json::string("function"),
    "name": Json::string(f.name),
    "description": opt_str(f.description),
    "parameters": f.parameters.unwrap_or(null),
  }
}

///|
fn encode_tool(t : Tool) -> Json {
  match t {
    Function(f) => encode_function_tool(f)
    GoogleSearch => { "type": Json::string("google_search") }
    CodeExecution => { "type": Json::string("code_execution") }
    URLContext => { "type": Json::string("url_context") }
    ComputerUse(cu) =>
      {
        "type": Json::string("computer_use"),
        "environment": opt_str(cu.environment),
        "excludedPredefinedFunctions": match cu.excluded_predefined_functions {
          None => null
          Some(arr) => Json::array(arr.map(Json::string))
        },
      }
    MCPServer(mcp) =>
      {
        "type": Json::string("mcp_server"),
        "url": opt_str(mcp.url),
        "name": opt_str(mcp.name),
        "headers": mcp.headers.unwrap_or(null),
        "allowed_tools": mcp.allowed_tools.unwrap_or(null),
      }
    FileSearch(fs) =>
      {
        "type": Json::string("file_search"),
        "file_search_store_names": match fs.file_search_store_names {
          None => null
          Some(arr) => Json::array(arr.map(Json::string))
        },
        "top_k": opt_int(fs.top_k),
        "metadata_filter": opt_str(fs.metadata_filter),
      }
  }
}

///|
fn encode_speech_config(sc : SpeechConfig) -> Json {
  {
    "voice": opt_str(sc.voice),
    "language": opt_str(sc.language),
    "speaker": opt_str(sc.speaker),
  }
}

///|
fn encode_generation_config(gc : GenerationConfig) -> Json {
  {
    "max_output_tokens": opt_int(gc.max_output_tokens),
    "temperature": opt_double(gc.temperature),
    "top_p": opt_double(gc.top_p),
    "seed": opt_int(gc.seed),
    "stop_sequences": match gc.stop_sequences {
      None => null
      Some(arr) => Json::array(arr.map(Json::string))
    },
    "thinking_level": opt_str(gc.thinking_level),
    "thinking_summaries": opt_str(gc.thinking_summaries),
    "speech_config": match gc.speech_config {
      None => null
      Some(arr) => Json::array(arr.map(encode_speech_config))
    },
    "image_config": match gc.image_config {
      None => null
      Some(ic) =>
        {
          "aspect_ratio": opt_str(ic.aspect_ratio),
          "image_size": opt_str(ic.image_size),
        }
    },
    "tool_choice": gc.tool_choice.unwrap_or(null),
  }
}

///|
fn encode_create_params(p : CreateParams) -> String {
  let obj : Json = {
    "model": Json::string(p.model),
    "input": encode_input(p.input),
    "previous_interaction_id": opt_str(p.previous_interaction_id),
    "generation_config": match p.generation_config {
      Some(gc) => encode_generation_config(gc)
      None => null
    },
    "tools": match p.tools {
      None => null
      Some(ts) => Json::array(ts.map(encode_tool))
    },
    "response_modalities": match p.response_modalities {
      None => null
      Some(ms) => Json::array(ms.map(Json::string))
    },
    "response_format": p.response_format.unwrap_or(null),
    "response_mime_type": opt_str(p.response_mime_type),
    "system_instruction": opt_str(p.system_instruction),
    "store": opt_bool(p.store),
    "background": opt_bool(p.background),
    "stream": opt_bool(p.stream),
  }
  Json::stringify(obj)
}

// ── JSON deserialisation helpers (String → Interaction) ──────────────────────

///|
fn decode_status(s : String) -> InteractionStatus {
  match s {
    "in_progress" => InProgress
    "requires_action" => RequiresAction
    "completed" => Completed
    "failed" => Failed
    "cancelled" => Cancelled
    _ => Incomplete
  }
}

///|
fn decode_annotation(j : Json) -> Annotation {
  match j {
    Object(m) =>
      {
        source: match m.get("source") {
          Some(String(s)) => Some(s)
          _ => None
        },
        start_index: match m.get("start_index") {
          Some(Number(n, ..)) => Some(n.to_int())
          _ => None
        },
        end_index: match m.get("end_index") {
          Some(Number(n, ..)) => Some(n.to_int())
          _ => None
        },
      }
    _ => { source: None, start_index: None, end_index: None }
  }
}

///|
fn decode_content(j : Json) -> Content? {
  match j {
    Object(m) =>
      match m.get("type") {
        Some(String("text")) => {
          let text : String? = match m.get("text") {
            Some(String(s)) => Some(s)
            _ => None
          }
          let annotations : Array[Annotation]? = match m.get("annotations") {
            Some(Array(arr)) => Some(arr.map(decode_annotation))
            _ => None
          }
          Some(Text({ text, annotations }))
        }
        Some(String("image")) =>
          Some(
            Image({
              data: match m.get("data") {
                Some(String(s)) => Some(s)
                _ => None
              },
              mime_type: match m.get("mime_type") {
                Some(String(s)) => Some(s)
                _ => None
              },
              resolution: match m.get("resolution") {
                Some(String(s)) => Some(s)
                _ => None
              },
              uri: match m.get("uri") {
                Some(String(s)) => Some(s)
                _ => None
              },
            }),
          )
        Some(String("audio")) =>
          Some(
            Audio({
              data: match m.get("data") {
                Some(String(s)) => Some(s)
                _ => None
              },
              mime_type: match m.get("mime_type") {
                Some(String(s)) => Some(s)
                _ => None
              },
              uri: match m.get("uri") {
                Some(String(s)) => Some(s)
                _ => None
              },
            }),
          )
        Some(String("function_call")) =>
          match (m.get("id"), m.get("name"), m.get("arguments")) {
            (Some(String(id)), Some(String(name)), Some(args)) =>
              Some(FunctionCall({ id, name, arguments: args }))
            _ => None
          }
        Some(String("function_result")) =>
          match (m.get("call_id"), m.get("result")) {
            (Some(String(call_id)), Some(result)) => {
              let name : String? = match m.get("name") {
                Some(String(s)) => Some(s)
                _ => None
              }
              let is_error : Bool? = match m.get("is_error") {
                Some(True) => Some(true)
                Some(False) => Some(false)
                _ => None
              }
              Some(FunctionResult({ call_id, result, name, is_error }))
            }
            _ => None
          }
        Some(String("document")) =>
          Some(
            Document({
              data: match m.get("data") {
                Some(String(s)) => Some(s)
                _ => None
              },
              mime_type: match m.get("mime_type") {
                Some(String(s)) => Some(s)
                _ => None
              },
              uri: match m.get("uri") {
                Some(String(s)) => Some(s)
                _ => None
              },
            }),
          )
        Some(String("video")) =>
          Some(
            Video({
              data: match m.get("data") {
                Some(String(s)) => Some(s)
                _ => None
              },
              mime_type: match m.get("mime_type") {
                Some(String(s)) => Some(s)
                _ => None
              },
              resolution: match m.get("resolution") {
                Some(String(s)) => Some(s)
                _ => None
              },
              uri: match m.get("uri") {
                Some(String(s)) => Some(s)
                _ => None
              },
            }),
          )
        Some(String("thought")) =>
          Some(
            Thought({
              signature: match m.get("signature") {
                Some(String(s)) => Some(s)
                _ => None
              },
              summary: match m.get("summary") {
                Some(v) => Some(v)
                _ => None
              },
            }),
          )
        Some(String("code_execution_call")) =>
          match m.get("id") {
            Some(String(id)) =>
              Some(
                CodeExecutionCall({
                  id,
                  arguments: m.get("arguments").unwrap_or(null),
                }),
              )
            _ => None
          }
        Some(String("code_execution_result")) =>
          match (m.get("id"), m.get("output")) {
            (Some(String(id)), Some(String(output))) =>
              Some(CodeExecutionResult({ id, output }))
            _ => None
          }
        Some(String("google_search_call")) =>
          match m.get("id") {
            Some(String(id)) =>
              Some(
                GoogleSearchCall({
                  id,
                  arguments: m.get("arguments").unwrap_or(null),
                }),
              )
            _ => None
          }
        Some(String("google_search_result")) =>
          match m.get("id") {
            Some(String(id)) =>
              Some(
                GoogleSearchResult({
                  id,
                  result: m.get("result").unwrap_or(null),
                }),
              )
            _ => None
          }
        Some(String("url_context_call")) =>
          match m.get("id") {
            Some(String(id)) =>
              Some(
                URLContextCall({
                  id,
                  arguments: m.get("arguments").unwrap_or(null),
                }),
              )
            _ => None
          }
        Some(String("url_context_result")) =>
          match m.get("id") {
            Some(String(id)) =>
              Some(
                URLContextResult({ id, result: m.get("result").unwrap_or(null) }),
              )
            _ => None
          }
        Some(String("mcp_server_tool_call")) =>
          match (m.get("id"), m.get("name")) {
            (Some(String(id)), Some(String(name))) =>
              Some(
                MCPServerToolCall({
                  id,
                  name,
                  arguments: m.get("arguments").unwrap_or(null),
                }),
              )
            _ => None
          }
        Some(String("mcp_server_tool_result")) =>
          match m.get("id") {
            Some(String(id)) =>
              Some(
                MCPServerToolResult({
                  id,
                  result: m.get("result").unwrap_or(null),
                }),
              )
            _ => None
          }
        Some(String("file_search_call")) =>
          match m.get("id") {
            Some(String(id)) =>
              Some(
                FileSearchCall({
                  id,
                  arguments: m.get("arguments").unwrap_or(null),
                }),
              )
            _ => None
          }
        Some(String("file_search_result")) =>
          match m.get("id") {
            Some(String(id)) =>
              Some(
                FileSearchResult({ id, result: m.get("result").unwrap_or(null) }),
              )
            _ => None
          }
        _ => None
      }
    _ => None
  }
}

///|
fn decode_usage(j : Json) -> Usage? {
  match j {
    Object(m) =>
      Some({
        total_input_tokens: match m.get("total_input_tokens") {
          Some(Number(n, ..)) => Some(n.to_int())
          _ => None
        },
        total_output_tokens: match m.get("total_output_tokens") {
          Some(Number(n, ..)) => Some(n.to_int())
          _ => None
        },
        total_cached_tokens: match m.get("total_cached_tokens") {
          Some(Number(n, ..)) => Some(n.to_int())
          _ => None
        },
      })
    _ => None
  }
}

///|
/// Parse a JSON string (as returned by the raw FFI) into an [`Interaction`].
/// Returns an error string if parsing fails.
pub fn parse_interaction(json_str : String) -> Interaction raise GenaiError {
  let j : Json = @json.parse(json_str) catch {
    e => raise ParseFailed(e.to_string())
  }
  match j {
    Object(m) => {
      let id = match m.get("id") {
        Some(String(s)) => s
        _ => raise MissingField("id")
      }
      let status = match m.get("status") {
        Some(String(s)) => decode_status(s)
        _ => raise MissingField("status")
      }
      let model : String? = match m.get("model") {
        Some(String(s)) => Some(s)
        _ => None
      }
      let outputs : Array[Content]? = match m.get("outputs") {
        Some(Array(arr)) => {
          let contents = arr.filter_map(decode_content)
          if contents.length() > 0 {
            Some(contents)
          } else {
            None
          }
        }
        _ => None
      }
      let previous_interaction_id : String? = match
        m.get("previous_interaction_id") {
        Some(String(s)) => Some(s)
        _ => None
      }
      let role : String? = match m.get("role") {
        Some(String(s)) => Some(s)
        _ => None
      }
      let usage : Usage? = match m.get("usage") {
        Some(u) => decode_usage(u)
        _ => None
      }
      let created : String? = match m.get("created") {
        Some(String(s)) => Some(s)
        _ => None
      }
      let updated : String? = match m.get("updated") {
        Some(String(s)) => Some(s)
        _ => None
      }
      let agent : String? = match m.get("agent") {
        Some(String(s)) => Some(s)
        _ => None
      }
      {
        id,
        status,
        model,
        outputs,
        previous_interaction_id,
        role,
        usage,
        created,
        updated,
        agent,
      }
    }
    _ => raise InvalidFormat("expected JSON object")
  }
}

// ── Promise utilities ─────────────────────────────────────────────────────────

///|
/// Chain a `JSPromise[String]` — calls `f` with the resolved string and
/// returns a new `JSPromise[Unit]`.  Mirrors `.then()` in JavaScript.
pub extern "js" fn promise_and_then(
  p : JSPromise[String],
  f : (String) -> JSPromise[Unit],
) -> JSPromise[Unit] =
  #| (p, f) => p.then(v => f(v))

///|
/// Sequence two `JSPromise[Unit]` values — run `f` after `p` resolves.
pub extern "js" fn promise_seq(
  p : JSPromise[Unit],
  f : () -> JSPromise[Unit],
) -> JSPromise[Unit] =
  #| (p, f) => p.then(() => f())

///|
/// A `JSPromise` that is already resolved to `Unit`.
pub extern "js" fn promise_unit() -> JSPromise[Unit] =
  #| () => Promise.resolve(undefined)

///|
/// Run a `JSPromise[Unit]` as the top-level async operation.
/// Logs errors to stderr and exits with code 1 on rejection.
pub extern "js" fn run_async(p : JSPromise[Unit]) -> Unit =
  #| (p) => p.catch(e => { console.error('Error:', String(e)); process.exit(1) })

///|
/// Read a Node.js environment variable.  Returns `""` if not set.
pub extern "js" fn get_env(key : String) -> String =
  #| (k) => process.env[k] ?? ''

// ── Public API ───────────────────────────────────────────────────────────────

///|
/// Create a new `GoogleGenAI` client.
///
/// ```moonbit nocheck
/// let ai = GoogleGenAI::new("YOUR_GEMINI_API_KEY")
/// ```
pub fn GoogleGenAI::new(api_key : String) -> GoogleGenAI {
  { js: ffi_new_client(api_key) }
}

///|
/// Create a `GoogleGenAI` client that routes all requests through a custom
/// `base_url` (e.g. an internal reverse-proxy).
///
/// ```moonbit nocheck
/// let ai = GoogleGenAI::new_with_base_url(
///   "YOUR_GEMINI_API_KEY", "https://ja3.chenyong.life",
/// )
/// ```
pub fn GoogleGenAI::new_with_base_url(
  api_key : String,
  base_url : String,
) -> GoogleGenAI {
  { js: ffi_new_client_with_base_url(api_key, base_url) }
}

///|
/// Create a new interaction and return a `JSPromise` that resolves to a
/// JSON-encoded [`Interaction`] string.
///
/// Use [`parse_interaction`] to convert the resolved string to a typed
/// [`Interaction`] value.
///
/// ## Example (stateless, single turn)
/// ```moonbit nocheck
/// let p = ai.interactions_create({
///   model: "gemini-2.5-flash",
///   input: Input::Plain("Why is the sky blue?"),
///   previous_interaction_id: None,
///   generation_config: None,
///   tools: None,
///   response_modalities: None,
///   response_format: None,
///   response_mime_type: None,
///   system_instruction: None,
///   store: None,
/// })
/// ```
///
/// ## Example (stateful multi-turn)
/// ```moonbit nocheck
/// let p2 = ai.interactions_create({
///   ...,
///   input: Input::Plain("What about sunsets?"),
///   previous_interaction_id: Some(first_interaction_id),
/// })
/// ```
pub fn GoogleGenAI::interactions_create(
  self : GoogleGenAI,
  params : CreateParams,
) -> JSPromise[String] {
  ffi_interactions_create(self.js, encode_create_params(params))
}

///|
/// Retrieve a previously created interaction by its `id`.
///
/// Returns a `JSPromise` that resolves to a JSON-encoded [`Interaction`].
pub fn GoogleGenAI::interactions_get(
  self : GoogleGenAI,
  id : String,
) -> JSPromise[String] {
  ffi_interactions_get(self.js, id)
}

///|
/// Cancel a background interaction that is still running.
///
/// Only applies to interactions started with `background: true` in
/// [`GenerationConfig`].  Returns a `JSPromise` resolving to the updated
/// [`Interaction`].
pub fn GoogleGenAI::interactions_cancel(
  self : GoogleGenAI,
  id : String,
) -> JSPromise[String] {
  ffi_interactions_cancel(self.js, id)
}

///|
/// Delete an interaction by its `id`.
pub fn GoogleGenAI::interactions_delete(
  self : GoogleGenAI,
  id : String,
) -> JSPromise[Unit] {
  ffi_interactions_delete(self.js, id)
}

// ── Streaming support ────────────────────────────────────────────────────────

///|
/// SSE event types emitted during a streamed interaction.
/// **Untested** — not yet verified at runtime.
pub(all) enum InteractionEvent {
  /// The interaction has started; carries the initial snapshot as JSON.
  InteractionStart(Json)
  /// The interaction status has changed.
  StatusUpdate(String)
  /// A new content block has started at the given index.
  ContentStart(Int, String)
  /// A delta for the content block at the given index.
  ContentDelta(Int, Json)
  /// The content block at the given index has finished.
  ContentStop(Int)
  /// The interaction is complete; carries the final snapshot as JSON.
  InteractionComplete(Json)
  /// An error event.
  Error(Json)
  /// An unrecognised event type.
  Unknown(String, Json)
} derive(Show)

///|
/// Parse a JSON-encoded SSE event string into an [`InteractionEvent`].
/// **Untested** — not yet verified at runtime.
pub fn parse_event(json_str : String) -> InteractionEvent raise GenaiError {
  let j : Json = @json.parse(json_str) catch {
    e => raise ParseFailed(e.to_string())
  }
  match j {
    Object(m) =>
      match m.get("event_type") {
        Some(String("interaction.start")) => InteractionStart(j)
        Some(String("interaction.status_update")) =>
          match m.get("status") {
            Some(String(s)) => StatusUpdate(s)
            _ => StatusUpdate("")
          }
        Some(String("content.start")) => {
          let index = match m.get("index") {
            Some(Number(n, ..)) => n.to_int()
            _ => 0
          }
          let content_type = match m.get("content") {
            Some(Object(cm)) =>
              match cm.get("type") {
                Some(String(s)) => s
                _ => ""
              }
            _ => ""
          }
          ContentStart(index, content_type)
        }
        Some(String("content.delta")) => {
          let index = match m.get("index") {
            Some(Number(n, ..)) => n.to_int()
            _ => 0
          }
          let delta = m.get("delta").unwrap_or(null)
          ContentDelta(index, delta)
        }
        Some(String("content.stop")) => {
          let index = match m.get("index") {
            Some(Number(n, ..)) => n.to_int()
            _ => 0
          }
          ContentStop(index)
        }
        Some(String("interaction.complete")) => InteractionComplete(j)
        Some(String("error")) => Error(j)
        Some(String(t)) => Unknown(t, j)
        _ => raise InvalidFormat("event missing 'event_type' field")
      }
    _ => raise InvalidFormat("expected JSON object for event")
  }
}

///|
/// Low-level FFI for streaming interaction creation.
/// Iterates the async stream and calls `on_event` for each SSE event.
extern "js" fn ffi_interactions_create_stream(
  client : JSGoogleGenAI,
  params_json : String,
  on_event : (String) -> Unit,
) -> JSPromise[Unit] =
  #| (client, p, cb) => {
  #|   const strip = v => {
  #|     if (Array.isArray(v)) return v.map(strip)
  #|     if (v !== null && typeof v === 'object')
  #|       return Object.fromEntries(
  #|         Object.entries(v).filter(([,x]) => x !== null).map(([k,x]) => [k, strip(x)])
  #|       )
  #|     return v
  #|   }
  #|   const params = strip(JSON.parse(p))
  #|   params.stream = true
  #|   return client.interactions.create(params).then(async stream => {
  #|     for await (const event of stream) { cb(JSON.stringify(event)) }
  #|   })
  #| }

///|
/// Create an interaction with streaming.  Each SSE event is delivered to
/// `on_event` as a JSON string; use [`parse_event`] to decode it.
///
/// **Untested** — not yet verified at runtime.
///
/// ## Example
/// ```moonbit nocheck
/// let p = ai.interactions_create_stream(
///   {
///     model: "gemini-2.5-flash",
///     input: Input::Plain("Hello!"),
///     ..CreateParams::default()
///   },
///   fn(event_json) {
///     // handle each SSE event
///   },
/// )
/// ```
pub fn GoogleGenAI::interactions_create_stream(
  self : GoogleGenAI,
  params : CreateParams,
  on_event : (String) -> Unit,
) -> JSPromise[Unit] {
  ffi_interactions_create_stream(
    self.js,
    encode_create_params(params),
    on_event,
  )
}
