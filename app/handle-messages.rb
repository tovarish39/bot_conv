require 'telegram/bot'


def start(bot, message)
    greeting = 'Добро пожаловать в бот "Мои финансы" вы можете заполнить свой банк и отслеживать конвертацию банка в выбраной валюте, которая по умолчанию "RUB"'
    kb_below = Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: [['текущее состояние банка', 'инструкция по изменению отслеживаемых валют']], resize_keyboard:true)
      bot.api.send_message(chat_id: message.chat.id, text: greeting, reply_markup:kb_below, one_time_keyboard: false)
  end
  
  def instruction(bot, message)
    manage_bank = 'для добавления валюты в банк или изменения количества введите: "краткое наименование валюты" = "количесто". Пример "USD=100.50" или "USD=100"'
    delete_currency = 'для удаления валюты из банка введите: "краткое наименование валюты"=0. Пример "USD=0"'
    manage_to_currency = 'изменение валюты для конвертации введите: "конвертировать в "краткое наименование валюты"". Пример "конвертировать в USD"'
  
    kb_inline = [[
      Telegram::Bot::Types::InlineKeyboardButton.new(text: "список фиатных валют", callback_data: "список фиатных валют"),
      Telegram::Bot::Types::InlineKeyboardButton.new(text: "список крипто валют", callback_data: "список крипто валют")
     ]]
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb_inline)
  
    bot.api.send_message(chat_id: message.chat.id, text: manage_bank)
    bot.api.send_message(chat_id: message.chat.id, text: delete_currency)
    bot.api.send_message(chat_id: message.chat.id, text: manage_to_currency, reply_markup:markup)
  end
  
  def get_data(message)
      # if message != nil
        return {
          'currency' => (message.slice(/[A-Za-z]+/) ? message.slice(/[A-Za-z]+/).upcase : 'false' ),
          'value' => message.slice(/([0-9]*[.])?[0-9]+/),
          'to_convert' => (message.match(/конвертировать/ui) ? true : false )
          }
      # end
  end
  
  def get_message_from(wallets)
    message = 'у вас в банке'
    for wal in wallets
      message += "\n \"#{wal.from_currency}\" = #{wal.amount}"
    end
    return message
  end