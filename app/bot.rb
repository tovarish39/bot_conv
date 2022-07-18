# приветствие

# введите одну валюту с указанием количества. Пример: RUB = 1234 или BTC = 1234,1234 
# ввод -> выполнено добавлено в банк/не выполнено результат выполнения без общего статуса банка 
# инлайн кнопка - добавить(повтор сообщений 3-й стр.),  инлайн кнопка - готово = статус


# статус 
# свой банк
# это может быть переконвертировано в ... RUB
# инлайн кнопка - поменять валюту конвертации
# -> введите валюту в которую хотите переконвертировать

# изменить банк
# инлайн кнопка - удаление валюты из отслеживания
# инлайн кнопка - добавление новой валюты или изменения количества существующей


# кнопка reply - информация по текущим курсам(+только для выбранных пар валют)
# кнопка reply - изменить банка 
# кнопка reply - текущий статус

require 'telegram/bot'
require "./get-fiat.rb"



token = '5101790589:AAHIddrd97og8aUGNO40vOB0_00CJMKFsBw'
$mes_bind = ''



#########################################################        
def start(bot, message)

    kb = Fiat.get()
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)


    greeting = 'Добро пожаловать в бот "Мои финансы"'
    bot.api.send_message(chat_id: message.chat.id, text: greeting, reply_markup: markup)
    add_value(bot, message)
end
# 
def add_value bot, message
    text1 = 'введите одну валюту с указанием количества.'
    text2 = 'Пример: RUB = 1234 или BTC = 1234,1234'
    bot.api.send_message(chat_id: message.chat.id, text: text1)
    bot.api.send_message(chat_id: message.chat.id, text: text2)
    $mes_bind = 'add_label'
end
#########################################################  

                   






Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message




###########################
        when Telegram::Bot::Types::CallbackQuery
            puts message.data
            puts message.message.chat.id
bot.api.send_message(chat_id: message.message.chat.id, text: message.data)

###########################
        when Telegram::Bot::Types::Message
           
            if message.text == "/start" 
                start(bot, message)
            elsif $mes_bind == 'add_label'
                puts message.text
                puts '1'
                $mes_bind = ''
            end
        



    end 
  end
end

