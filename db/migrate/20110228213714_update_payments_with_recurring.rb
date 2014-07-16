class UpdatePaymentsWithRecurring < ActiveRecord::Migration
  def self.up
    add_column :payments, :interval_length, :integer
    add_column :payments, :interval_unit, :string
    add_column :payments, :duration_start_date, :date
    add_column :payments, :duration_occurrences, :integer
  end

  def self.down
    remove_column :payments, :interval_length
    remove_column :payments, :interval_unit
    remove_column :payments, :duration_start_date
    remove_column :payments, :duration_occurrences
  end
end
