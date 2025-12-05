require 'rails_helper'
require 'gemini-ai'

RSpec.describe ReviewService, type: :service do  
  let(:pull_request) { instance_double("PullRequest", id: 1, user: "user") }
  let(:comment) { instance_double("Comment", pull_request_id: 1, pull_request: pull_request) }
  let(:client) { double("Gemini") }
  let(:prompt) { "Please review this code" }

  before do
    # Stub Gemini client creation
    allow(Gemini).to receive(:new).and_return(client)
    # Stub generate_content so it yields fake AI chunks
    allow(client).to receive(:generate_content) do |args, &block|
      block.call({
        "candidates" => [
          { "content" => { "parts" => [{ "text" => "AI comment part 1" }] } }
        ]
      })
      block.call({
        "candidates" => [
          { "content" => { "parts" => [{ "text" => "AI comment part 2" }] } }
        ]
      })
    end

    # Stub Comment creation
    allow(Comment).to receive(:create!).and_return(comment)
    
    # Stub update_columns to avoid touching the DB
    allow(comment).to receive(:update_columns)
    
    # Stub Turbo broadcast
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    
    # Stub save! to avoid touching the DB
    allow(comment).to receive(:save!)
  end

  describe "#generate_comment" do
    it "generates a comment for the pull request" do
      ReviewService.generate_comment(pull_request, prompt)
      expect(comment).to have_received(:update_columns).with(content: "AI comment part 1")
      expect(comment).to have_received(:update_columns).with(content: "AI comment part 1AI comment part 2")
    end

    it "updates the comment with AI-generated content" do
      ReviewService.generate_comment(pull_request, prompt)
      expect(comment).to have_received(:update_columns).with(content: "AI comment part 1")
      # Since we yield twice, the final content should include both parts
      expect(comment).to have_received(:update_columns).with(content: "AI comment part 1AI comment part 2")
    end
  end

  

end