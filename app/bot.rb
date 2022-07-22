require 'telegram/bot'

require "./get-fiat.rb"       # get_cripto_catalog_keyboard(), get_fiat_catalog_keyboard()
require '../models/User.rb'   # create_user(), 
require '../models/Wallet.rb' #
require './handle-messages.rb'# start(), instruction(), get_data()

token = '5101790589:AAHIddrd97og8aUGNO40vOB0_00CJMKFsBw'
list_currencies = File.read('../asset/coins.txt')






Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
      when Telegram::Bot::Types::Message
######################################################
        if (message.text == '/start')
            start(bot, message)
#           # создание user
            User.create_user(message)
        elsif (message.text == 'инструкция по изменению отслеживаемых валют')
            instruction(bot, message)
      
        else
          data = get_data(message.text)
          if data != nil
            if (data['to_convert'] && list_currencies.include?(data['currency']))
#             # ввод валюты для конвертации
              User.manage_to_currency(message, data['currency'])
              bot.api.send_message(chat_id: message.chat.id, text: "#{data['currency']} на конвертацию")
            elsif (list_currencies.include?(data['currency']) && (data['value']))
              if (data['value'] == '0')
#               # если 0, то удаление валюты из банка
                current_user_id = User.current_user(message.from.id).id
                Wallet.delete_currency(current_user_id, data['currency'])
                bot.api.send_message(chat_id: message.chat.id, text: "удаление из банка #{data['currency']}")
              else
#               # ввод валюты + значение
                current_user_id = User.current_user(message.from.id).id
                Wallet.create_update(current_user_id, data)
                bot.api.send_message(chat_id: message.chat.id, text: "добавление #{data['currency']} == #{data['value']}")
              end
            else
              messege_output = 'введённая валюта не отслеживается или не корректный ввод'
              bot.api.send_message(chat_id: message.chat.id, text: messege_output)
              instruction(bot, message)
            end
          end
        end
######################################################
      when Telegram::Bot::Types::CallbackQuery
        if message.data == 'список фиатных валют'
          kb = get_fiat_catalog_keyboard(5)
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)  
          bot.api.send_message(chat_id: message.message.chat.id, text: "список фиатных валют", reply_markup:markup)
        elsif message.data == 'список крипто валют'
          kb = get_cripto_catalog_keyboard(5)
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)  
          bot.api.send_message(chat_id: message.message.chat.id, text: "список крипто валют", reply_markup:markup)
        end
######################################################
    end 
  end
end



