
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: '../db.db')

class CreateUsers < ActiveRecord::Migration[7.0]
    def change
      create_table :users do |t|
        t.string :to_currency, null: false
        t.string :token, null: false
      end
    end
  end
  
class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :from_currency, null: false
      t.integer :amount, null: false
    end
  end
end
    
CreateUsers.migrate(:up)  
CreateWallets.migrate(:up)  

