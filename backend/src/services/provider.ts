import type { AppConfig } from '../config.js';
import { AppError } from '../utils.js';
import type { DocumentClassification, ExtractionPayload } from '../types.js';
import { buildExtractionPrompt } from './prompts.js';

export interface AiProvider {
  readonly providerName: string;
  readonly modelName: string;
  extract(input: {
    classification: DocumentClassification;
    normalizedText: string;
  }): Promise<Record<string, unknown>>;
}

export class GeminiProvider implements AiProvider {
  readonly providerName = 'gemini';

  constructor(private readonly config: AppConfig) {}

  get modelName() {
    return this.config.geminiModel;
  }

  async extract(input: {
    classification: DocumentClassification;
    normalizedText: string;
  }): Promise<Record<string, unknown>> {
    if (!this.config.geminiApiKey) {
      throw new AppError(503, 'provider_unavailable', 'Missing Gemini API key');
    }

    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort(),
      this.config.requestTimeoutMs,
    );

    try {
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${this.config.geminiModel}:generateContent?key=${this.config.geminiApiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [
              {
                parts: [
                  {
                    text: buildExtractionPrompt(
                      input.classification,
                      input.normalizedText,
                    ),
                  },
                ],
              },
            ],
            generationConfig: {
              responseMimeType: 'application/json',
            },
          }),
          signal: controller.signal,
        },
      );

      if (!response.ok) {
        throw new AppError(
          response.status,
          'provider_error',
          `Gemini request failed with ${response.status}`,
        );
      }

      const payload = (await response.json()) as Record<string, unknown>;
      const candidates = Array.isArray(payload.candidates)
        ? payload.candidates
        : [];
      const content = candidates[0] as
        | { content?: { parts?: Array<{ text?: string }> } }
        | undefined;
      const text = content?.content?.parts?.[0]?.text;
      if (!text) {
        throw new AppError(
          502,
          'provider_malformed_response',
          'Gemini did not return JSON text',
        );
      }
      return JSON.parse(text) as Record<string, unknown>;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      if (error instanceof Error && error.name === 'AbortError') {
        throw new AppError(504, 'provider_timeout', 'Gemini timed out');
      }
      throw new AppError(502, 'provider_error', 'Gemini request failed');
    } finally {
      clearTimeout(timeout);
    }
  }
}
