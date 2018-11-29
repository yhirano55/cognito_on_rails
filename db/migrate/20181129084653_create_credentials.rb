class CreateCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :credentials do |t|
      t.references :user, foreign_key: true, null: false, index: false
      t.string :domain, null: false
      t.string :token, null: false

      t.timestamps
      t.index [:user_id, :domain], unique: true
    end
  end
end
