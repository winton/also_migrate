class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :header
      t.string :description
    end
  end

  def self.down
    drop_table :comments
  end
end