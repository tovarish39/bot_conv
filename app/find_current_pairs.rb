require 'json'

Pairs = JSON.parse(File.read('../asset/all-pairs.txt'))
Coins = JSON.parse(File.read('../asset/coins.txt'))

# не забыть RUB => RUB

# если есть прямая пара или обратная
def get_pair_L1(cur_from, cur_to)
  pair1 = Pairs.include?(cur_from + cur_to) ? cur_from + cur_to : nil  
  pair2 = Pairs.include?(cur_to + cur_from) ? cur_to + cur_from : nil  
  return nil unless pair1 || pair2
  return {:target_pair => (pair1 || pair2)}
end




def get_rests(cur_from, cur_to)
  pairs_with_cur_from = Pairs.filter{|pair| pair.match(/^#{cur_from}|#{cur_from}$/)}
  pairs_with_cur_to   = Pairs.filter{|pair| pair.match(/^#{cur_to}|#{cur_to}$/)}

  rest_of_pairs_with_cur_from = pairs_with_cur_from.map {|pair| pair.gsub(cur_from, '')}
  rest_of_pairs_with_cur_to   = pairs_with_cur_to.map {|pair| pair.gsub(cur_to, '')}
  return [rest_of_pairs_with_cur_from, rest_of_pairs_with_cur_to]
end

# если есть между currencies 2-е пары с 3-ей промежуточной currency
def get_pair_L2(cur_from, cur_to)
  rest_of_pairs_with_cur_from, rest_of_pairs_with_cur_to = get_rests(cur_from, cur_to)

  intersection_cur = rest_of_pairs_with_cur_from.intersection(rest_of_pairs_with_cur_to)
  first_intersection_cur = intersection_cur[0]
  return nil if first_intersection_cur.nil?

  first_target_pair  = Pairs.include?(cur_from + first_intersection_cur) ? cur_from + first_intersection_cur : first_intersection_cur + cur_from
  second_target_pair = Pairs.include?(cur_to + first_intersection_cur)   ? cur_to + first_intersection_cur   : first_intersection_cur + cur_to
  return {:first_target_pair => first_target_pair, :second_target_pair => second_target_pair}
end

# если между currencies промежуточная пара
def get_pair_L3(cur_from, cur_to)
    rest_of_pairs_with_cur_from, rest_of_pairs_with_cur_to = get_rests(cur_from, cur_to)

    for coin1 in rest_of_pairs_with_cur_from do
      for coin2 in rest_of_pairs_with_cur_to do
        pair1 = coin1 + coin2
        pair2 = coin2 + coin1
        if Pairs.include?(pair1)
            return pair1
        elsif Pairs.include?(pair2)
            return pair2
        end
      end
    end
end



# cur1 = "PROS" #VIA
# cur2 = "BTCB" #FILUP


cur1 = Coins[rand(Coins.size-1)]
cur2 = Coins[rand(Coins.size-1)]
puts "cur1 = #{cur1}"
puts "cur2 = #{cur2}"

first_level  = get_pair_L1(cur1, cur2)
second_level = get_pair_L2(cur1, cur2)
third_level  = get_pair_L3(cur1, cur2)

if first_level != nil
  puts 'first level'
  p first_level
elsif second_level != nil
  puts 'second level'
  p second_level
elsif third_level != nil
    puts 'third level'
    p third_level
end

