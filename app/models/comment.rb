class Comment < ApplicationRecord
  belongs_to :pull_request
  after_update_commit -> {
    broadcast_replace_to(
      "pull_request_#{pull_request_id}",
      partial: "pull_requests/pull_request",
      target: "pull_request_#{pull_request_id}",
      locals: { pr: pull_request }
    )
  }
end
