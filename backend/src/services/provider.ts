import type { AppConfig } from "../config.js";
import { AppError } from "../utils.js";
import type { DocumentClassification } from "../types.js";
import { buildExtractionPrompt } from "./prompts.js";

export interface AiProvider {
  readonly providerName: string;
  readonly modelName: string;
  extract(input: {
    classification: DocumentClassification;
    normalizedText?: string;
    document?: {
      mimeType: string;
      dataBase64: string;
    };
  }): Promise<Record<string, unknown>>;
}

export class GeminiProvider implements AiProvider {
  readonly providerName = "gemini";
  private readonly maxAttempts = 3;

  constructor(private readonly config: AppConfig) {}

  get modelName() {
    return this.config.geminiModel;
  }

  async extract(input: {
    classification: DocumentClassification;
    normalizedText?: string;
    document?: {
      mimeType: string;
      dataBase64: string;
    };
  }): Promise<Record<string, unknown>> {
    if (!this.config.geminiApiKey) {
      throw new AppError(503, "provider_unavailable", "Missing Gemini API key");
    }

    for (let attempt = 1; attempt <= this.maxAttempts; attempt += 1) {
      try {
        const response = await this.requestGemini(input);
        if (!response.ok) {
          const body = await readProviderErrorBody(response);
          if (shouldRetry(response.status) && attempt < this.maxAttempts) {
            await backoff(attempt);
            continue;
          }
          throw mapProviderHttpError(response.status, body);
        }

        const payload = (await response.json()) as Record<string, unknown>;
        throwIfBlocked(payload);

        const candidates = Array.isArray(payload.candidates)
          ? payload.candidates
          : [];
        if (candidates.length === 0) {
          throw new AppError(
            502,
            "provider_malformed_response",
            "Gemini response did not contain candidates",
          );
        }
        const text = firstCandidateText(candidates[0]);
        if (!text) {
          throw new AppError(
            502,
            "provider_malformed_response",
            "Gemini did not return JSON text",
          );
        }
        try {
          return JSON.parse(text) as Record<string, unknown>;
        } catch {
          throw new AppError(
            502,
            "provider_malformed_response",
            "Gemini returned malformed JSON",
          );
        }
      } catch (error) {
        if (error instanceof AppError) {
          throw error;
        }
        if (error instanceof Error && error.name === "AbortError") {
          if (attempt < this.maxAttempts) {
            await backoff(attempt);
            continue;
          }
          throw new AppError(504, "provider_timeout", "Gemini timed out");
        }
        if (attempt < this.maxAttempts) {
          await backoff(attempt);
          continue;
        }
        throw new AppError(502, "provider_error", "Gemini request failed");
      }
    }

    throw new AppError(502, "provider_error", "Gemini request failed");
  }

  private async requestGemini(input: {
    classification: DocumentClassification;
    normalizedText?: string;
    document?: {
      mimeType: string;
      dataBase64: string;
    };
  }) {
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort(),
      this.config.requestTimeoutMs,
    );
    try {
      const parts: Array<Record<string, unknown>> = [];
      if (input.document) {
        parts.push({
          inline_data: {
            mime_type: input.document.mimeType,
            data: input.document.dataBase64,
          },
        });
      }
      parts.push({
        text: buildExtractionPrompt(input.classification, input.normalizedText),
      });

      return await fetch(
        `https://generativelanguage.googleapis.com/${this.config.geminiApiVersion}/models/${this.config.geminiModel}:generateContent?key=${this.config.geminiApiKey}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [
              {
                parts,
              },
            ],
            generationConfig: {
              responseMimeType: "application/json",
            },
          }),
          signal: controller.signal,
        },
      );
    } finally {
      clearTimeout(timeout);
    }
  }
}

function shouldRetry(status: number) {
  return (
    status === 429 ||
    status === 500 ||
    status === 502 ||
    status === 503 ||
    status === 504
  );
}

function backoff(attempt: number) {
  const delayMs = 250 * 2 ** (attempt - 1);
  return new Promise((resolve) => setTimeout(resolve, delayMs));
}

function mapProviderHttpError(status: number, _body: string | null) {
  if (status === 429) {
    return new AppError(503, "provider_rate_limited", "Gemini rate limited", {
      providerStatus: status,
      providerBodySnippet: _body,
    });
  }
  if (status >= 500) {
    return new AppError(502, "provider_error", "Gemini service error", {
      providerStatus: status,
      providerBodySnippet: _body,
    });
  }
  if (status === 400 || status === 404) {
    return new AppError(502, "provider_error", "Gemini request rejected", {
      providerStatus: status,
      providerBodySnippet: _body,
    });
  }
  return new AppError(502, "provider_error", "Gemini request failed", {
    providerStatus: status,
    providerBodySnippet: _body,
  });
}

async function readProviderErrorBody(response: Response) {
  try {
    const body = await response.text();
    return body.slice(0, 512);
  } catch {
    return null;
  }
}

function throwIfBlocked(payload: Record<string, unknown>) {
  const promptFeedback = payload.promptFeedback as
    | { blockReason?: string }
    | undefined;
  if (promptFeedback?.blockReason) {
    throw new AppError(502, "provider_blocked", "Gemini blocked the request");
  }
  const candidates = Array.isArray(payload.candidates)
    ? payload.candidates
    : [];
  for (const candidate of candidates) {
    const finishReason = (candidate as { finishReason?: string }).finishReason;
    if (finishReason === "SAFETY" || finishReason === "BLOCKLIST") {
      throw new AppError(502, "provider_blocked", "Gemini blocked the request");
    }
  }
}

function firstCandidateText(candidate: unknown) {
  const candidateRecord = candidate as
    | {
        content?: {
          parts?: Array<{ text?: string }>;
        };
      }
    | undefined;
  const parts = candidateRecord?.content?.parts;
  if (!Array.isArray(parts)) {
    return null;
  }
  for (const part of parts) {
    if (typeof part.text === "string" && part.text.trim().length > 0) {
      return part.text;
    }
  }
  return null;
}
