class User < ApplicationRecord
  has_many :pull_requests

  def pull_request_limit
    2
  end
end
