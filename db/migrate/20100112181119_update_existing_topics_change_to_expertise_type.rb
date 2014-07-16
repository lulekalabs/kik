class UpdateExistingTopicsChangeToExpertiseType < ActiveRecord::Migration
  def self.up
    execute "UPDATE topics SET type = 'Expertise' WHERE type IS NULL"
  end

  def self.down
    execute "UPDATE topics SET type = NULL WHERE type = 'Expertise'"
  end
end
