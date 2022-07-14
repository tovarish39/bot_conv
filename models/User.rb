require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: '../db/db.db')

class User < ActiveRecord::Base
    has_many :wallets, dependent: :destroy
end