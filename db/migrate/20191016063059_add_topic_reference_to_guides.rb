class AddTopicReferenceToGuides < ActiveRecord::Migration[5.0]
  def change
    add_reference :guides, :topic, foreign_key: true
  end
end
