require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: '../db.db')

class CreateWallets < ActiveRecord::Migration[7.0]
    def change
        change_column :wallets, :amount, :string
    end
  end

CreateWallets.migrate(:up)  