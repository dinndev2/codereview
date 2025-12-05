class PullRequest < ApplicationRecord
  belongs_to :user, optional: true
  has_one :comment, dependent: :destroy

  validates :link, presence: true
  validates :link, format: { with: URI::DEFAULT_PARSER.make_regexp(['http', 'https']), message: 'must be a valid HTTP or HTTPS URL' }

  def repo_full_name
    parts = URI.parse(link).path.split("/")
    "#{parts[1]}/#{parts[2]}"
  end

  def number
    link.split("/").last
  end
end
