require "sinatra/base"
require "dotenv"
Dotenv.load
require "./lib/trello_poster"
require "json"
require "logger"

class App < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  get "/" do
    status 200
    erb :index
  end

  post "/payload" do
    request.body.rewind
    payload = JSON.parse(request.body.read)

    return [400, "Error: Required payload fields missing"] unless has_required_fields?(payload)

    return [200, "Skip: review_requested events are ignored"] if payload["action"] == "review_requested"

    trello_card_id = payload["pull_request"]["body"].match(%r{https://trello.com/c/(\w{8})}) { |m| m[1] }
    return [200, "Skip: PR description doesn't contain Trello link"] if trello_card_id.nil?

    TrelloPoster.new.post!(payload["pull_request"]["html_url"], trello_card_id, payload["action"] == "closed")
    return [200, "OK"]
  end

  def has_required_fields?(payload)
    [
      %w[action],
      %w[pull_request body],
      %w[pull_request html_url],
    ].all? { |k| !payload.dig(*k).nil? }
  end

  # start the server if ruby file executed directly
  run! if app_file == $PROGRAM_NAME
end
