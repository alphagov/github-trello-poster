require "sinatra/base"
require "dotenv"
Dotenv.load
require "json"
require "logger"

class GithubTrelloPoster < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  get "/" do
    status 200
    erb :index
  end

  post "/payload" do
    payload = JSON.parse(request.body.read)

    return [400, "Error: Required payload fields missing"] unless %w[action body html_url].all? { |k| payload.key? k }

    return [200, "Skip: review_requested events are ignored"] if payload["action"] == "review_requested"

    trello_card_id = payload["body"].match(%r{https://trello.com/c/(\w{8})}) { |m| m[1] }
    return [200, "Skip: PR description doesn't contain Trello link"] if trello_card_id.nil?

    TrelloPoster.new.post!(payload["html_url"], trello_card_id, payload["action"] == "closed")
    return [200, "OK"]
  end

  # start the server if ruby file executed directly
  run! if app_file == $PROGRAM_NAME
end
