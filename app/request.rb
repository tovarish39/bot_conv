require 'net/http'
require 'json'
require './find-pairs-to-request.rb'
require '../models/Wallet.rb'
require '../models/User.rb'

wallets = Wallet.all
to = 'KDA'

pair_to_request = []
for wallet in wallets
    from = wallet.from_currency 
    pair_s = get_pair_L1(from, to) || get_pairs_L2(from, to) || get_pairs_L3(from, to)
    pair_to_request << {pair: pair_s[:first_target_pair][:target_pair], direction: pair_s[:first_target_pair][:direction]}  if pair_s[:first_target_pair]
    pair_to_request << {pair: pair_s[:second_target_pair][:target_pair], direction: pair_s[:second_target_pair][:direction]} if pair_s[:second_target_pair]
    pair_to_request << {pair: pair_s[:third_target_pair][:target_pair], direction: pair_s[:second_target_pair][:direction]}  if pair_s[:third_target_pair]
end




pairs = pair_to_request.uniq.map {|pair_with_direction| pair_with_direction[:pair]}

params = "symbols=#{pairs}" if pairs.size > 1
params = "symbol=#{pairs[0]}" if pairs.size == 1





# params_str = params.to_s.gsub(' ', '')
# # params = 'symbols=["BTCUSDT","BNBUSDT"]'
# # params = 'symbol=PHBPAX'
# uri = URI("https://api.binance.com/api/v3/ticker/price?#{params_str}")

# res = Net::HTTP.get(uri)
# puts res
# puts JSON.parse(res)['price']