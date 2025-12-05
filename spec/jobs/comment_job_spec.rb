require 'pry'
require "rails_helper"

RSpec.describe CommentJob, type: :job do
  let(:pull_request) { double("PullRequest", repo_full_name: "test/test", number: 1) }
  let(:user) { double("User", id: 1) }
  let(:client) { instance_double(Octokit::Client) }


  describe "perform" do
    before do
      allow(Octokit::Client).to receive(:new).and_return(client)
      allow(client).to receive(:pull_request)
        .with(pull_request.repo_full_name, pull_request.number, accept: "application/vnd.github.diff")
        .and_return("diff")
      allow(client).to receive(:pull_request_files)
        .with(pull_request.repo_full_name, pull_request.number)
        .and_return(["file1", "file2"])

    end

    context "when the pull request is too big to review" do
      it "updates the pull request comment with a message" do
        allow(Utilities).to receive(:pr_too_big?).and_return(true)
        allow(pull_request).to receive(:create_comment!)
          .with(content: "Pull request is too big to review")
        CommentJob.perform_now(pull_request)
      end
    end

    context "when PR is valid" do
      it "generates a comment for the pull request" do
        allow(Utilities).to receive(:pr_too_big?).and_return(false)
        allow(ReviewService).to receive(:generate_comment)
          .with(pull_request, "Review the following GitHub pull request diff and provide clear feedback. diff")
        CommentJob.perform_now(pull_request)
        expect(ReviewService).to have_received(:generate_comment).with(pull_request, "Review the following GitHub pull request diff and provide clear feedback. diff")
      end
    end
  end
end