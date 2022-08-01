require 'net/http'
require 'json'
require 'colorize'
require_relative './find-pairs-to-request.rb'
require_relative '../models/Wallet.rb'

# wallets = Wallet.where(user_id:2)
# puts '1'
# puts wallets.class
# puts wallets.first.from_currency
# puts '1'



def request(wallets, to)
  # puts wallets
  coins_from = []
  pairs_to_request = []
  result = 0
  
  for wallet in wallets
    coins_from << wallet.from_currency 
  end
  
  for from in coins_from
    next if from == to 
    pair_s = get_pair_L1(from, to) || get_pairs_L2(from, to) || get_pairs_L3(from, to)
    pair_s[:pairs].each {|pair| pairs_to_request << pair}
  end


  return wallets.first.amount if  pairs_to_request.size == 0

  pairs_str = pairs_to_request.uniq.join('","')
  
  params = "symbols=[\"#{pairs_str}\"]"
  uri = URI("https://api.binance.com/api/v3/ticker/price?#{params}")
  
  res = JSON.parse(Net::HTTP.get(uri))  
  @res_pairs = res.map {|obj| {obj["symbol"]=>obj["price"]}}
  
puts "cois from = ".yellow + "#{coins_from}"
puts "coin to   = ".yellow + to
puts "response  = ".yellow + "#{res}"
#########################################################################################################################
# handle response
  def value(pair)
      @res_pairs.each  do |obj|
      if obj.keys.first == pair 
        return obj.values.first.to_f
      end
    end
  end

  def have?(pair)
    @res_pairs.each do |obj| 
      if obj.keys.first == pair 
        return true
      end
    end
    return false
  end
#########################################################################################################################
  for wal in wallets
    puts "#{result}".yellow
    current = 0
    from = wal.from_currency
#########################################################################################################################
# если from и to одинаковы
    if from == to; result += wal.amount.to_f; next; end

#########################################################################################################################
# если есть прямая или обратная пара из from и to
    if have?(from+to)
      result += wal.amount.to_f * value(from+to); next
    elsif have?(to+from)
      result += wal.amount.to_f / value(to+from); next
    end

