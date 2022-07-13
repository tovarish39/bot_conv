
require 'active_record'
# require 'sqlite3'

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
    

class CreateCurrencies < ActiveRecord::Migration[7.0]
    def change
      create_table :currencies do |t|
        t.string :currency, null: false, primary_key: true
      end
    end
  end
  
class CreatePairs < ActiveRecord::Migration[7.0]
  def change
    create_table :pairs do |t|
      t.string :pair, null: false, primary_key: true
    end
  end
end

CreateUsers.migrate(:up)  
CreateWallets.migrate(:up)  
CreateCurrencies.migrate(:up)  
CreatePairs.migrate(:up)  

