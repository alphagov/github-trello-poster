require "trello_poster"

describe TrelloPoster do
  subject(:trello_poster) { described_class.new client }

  let(:client) { instance_double Trello::Client }
  let(:pr_url) { "https://github.com/foo/bar" }
  let(:trello_card_id) { "123456" }
  let(:trello_card) { instance_double Trello::Card, id: trello_card_id, checklists: }
  let(:unrelated_checklist) { instance_double Trello::Checklist, name: "Acceptance criteria", check_items: [] }
  let(:pr_checklist) { instance_double Trello::Checklist, name: "Pull Requests", check_items: }
  let(:checklists) { [unrelated_checklist, pr_checklist] }
  let(:check_item_id) { "123" }
  let(:check_item) { { "id" => check_item_id, "name" => pr_url } }
  let(:check_items) { [check_item] }
  let(:pr_closed) { false }

  def post!
    trello_poster.post! pr_url, trello_card_id, pr_closed
  end

  before do
    allow(client).to receive(:find)
      .with(:card, trello_card_id)
      .and_return(trello_card)
  end

  context "when the Trello card already contains a link to the PR, and the PR is not closed" do
    it "does nothing" do
      post!
    end
  end

  context "when there is no existing PR checklist" do
    let(:checklists) { [unrelated_checklist] }

    it "creates a new checklist" do
      expect(client).to receive(:create)
        .once
        .with(:checklist, { "idCard" => trello_card_id, "name" => "Pull Requests" })
        .and_return(pr_checklist)

      post!
    end
  end

  context "when there is no matching item on the PR checklist" do
    let(:check_items) { [{ "name" => "https://github.com/some/other/pr" }] }

    it "adds a checklist item for the PR" do
      expect(pr_checklist).to receive(:add_item)
        .once
        .with(pr_url, false, "bottom")
        .and_return(check_item)

      post!
    end
  end

  context "when the PR is closed" do
    let(:pr_closed) { true }

    it "marks the item as complete" do
      expect(pr_checklist).to receive(:update_item_state).with(check_item_id, "complete").once
      expect(pr_checklist).to receive(:save).once

      post!
    end
  end
end
