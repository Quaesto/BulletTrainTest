class CreateSaloons < ActiveRecord::Migration[7.1]
  def change
    create_table :saloons do |t|
      t.references :team, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
