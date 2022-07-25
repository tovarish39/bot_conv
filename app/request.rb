require 'net/http'
require 'json'
require 'colorize'
require './find-pairs-to-request.rb'
require '../models/Wallet.rb'
require '../models/User.rb'

def request(wallets, to)
    # wallets = Wallet.all
    # to = 'EUR'


    coins_from = []
    for wallet in wallets
        coins_from << wallet.from_currency 
    end

    pairs_to_request = []
    for from in coins_from
        next if from == to 
        pair_s = get_pair_L1(from, to) || get_pairs_L2(from, to) || get_pairs_L3(from, to)
        pair_s[:pairs].each {|pair| pairs_to_request << pair}
    end

    pairs_str = pairs_to_request.uniq.join('","')
    puts "cois from =  ".yellow + "#{coins_from}"
    puts "coin to = ".yellow + to



    return wallets.first.amount if  pairs_to_request.size == 0
    params =  pairs_to_request.size > 1 ? "symbols=[\"#{pairs_str}\"]" : "symbol=#{pairs_to_request[0]}"
    uri = URI("https://api.binance.com/api/v3/ticker/price?#{params}")

    res = JSON.parse(Net::HTTP.get(uri))

    # puts res_json
    # File.write('./response.txt', res.to_s)


    # res = JSON.parse(File.read('./response.txt'))


    # res = JSON.parse(File.read('./response.txt'))
