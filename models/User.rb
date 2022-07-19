require 'telegram/bot'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: '../db/db.db')

class User < ActiveRecord::Base
    has_many :wallets, dependent: :destroy

    def self.create_user(message)
        User.create(to_currency:"RUB", token:message.from.id) if (!User.find_by(token:message.from.id))
    end

    def self.manage_to_currency(message, currency)
        User.find_by(token:message.from.id).update(to_currency:currency)
    end

    scope :current_user, -> (token) {find_by(token:token)}
end



