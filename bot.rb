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

token = '5101790589:AAHIddrd97og8aUGNO40vOB0_00CJMKFsBw'
$mes_bind = ''

#########################################################        
def start(bot, message)
    greeting = 'Добро пожаловать в бот "Мои финансы"'
    reply_buttons = Telegram::Bot::Types::ReplyKeyboardMarkup
                .new(keyboard: [['текущие курсы', 'изменить банк', 'текущий статус']], resize_keyboard: true)
    bot.api.send_message(chat_id: message.chat.id, text: greeting, reply_markup: reply_buttons)
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
       
###########################
        when Telegram::Bot::Types::Message
           
            if message.text == "/start" 
                start(bot, message)
            end


            if $mes_bind == 'add_label'
                puts message.text
                $mes_bind = ''
            end
        



    end 
  end
end