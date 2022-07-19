require 'telegram/bot'

def get_fiat_catalog_keyboard segment
    popular_fiat_currencies = File.read('../asset/popular-fiat-currencies.txt').split(',')
    array_of_buttons = popular_fiat_currencies.map{|el| Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{el}", callback_data: "#{el}", )}
    return array_of_buttons.each_slice(segment).to_a 
end

def get_cripto_catalog_keyboard segment
    popular_fiat_currencies = File.read('../asset/popular-cripto-currencies.txt').split(',')
    array_of_buttons = popular_fiat_currencies.map{|el| Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{el}", callback_data: "#{el}", )}
    return array_of_buttons.each_slice(segment).to_a 
end