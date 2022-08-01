require 'telegram/bot'
require 'json'
@counter = 0
@num = {   '1' => "\x31\xE2\x83\xA3",
           '2' => "\x32\xE2\x83\xA3",
           '3' => "\x33\xE2\x83\xA3",
           '4' => "\x34\xE2\x83\xA3",
           '5' => "\x35\xE2\x83\xA3",
           '6' => "\x36\xE2\x83\xA3",
           '7' => "\x37\xE2\x83\xA3",
           '8' => "\x38\xE2\x83\xA3",
           '9' => "\x39\xE2\x83\xA3",
          '10' => "\x31\xE2\x83\xA3\x30\xE2\x83\xA3",
          '11' => "\x31\xE2\x83\xA3\x31\xE2\x83\xA3",
          '12' => "\x31\xE2\x83\xA3\x32\xE2\x83\xA3",
          '13' => "\x31\xE2\x83\xA3\x33\xE2\x83\xA3",
          '14' => "\x31\xE2\x83\xA3\x34\xE2\x83\xA3",
          '15' => "\x31\xE2\x83\xA3\x35\xE2\x83\xA3",
          '16' => "\x31\xE2\x83\xA3\x36\xE2\x83\xA3",
          '17' => "\x31\xE2\x83\xA3\x37\xE2\x83\xA3",
          '18' => "\x31\xE2\x83\xA3\x38\xE2\x83\xA3",
          '19' => "\x31\xE2\x83\xA3\x39\xE2\x83\xA3",
          '20' => "\x32\xE2\x83\xA3\x30\xE2\x83\xA3",
        }

def get_fiat_catalog_keyboard segment
    popular_fiat_currencies = File.read('../asset/popular-fiat-currencies.txt').split(',')
    array_of_buttons = popular_fiat_currencies.map{|el| Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{el}", callback_data: "#{el}", )}
    return array_of_buttons.each_slice(segment).to_a 
end

def get_full_catalog_keyboard segment, page_cur = 1
    @counter = (@counter < 1000) ? @counter + 1 : 0


    coins = JSON.parse(File.read('../asset/coins.txt'))
    array_of_buttons = coins.map{|el| Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{el}", callback_data: "#{el}", )}
    all_coins_arr = array_of_buttons.each_slice(segment).to_a 
    pages = all_coins_arr.each_slice(9).to_a


    
    size = pages.size
    
    page_back    = (page_cur.to_i == 1) ? size : page_cur.to_i - 1
    page_forward = (page_cur.to_i == size) ? 1 : page_cur.to_i + 1
    
    # puts page_forward
    # puts @num["page_forward"]
    pages.each {|page| page.push([Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{@num["#{page_back}"]}/#{size}\xE2\x8F\xAA", callback_data: "f #{page_back}"),
                                  Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{@num["#{page_cur}"]}/#{size}", callback_data: "counter = #{@counter}"),
                                  Telegram::Bot::Types::InlineKeyboardButton.new(text: "\xE2\x8F\xA9\ #{@num["#{page_forward}"]}/#{size}", callback_data: "f #{page_forward}")
        ]) } 




    return pages[page_cur.to_i-1]
end



# def get_cripto_catalog_keyboard segment
#     popular_fiat_currencies = File.read('../asset/popular-cripto-currencies.txt').split(',')
#     array_of_buttons = popular_fiat_currencies.map{|el| Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{el}", callback_data: "#{el}", )}
#     return array_of_buttons.each_slice(segment).to_a 
# end