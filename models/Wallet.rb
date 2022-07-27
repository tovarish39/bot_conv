require 'telegram/bot'
require 'active_record'
require 'pathname'

project_root = File.dirname(__dir__ )
db = Pathname.new(project_root + "/db/db.db")
# db = '../db/db.db'
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: db)

class Wallet < ActiveRecord::Base
    belongs_to :user

    def self.create_update(current_user_id, data)
        wallet = Wallet.find_by(user_id:current_user_id, from_currency:data['currency'])
        wallet ? wallet.update(amount:data['value']) : Wallet.create(user_id:current_user_id, from_currency:data['currency'], amount:data['value'])
    end

    def self.delete_currency(current_user_id, currency)
        wallet = Wallet.find_by(user_id:current_user_id, from_currency:currency)
        wallet ? wallet.destroy : ''
    end

    scope :wallets, -> (id) {where(user_id:id)}
end
