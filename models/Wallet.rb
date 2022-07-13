require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: '../db/db.db')

class Wallet < ActiveRecord::Base
end