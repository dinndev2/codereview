require "gemini-ai"

class ReviewService
  def self.generate_comment(pull_request, prompt)
    user = pull_request.user
    client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GOOGLE_API_KEY'],
        version: 'v1beta'
      },
      options: { model: 'gemini-2.5-flash', server_sent_events: true }
    )
    comment = Comment.create!(pull_request: pull_request, content: "")
    comments = []
    client.generate_content({ contents: { role: 'user', parts: { text: prompt } } }) do |chunk|
      # Safely drill into the structure
      text = chunk.dig("candidates", 0, "content", "parts", 0, "text")
      comments << text
      partial_content = comments.join("")

        # ---- LIVE BROADCAST ----
      comment.update_columns(content: partial_content)
        # ---- MANUAL BROADCAST ----  
      Turbo::StreamsChannel.broadcast_replace_to(
        "pull_request_#{comment.pull_request_id}",
        partial: "pull_requests/pull_request",
        target: "pull_request_#{comment.pull_request_id}",
        locals: { pr: comment.pull_request }
      )
    end

    comment.save!
    rescue => exception
      Rails.logger.error "AI review failed: #{exception.message}"
    end
end