#########################################################################################################################
#############
    response_pairs_arr = res.map {|obj| obj["symbol"]}
    rests_from = response_pairs_arr.filter{|pair| pair.match(/^#{from}|#{from}$/)}.map{|pair| pair.gsub(/^#{from}|#{from}$/, '')}
    rests_to   = response_pairs_arr.filter{|pair| pair.match(/^#{to}|#{to}$/)}    .map{|pair| pair.gsub(/^#{to}|#{to}$/, '')}
# p response_pairs_arr
# p rests_from
# p rests_to

# если пары через промежуточную валюту
    common_coin = rests_from.intersection(rests_to).first
    if common_coin
      if have?(from+common_coin)
        current = wal.amount.to_f * value(from+common_coin)
        if have?(to+common_coin)
          result += current / value(to+common_coin); next
        elsif have?(common_coin+to)
          result += current * value(common_coin+to); next
        end
      elsif have?(common_coin+from)
        current = wal.amount.to_f / value(common_coin+from)
        if have?(to+common_coin)
          result += current / value(to+common_coin); next
        elsif have?(common_coin+to)
          result += current * value(common_coin+to); next
        end
      end
    end
#########################################################################################################################
#############
    coin1C = ''# common coin 1
    coin2C = ''# common coin 2
    pairC = '' # common pair
    for coin1 in rests_from do
      for coin2 in rests_to do
        if have?(coin1+coin2)
          pairC = coin1+coin2
          coin1C = coin1
          coin2C = coin2
          break
        elsif have?(coin2+coin1)  
          pairC = coin2+coin1
          coin1C = coin2
          coin2C = coin1
          break
        end
      end
    end
# если пары через промежуточную пару
# puts "coin1 = #{coin1C}"
# puts "coin2 = #{coin2C}"
    if have?(from+coin1C)
      current = wal.amount.to_f * value(from+coin1C)
      if have?(coin1C+coin2C)
        current *= value(coin1C+coin2C)
        if have?(to+coin1C)
          result += current / value(to+coin1C); next
        elsif have?(coin1C+to)
          result += current * value(coin1C+to); next
        elsif have?(to+coin2C)
          result += current * value(to+coin2C); next
        elsif have?(coin2C+to)
          result += current / value(coin2C+to); next
        end
      elsif have?(coin2C+coin1C)
        current /= value(coin2C+coin1C)
        if have?(to+coin1C)
          result += current * value(to+coin1C); next
        elsif have?(coin1C+to)
          result += current / value(coin1C+to); next
        elsif have?(to+coin2C)
          result += current / value(to+coin2C); next
        elsif have?(coin2C+to)
          result += current * value(coin2C+to); next
        end
      end
    elsif have?(coin1C+from)
      current = wal.amount.to_f / value(coin1C+from)
      if have?(coin1C+coin2C)
        current *= value(coin1C+coin2C)
        if have?(to+coin1C)
          result += current / value(to+coin1C); next
        elsif have?(coin1C+to)
          result += current * value(coin1C+to); next
        elsif have?(to+coin2C)
          result += current / value(to+coin2C); next
        elsif have?(coin2C+to)
          result += current * value(coin2C+to); next
        end
      elsif have?(coin2C+coin1C)
        current /= value(coin2C+coin1C)
        if have?(to+coin1C)
          result += current * value(to+coin1C); next
        elsif have?(coin1C+to)
          result += current / value(coin1C+to); next
        elsif have?(to+coin2C)
          result += current / value(to+coin2C); next
        elsif have?(coin2C+to)
          result += current * value(coin2C+to); next
        end
      end
    elsif have?(from+coin2C)
      current = wal.amount.to_f * value(from+coin2C)
      if have?(coin1C+coin2C)
        current *= value(coin1C+coin2C)
        if have?(to+coin1C)
          result += current / value(to+coin1C); next
        elsif have?(coin1C+to)
          result += current * value(coin1C+to); next
        elsif have?(to+coin2C)
          result += current * value(to+coin2C); next
        elsif have?(coin2C+to)
          result += current / value(coin2C+to); next
        end
      elsif have?(coin2C+coin1C)
        current /= value(coin2C+coin1C)
        if have?(to+coin1C)
          result += current * value(to+coin1C); next
        elsif have?(coin1C+to)
          result += current / value(coin1C+to); next
        elsif have?(to+coin2C)
          result += current / value(to+coin2C); next
        elsif have?(coin2C+to)
          result += current * value(coin2C+to); next
        end
      end
    elsif have?(coin2C+from)
      current = wal.amount.to_f / value(coin2C+from)
      if have?(coin1C+coin2C)
        current *= value(coin1C+coin2C)
        if have?(to+coin1C)
          result += current / value(to+coin1C); next
        elsif have?(coin1C+to)
          result += current * value(coin1C+to); next
        elsif have?(to+coin2C)
          result += current / value(to+coin2C); next
        elsif have?(coin2C+to)
          result += current * value(coin2C+to); next
        end
      elsif have?(coin2C+coin1C)
        current /= value(coin2C+coin1C)
        if have?(to+coin1C)
          result += current * value(to+coin1C); next
        elsif have?(coin1C+to)
          result += current / value(coin1C+to); next
        elsif have?(to+coin2C)
          result += current / value(to+coin2C); next
        elsif have?(coin2C+to)
          result += current * value(coin2C+to); next
        end
      end
    end
  end
  puts "#{result}".yellow
  return result
end



# request(wallets, "USD")
# class Wal_for_debug
#   attr_accessor :from_currency, :amount

#   def initialize(from_currency, amount)
#     @from_currency = from_currency
#     @amount = amount
#   end
# end

# wallets = [ Wal_for_debug.new("EUR", "100"),
#             Wal_for_debug.new("RUB", "6000")
# ]