puts res


    res = [res] if res.class == Hash



    res_pairs = res.map {|obj| obj["symbol"]}





    # GASBTC
    # BTCBBTC
    # BTCBUSD
    # BTCEUR
    # KDABTC










    amount_result = 0
    for wallet in wallets
        from = wallet.from_currency
        amount_current = 0

    # если from и to одинаковы
        if from == to
         amount_result += wallet.amount.to_f
         next
        end

    # если есть прямая или обратная пара из from и to
        if res_pairs.include?(from+to)
          pair = res.select {|obj| obj["symbol"] == from+to}.first
          amount_result += wallet.amount.to_f * pair["price"].to_f
          next
        elsif res_pairs.include?(to+from)
          pair = res.select {|obj| obj["symbol"] == to+from}.first
          amount_result += wallet.amount.to_f / pair["price"].to_f
          next
        end
    #############
        rests_of_pairs_with_from = res_pairs.filter{|pair| pair.match(/^#{from}|#{from}$/)}.map{|pair| pair.gsub(/^#{from}|#{from}$/, '')}
        rests_of_pairs_with_to   = res_pairs.filter{|pair| pair.match(/^#{to}|#{to}$/)}    .map{|pair| pair.gsub(/^#{to}|#{to}$/, '')}
    # если пары через промежуточную валюту
        common_coin = rests_of_pairs_with_from.intersection(rests_of_pairs_with_to)[0]
        if common_coin
            if res_pairs.include?(from+common_coin)
              pair = res.select {|obj| obj["symbol"] == from+common_coin}.first
              amount_current = wallet.amount.to_f * pair["price"].to_f
              if res_pairs.include?(to+common_coin)
                pair = res.select {|obj| obj["symbol"] == to+common_coin}.first
                amount_result += amount_current / pair["price"].to_f
                next
              elsif res_pairs.include?(common_coin+to)
                pair = res.select {|obj| obj["symbol"] == common_coin+to}.first
                amount_result += amount_current * pair["price"].to_f
                next
              end
            elsif res_pairs.include?(common_coin+from)
              pair = res.select {|obj| obj["symbol"] == common_coin+from}.first
              amount_current = wallet.amount.to_f / pair["price"].to_f
              if res_pairs.include?(to+common_coin)
                pair = res.select {|obj| obj["symbol"] == to+common_coin}.first
                amount_result += amount_current / pair["price"].to_f
                next
              elsif res_pairs.include?(common_coin+to)
                pair = res.select {|obj| obj["symbol"] == common_coin+to}.first
                amount_result += amount_current * pair["price"].to_f
                next
              end
            end
        end
    # если пары через промежуточную пару
        coin_common1 = ''
        coin_common2 = ''
        pair_common = ''
        for coin1 in rests_of_pairs_with_from do
          for coin2 in rests_of_pairs_with_to do
            if res_pairs.include?(coin1+coin2)
              pair_common = coin1+coin2
              coin_common1 = coin1
              coin_common2 = coin2
              break
            elsif res_pairs.include?(coin2+coin1)  
              pair_common = coin2+coin1
              coin_common1 = coin2
              coin_common2 = coin1
              break
            end
          end
        end



        if res_pairs.include?(from+coin_common1)
            pair = res.select {|obj| obj["symbol"] == from+coin_common1}.first
            amount_current = wallet.amount.to_f * pair["price"].to_f

            if res_pairs.include?(coin_common1+coin_common2)
                pair = res.select {|obj| obj["symbol"] == coin_common1+coin_common2}.first
                amount_current *= pair["price"].to_f


                if res_pairs.include?(to+coin_common1)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common1}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common1+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common1+to}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                elsif res_pairs.include?(to+coin_common2)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common2}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common2+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common2+to}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                end

            elsif res_pairs.include?(coin_common2+coin_common1)
    # проверено #
                pair = res.select {|obj| obj["symbol"] == coin_common2+coin_common1}.first
                amount_current /= pair["price"].to_f

                if res_pairs.include?(to+coin_common1)
    # проверено #
                  pair = res.select {|obj| obj["symbol"] == to+coin_common1}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common1+to)
    # проверено #             
                  pair = res.select {|obj| obj["symbol"] == coin_common1+to}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(to+coin_common2)
    # проверено #
                  pair = res.select {|obj| obj["symbol"] == to+coin_common2}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common2+to)
    # проверено
                  pair = res.select {|obj| obj["symbol"] == coin_common2+to}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                end
            end

        elsif res_pairs.include?(coin_common1+from)
            pair = res.select {|obj| obj["symbol"] == coin_common1+from}.first
            amount_current = wallet.amount.to_f / pair["price"].to_f


            if res_pairs.include?(coin_common1+coin_common2)
                pair = res.select {|obj| obj["symbol"] == coin_common1+coin_common2}.first
                amount_current *= pair["price"].to_f
                if res_pairs.include?(to+coin_common1)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common1}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common1+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common1+to}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                elsif res_pairs.include?(to+coin_common2)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common2}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common2+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common2+to}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                end
            
            elsif res_pairs.include?(coin_common2+coin_common1)
                pair = res.select {|obj| obj["symbol"] == coin_common2+coin_common1}.first
                amount_current /= pair["price"].to_f

                if res_pairs.include?(to+coin_common1)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common1}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common1+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common1+to}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(to+coin_common2)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common2}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common2+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common2+to}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                end
            end





        elsif res_pairs.include?(from+coin_common2)
            pair = res.select {|obj| obj["symbol"] == from+coin_common2}.first
            amount_current = wallet.amount.to_f * pair["price"].to_f
        
            if res_pairs.include?(coin_common1+coin_common2)
              pair = res.select {|obj| obj["symbol"] == coin_common1+coin_common2}.first
              amount_current *= pair["price"].to_f

                if res_pairs.include?(to+coin_common1)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common1}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common1+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common1+to}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                elsif res_pairs.include?(to+coin_common2)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common2}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common2+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common2+to}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                end

            elsif res_pairs.include?(coin_common2+coin_common1)
                pair = res.select {|obj| obj["symbol"] == coin_common2+coin_common1}.first
                amount_current /= pair["price"].to_f

                if res_pairs.include?(to+coin_common1)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common1}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common1+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common1+to}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(to+coin_common2)
                  pair = res.select {|obj| obj["symbol"] == to+coin_common2}.first
                  amount_result += amount_current / pair["price"].to_f
                  next
                elsif res_pairs.include?(coin_common2+to)
                  pair = res.select {|obj| obj["symbol"] == coin_common2+to}.first
                  amount_result += amount_current * pair["price"].to_f
                  next
                end
            end
        
            elsif res_pairs.include?(coin_common2+from)
                pair = res.select {|obj| obj["symbol"] == coin_common2+from}.first
                amount_current = wallet.amount.to_f / pair["price"].to_f
     
            
                if res_pairs.include?(coin_common1+coin_common2)
                    pair = res.select {|obj| obj["symbol"] == coin_common1+coin_common2}.first
                    amount_current *= pair["price"].to_f
                    if res_pairs.include?(to+coin_common1)
                      pair = res.select {|obj| obj["symbol"] == to+coin_common1}.first
                      amount_result += amount_current / pair["price"].to_f
                      next
                    elsif res_pairs.include?(coin_common1+to)
                      pair = res.select {|obj| obj["symbol"] == coin_common1+to}.first
                      amount_result += amount_current * pair["price"].to_f
                      next
                    elsif res_pairs.include?(to+coin_common2)
                      pair = res.select {|obj| obj["symbol"] == to+coin_common2}.first
                      amount_result += amount_current / pair["price"].to_f
                      next
                    elsif res_pairs.include?(coin_common2+to)
                      pair = res.select {|obj| obj["symbol"] == coin_common2+to}.first
                      amount_result += amount_current * pair["price"].to_f
                      next
                    end
                
                elsif res_pairs.include?(coin_common2+coin_common1)
                    puts '2' 
                  pair = res.select {|obj| obj["symbol"] == coin_common2+coin_common1}.first
                  amount_current /= pair["price"].to_f
                
                  if res_pairs.include?(to+coin_common1)
                    pair = res.select {|obj| obj["symbol"] == to+coin_common1}.first
                    amount_result += amount_current * pair["price"].to_f
                    next
                  elsif res_pairs.include?(coin_common1+to)
                    pair = res.select {|obj| obj["symbol"] == coin_common1+to}.first
                    amount_result += amount_current / pair["price"].to_f
                    next
                  elsif res_pairs.include?(to+coin_common2)
                    pair = res.select {|obj| obj["symbol"] == to+coin_common2}.first
                    amount_result += amount_current / pair["price"].to_f
                    next
                  elsif res_pairs.include?(coin_common2+to)
                    pair = res.select {|obj| obj["symbol"] == coin_common2+to}.first
                    amount_result += amount_current * pair["price"].to_f
                    next
                  end
                end
        end
puts coin_common1
puts coin_common2
puts pair_common
    end
    return amount_result
end

    # puts amount_result
    # puts "#{wallet.from_currency} = #{wallet.amount}"