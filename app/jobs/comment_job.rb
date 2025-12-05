class CommentJob < ApplicationJob
  queue_as :default


  def perform(pull_request)
    repo   = pull_request.repo_full_name
    number = pull_request.number
    client = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])
    diff = client.pull_request(repo, number, accept: "application/vnd.github.diff")
    files = client.pull_request_files(repo, number)
    if Utilities.pr_too_big?(files)
      Rails.logger.error "Pull request is too big to review"
      pull_request.create_comment!(content: "Pull request is too big to review")
      return
    end
    prompt = "Review the following GitHub pull request diff and provide clear feedback. #{diff}"
    ReviewService.generate_comment(pull_request, prompt)
    rescue => exception
      pull_request.comment.update!(content: "Failed to generate comment: #{exception.message}")
      Rails.logger.error "AI review failed: #{exception.message}"
    end
end