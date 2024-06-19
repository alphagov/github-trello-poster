require "trello"

class TrelloPoster
  def initialize(client = nil)
    @client = client || Trello::Client.new(
      developer_public_key: ENV["TRELLO_PUBLIC_KEY"],
      member_token: ENV["TRELLO_MEMBER_TOKEN"],
    )
  end

  def post!(pr_url, trello_card_id, pr_closed)
    trello_card = client.find(:card, trello_card_id)
    pr_checklist = find_or_create_pr_checklist(trello_card)
    item = find_or_create_checklist_item(pr_checklist, pr_url)

    mark_as_complete(pr_checklist, item) if pr_closed
  end

private

  attr_reader :client

  def find_or_create_pr_checklist(trello_card)
    trello_card.checklists.find { |c| ["pull requests", "prs"].include? c.name.downcase } ||
      client.create(:checklist, "name" => "Pull Requests", "idCard" => trello_card.id)
  end

  def find_or_create_checklist_item(checklist, pr_url)
    checklist.check_items.find { |item| item["name"].include? pr_url } ||
      checklist.add_item(pr_url, false, "bottom")
  end

  def mark_as_complete(checklist, item)
    checklist.update_item_state(item["id"], "complete")
    checklist.save
  end
end
