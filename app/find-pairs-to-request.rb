require 'json'
require 'colorize'
require 'pathname'



all_pairs = Pathname.new(__dir__ + "/../asset/all-pairs.txt")
coins     = Pathname.new(__dir__ + "/../asset/coins.txt")

Pairs = JSON.parse(File.read(all_pairs))
Coins = JSON.parse(File.read(coins))



# не забыть RUB => RUB

# если есть прямая пара или обратная
def get_pair_L1(from, to)
  pair_direct = Pairs.include?(from + to) ? from + to : nil  
  pair2_reverse = Pairs.include?(to + from) ? to + from : nil  
  return nil unless pair_direct || pair2_reverse
  return {pairs: [pair_direct || pair2_reverse]}
  # return {pair: pair_direct,   direction: 'direct', have_in_Pairs?: Pairs.include?(pair_direct) } if pair_direct
  # return {pair: pair2_reverse, direction: 'reverse', have_in_Pairs?: Pairs.include?(pair2_reverse)} if pair2_reverse
end




def get_rests(from, to)
  pairs_with_from = Pairs.filter{|pair| pair.match(/^#{from}|#{from}$/)}
  pairs_with_to   = Pairs.filter{|pair| pair.match(/^#{to}|#{to}$/)}

  rest_of_pairs_with_from_raw = pairs_with_from.map {|pair| pair.gsub(/^#{from}|#{from}$/, '')}
  rest_of_pairs_with_to_raw   = pairs_with_to.map   {|pair| pair.gsub(/^#{to}|#{to}$/, '')}

  rest_of_pairs_with_from = rest_of_pairs_with_from_raw.filter {|coin_raw| Coins.include?(coin_raw)}
  rest_of_pairs_with_to   = rest_of_pairs_with_to_raw.filter {|coin_raw| Coins.include?(coin_raw)}
  
  return [rest_of_pairs_with_from, rest_of_pairs_with_to, pairs_with_from, pairs_with_to]
end

# если есть между currencies 2-е пары с 3-ей промежуточной currency
def get_pairs_L2(from, to)
  rest_of_pairs_with_from, rest_of_pairs_with_to, pairs_with_from, pairs_with_to = get_rests(from, to)

  common_coin = rest_of_pairs_with_from.intersection(rest_of_pairs_with_to)
  common_coin_first = common_coin[0]
  return nil if common_coin_first.nil?

  
  first_pair  = Pairs.include?(from + common_coin_first) ? from + common_coin_first : common_coin_first + from
  second_pair = Pairs.include?(to + common_coin_first)   ? to + common_coin_first   : common_coin_first + to
  
  first_direction  =  first_pair.match(/^#{from}/) ? 'direct' : 'reverse' 
  second_direction = second_pair.match(/^#{to}/)   ? 'direct' : 'reverse' 
  puts "error".red unless Pairs.include?(first_pair) || Pairs.include?(second_pair)
  return {pairs: [first_pair, second_pair]}
  # return {:first_pair  => { pair: first_pair,  direction: first_direction, have_in_Pairs?: Pairs.include?(first_pair)},
  #         :second_pair => { pair: second_pair, direction: second_direction, have_in_Pairs?: Pairs.include?(second_pair)}
  #       }
end

# если между currencies промежуточная пара
def get_pairs_L3(from, to)
  
  rest_of_pairs_with_from, rest_of_pairs_with_to, pairs_with_from, pairs_with_to = get_rests(from, to)
  
  pair_common = ''
  coin1_of_pair_common  = ''
  coin2_of_pair_common = ''
  dicrection_of_pair_common = ''
  first_pair = ''
  second_pair = ''

  coin11 = ''
  coin12 = ''
  coin21 = ''
  coin22 = ''
  
    for coin1 in rest_of_pairs_with_from do
      for coin2 in rest_of_pairs_with_to do
        pair_direct  = coin1 + coin2
        pair_reverse = coin2 + coin1
        if Pairs.include?(pair_direct)
          coin1_of_pair_common  = coin1
          coin2_of_pair_common = coin2
          dicrection_of_pair_common = 'direct'
          pair_common = pair_direct
          break
        elsif Pairs.include?(pair_reverse)
          coin1_of_pair_common  = coin1
          coin2_of_pair_common = coin2
          dicrection_of_pair_common = 'reverse'
          pair_common = pair_reverse
          break
        end
      end
      break if pair_common.size > 0
    end

  if dicrection_of_pair_common == 'direct'
    first_pair  = Pairs.include?(from + coin1_of_pair_common) ? from + coin1_of_pair_common : coin1_of_pair_common + from
    coin11 = from
    coin12 = coin1_of_pair_common
    second_pair = Pairs.include?(to + coin2_of_pair_common)   ? to + coin2_of_pair_common   : coin2_of_pair_common + to
    coin21 = to
    coin22 = coin2_of_pair_common
  elsif   dicrection_of_pair_common == 'reverse'
    first_pair  = Pairs.include?(from + coin1_of_pair_common) ? from + coin1_of_pair_common  : coin1_of_pair_common + from
    coin11 = from
    coin12 = coin1_of_pair_common
    second_pair = Pairs.include?(to + coin2_of_pair_common)   ?  to + coin2_of_pair_common    : coin2_of_pair_common + to
    coin21 = to
    coin22 = coin2_of_pair_common
  end

  first_direction  =  first_pair.match(/^#{from}/) ? 'direct' : 'reverse' 
  second_direction = second_pair.match(/^#{to}/)   ? 'direct' : 'reverse' 
  puts "error".red unless Pairs.include?(first_pair) || Pairs.include?(second_pair) || Pairs.include?(pair_common)
  return {pairs: [first_pair, second_pair, pair_common]}
  # return {:first_pair =>  { pair: first_pair, direction: first_direction, coin_from:coin11, coin_last:coin12, have_in_Pairs?: Pairs.include?(first_pair)},
  #         :second_pair => { pair: second_pair, direction: second_direction, coin_to:coin21, coin_last:coin22, have_in_Pairs?: Pairs.include?(second_pair)},
  #         :pair_common => { pair: pair_common, direction: dicrection_of_pair_common, coin1:coin1_of_pair_common, coin2:coin2_of_pair_common, have_in_Pairs?: Pairs.include?(pair_common)} }
end



# to = Coins[rand(Coins.size-1)]
# coins = [] 
# 1000.times do
#    coins << Coins[rand(Coins.size-1)]
# end
# puts  "coins from =  #{coins}".yellow
# puts  "coin to =  #{to}".green


# for from in coins
#   if from == to
#     puts from.cyan + to.red
#     next
#   end
#   pair_s = get_pair_L1(from, to) || get_pairs_L2(from, to) || get_pairs_L3(from, to)
#   # puts pair_s
# end

