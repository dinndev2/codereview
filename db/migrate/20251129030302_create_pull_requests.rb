class CreatePullRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :pull_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :link

      t.timestamps
    end
  end
end
