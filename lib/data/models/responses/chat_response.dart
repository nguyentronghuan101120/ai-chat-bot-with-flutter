import 'package:json_annotation/json_annotation.dart';

part 'chat_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatResponse {
  final String? id;
  final String? object;
  final int? created;
  final String? model;
  final List<ChatChoice>? choices;

  ChatResponse({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}

@JsonSerializable()
class ChatChoice {
  final ChatDelta? delta;
  @JsonKey(name: 'finish_reason')
  final String? finishReason;
  final int? index;
  final dynamic logprobs;

  ChatChoice({
    this.delta,
    this.finishReason,
    this.index,
    this.logprobs,
  });

  factory ChatChoice.fromJson(Map<String, dynamic> json) =>
      _$ChatChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChatChoiceToJson(this);
}

@JsonSerializable()
class ChatDelta {
  final String? content;
  @JsonKey(name: 'function_call')
  final dynamic functionCall;
  final dynamic refusal;
  final String? role;
  @JsonKey(name: 'tool_calls')
  final List<ToolCall>? toolCalls;

  ChatDelta({
    this.content,
    this.functionCall,
    this.refusal,
    this.role,
    this.toolCalls,
  });

  factory ChatDelta.fromJson(Map<String, dynamic> json) =>
      _$ChatDeltaFromJson(json);

  Map<String, dynamic> toJson() => _$ChatDeltaToJson(this);
}

@JsonSerializable()
class ChatUsage {
  @JsonKey(name: 'completion_tokens')
  final int? completionTokens;
  @JsonKey(name: 'prompt_tokens')
  final int? promptTokens;
  @JsonKey(name: 'total_tokens')
  final int? totalTokens;

  ChatUsage({
    this.completionTokens,
    this.promptTokens,
    this.totalTokens,
  });

  factory ChatUsage.fromJson(Map<String, dynamic> json) =>
      _$ChatUsageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatUsageToJson(this);
}

@JsonSerializable()
class ToolCall {
  final String? id;
  final String? type;
  @JsonKey(name: 'function')
  final ToolFunction? function;

  ToolCall({
    this.id,
    this.type,
    this.function,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) =>
      _$ToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}

@JsonSerializable()
class ToolFunction {
  final String? arguments;
  final String? name;

  ToolFunction({
    this.arguments,
    this.name,
  });

  factory ToolFunction.fromJson(Map<String, dynamic> json) =>
      _$ToolFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$ToolFunctionToJson(this);
}