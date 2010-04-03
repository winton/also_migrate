class RemoveMagicColumns < ActiveRecord::Migration
  def self.up
    remove_column :articles, :move_id
    remove_column :articles, :moved_at
  end

  def self.down
  end
end