require 'telegram/bot'

token = '5101790589:AAHIddrd97og8aUGNO40vOB0_00CJMKFsBw'

Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
        case message
        when Telegram::Bot::Types::CallbackQuery
          # Here you can handle your callbacks from inline buttons
          kb = [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Go', url: 'https://google.com'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Touch', callback_data: 'touch'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Swich', switch_inline_query: 'some text')
          ]
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
          puts message.id
          bot.api.editMessageReplyMarkup(chat_id:message.message.chat.id, message_id: message.message.message_id, reply_markup: markup)
          
          if message.data == 'touch'
            bot.api.send_message(chat_id: message.from.id, text: "Don't touch me!")
          end
        when Telegram::Bot::Types::Message
          kb = [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Go to Google', url: 'https://google.com'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Touch me', callback_data: 'touch'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Switch to inline', switch_inline_query: 'some text')
          ]
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
          bot.api.send_message(chat_id: message.chat.id, text: 'Make a choice', reply_markup: markup)
        end
      end
  end