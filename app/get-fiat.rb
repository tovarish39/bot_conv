require 'telegram/bot'

class Fiat
    def self.get
        popular_fiat_currencies = File.read('../asset/popular-fiat-currencies.txt').split(',')
        array_of_buttons = popular_fiat_currencies.map{|el| Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{el}", callback_data: "#{el}", )}
        return array_of_buttons.each_slice(3).to_a 
    end
end