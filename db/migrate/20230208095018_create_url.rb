class CreateUrl < ActiveRecord::Migration[7.0]
  def change
    create_table :urls do |t|
      t.string :url_hash
      t.string :original_url
      t.datetime :expired_date
      t.integer :user_id

      t.timestamps
    end

    add_index :urls, :url_hash
    add_index :urls, :user_id
    add_index :urls, :expired_date
  end
end
