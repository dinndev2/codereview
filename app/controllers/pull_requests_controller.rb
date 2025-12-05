class PullRequestsController < ApplicationController
  before_action :set_pull_request, only: [:show]

  def index
    @pull_requests = PullRequest.order(created_at: :desc)
  end

  def show
    @pull_request = PullRequest.find(params[:id])
  end

  def create
    @pull_request = PullRequest.new(pull_request_params)
    @pull_request.user = User.first
    if @pull_request.save
      CommentJob.perform_later(@pull_request)
      flash[:notice] = "Pull request is now being reviewed"
      redirect_to pull_requests_path
    else
      flash[:alert] = "Failed to review pull request: #{@pull_request.errors.full_messages.join(", ")}"
      redirect_to pull_requests_path
    end
  end

  private

  def set_pull_request
    @pull_request = PullRequest.find(params[:id])
  end

  def pull_request_params
    params.require(:pull_request).permit(:link)
  end
end