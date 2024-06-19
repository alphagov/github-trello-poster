require "trello"

class TrelloPoster
  def initialize
    @client = Trello::Client.new(
      developer_public_key: ENV["TRELLO_PUBLIC_KEY"],
      member_token: ENV["TRELLO_MEMBER_TOKEN"],
    )
  end

  def post!(pr_url, trello_card_id, pr_closed)
    trello_card = client.find(:card, trello_card_id)
    pr_checklist = find_or_create_pr_checklist(trello_card)

    if find_pr_on_checklist(pr_checklist, pr_url).nil?
      pr_checklist.add_item(pr_url, false, "bottom")
    end

    mark_as_complete(trello_card, pr_url) if pr_closed
  end

private

  attr_reader :client

  def find_or_create_pr_checklist(trello_card)
    trello_card
      .checklists
      .find { |c| ["pull requests", "prs"].include? c.name.downcase }
      .then { |c| c || client.create(:checklist, "name" => "Pull Requests", "idCard" => trello_card.id) }
  end

  def mark_as_complete(trello_card, pr_url)
    checklist = find_or_create_pr_checklist(trello_card)
    item = find_pr_on_checklist(checklist, pr_url)
    unless item.nil?
      checklist.update_item_state(item["id"], "complete")
      checklist.save
    end
  end

  def find_pr_on_checklist(checklist, pr_url)
    checklist.check_items.find { |item| item["name"].include? pr_url }
  end
end
