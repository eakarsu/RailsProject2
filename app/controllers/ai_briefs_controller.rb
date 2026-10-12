require "json"
require "net/http"
require "uri"

class AiBriefsController < ApplicationController
  before_action :authenticate!

  def index
    results = AiResult.where(user_id: current_user.id, feature: "editorial-brief").order(created_at: :desc).limit(30)
    render json: results.map { |result|
      {
        id: result.id,
        name: "Editorial brief · #{result.created_at.strftime('%b %-d, %Y %H:%M')}",
        input: result.input,
        output: result.output,
        model: result.model,
        createdAt: result.created_at
      }
    }
  end

  def create
    prompt = params[:prompt].to_s.strip
    return render json: { error: "prompt_too_short" }, status: :unprocessable_entity if prompt.length < 20

    begin
      model = ENV.fetch("OPENROUTER_MODEL")
      base_url = ENV.fetch("OPENROUTER_BASE_URL").sub(%r{/+$}, "")
      uri = URI.parse("#{base_url}/chat/completions")
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{ENV.fetch('OPENROUTER_API_KEY')}"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(
        model: model,
        messages: [
          { role: "system", content: "You are an editorial operations assistant. Return a concise non-advisory brief with risks, next actions, uncertainty, and required human review." },
          { role: "user", content: prompt }
        ],
        temperature: 0.2,
        max_tokens: 900
      )
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 120) { |http| http.request(request) }
      raise "OpenRouter HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
      brief = JSON.parse(response.body).dig("choices", 0, "message", "content").to_s.strip
      raise "OpenRouter returned empty content" if brief.empty?
    rescue StandardError => error
      Rails.logger.error("AI editorial provider failed: #{error.class}")
      return render json: {
        status: "unavailable",
        message: "The editorial AI provider is unavailable. No brief was generated or saved. Please try again later.",
        humanReviewRequired: true
      }
    end

    persisted = AiResult.create!(user: current_user, feature: "editorial-brief", input: { prompt: prompt }, output: brief, model: model)
    render json: { id: persisted.id, brief: brief, model: model, humanReviewRequired: true }
  end
end
