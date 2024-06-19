require "spec_helper"
RSpec.describe App do
  include Rack::Test::Methods

  def app
    App.new
  end

  describe "GET '/'" do
    it "returns an HTTP 200" do
      response = get "/"
      expect(response.status).to eq(200)
    end
  end

  describe "POST /payload" do
    let(:response) do
      post "/payload", payload, { "Content-Type" => "application/json" }
    end

    context "when payload is valid and contains a Trello card link" do
      let(:card_id) { "12345678" }
      let(:pr_url) { "https://github.com/foo/bar" }
      let(:payload) do
        {
          "action": action,
          "pull_request": {
            "body": "[Trello card](https://trello.com/c/#{card_id}/123-hello-world)",
            "html_url": pr_url,
          },
        }.to_json
      end

      %w[opened closed edited].each do |action|
        context "when action is '#{action}'" do
          let(:action) { action }

          it "calls TrelloPoster#post! and returns an HTTP 200" do
            trello_poster = instance_double(TrelloPoster)
            allow(TrelloPoster).to receive(:new).and_return(trello_poster)
            expect(trello_poster).to receive(:post!).with(pr_url, card_id, action == "closed")
            expect(response.status).to eq(200)
            expect(response.body).to eq("OK")
          end
        end
      end

      context "when action is 'review_requested'" do
        let(:action) { "review_requested" }

        it "returns an HTTP 200 and does not instantiate TrelloPoster" do
          expect(TrelloPoster).not_to receive(:new)
          expect(response.status).to eq(200)
          expect(response.body).to eq("Skip: review_requested events are ignored")
        end
      end
    end

    context "when payload is valid but does not contain a Trello card link" do
      let(:payload) do
        {
          "action": "open",
          "pull_request": {
            "body": "Hello world!",
            "html_url": "https://github.com/foo/bar",
          },
        }.to_json
      end

      it "returns an HTTP 200 and does not instantiate TrelloPoster" do
        expect(TrelloPoster).not_to receive(:new)
        expect(response.status).to eq(200)
        expect(response.body).to eq("Skip: PR description doesn't contain Trello link")
      end
    end

    context "when payload is invalid" do
      let(:payload) { { "stuff": "things" }.to_json }

      it "returns an HTTP 400 and does not instantiate TrelloPoster" do
        expect(TrelloPoster).not_to receive(:new)
        expect(response.status).to eq(400)
        expect(response.body).to eq("Error: Required payload fields missing")
      end
    end
  end
end
