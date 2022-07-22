import fs from 'fs'
import _ from 'lodash'

const coins = fs.readFileSync('../asset/coins.txt', 'utf-8')
const json_coins = JSON.parse(coins)

const json_pairs = JSON.parse(fs.readFileSync('../asset/all-pairs.txt', 'utf-8'))

const currency1 = json_coins[_.random(0, json_coins.length - 1)]
const currency2 = json_coins[_.random(0, json_coins.length - 1)]

const regex_currency1 = new RegExp(`(^${currency1}|${currency1}$)`)
const regex_currency2 = new RegExp(`(^${currency2}|${currency2}$)`)


// const pair_1_1 = currency1 + currency2
// const pair_1_2 = currency2 + currency1



const half_pair_1 = json_pairs.filter(pair=>pair.match(regex_currency1))
const half_pair_2 = json_pairs.filter(pair=>pair.match(regex_currency2))

const half_pair_1_rest = half_pair_1.map(pair=>pair.replace(currency1, ''))
const half_pair_2_rest = half_pair_2.map(pair=>pair.replace(currency2, ''))


// console.log('currency1 = ', currency1)
// console.log('currency2 = ', currency2)
// console.log(half_pair_1_rest)
// console.log(half_pair_2_rest)


let flag = false
for (const el1 of half_pair_1_rest){
    for (const el2 of half_pair_2_rest){
        const pair = el1+el2
        const pair_reverse = el2+el1
        if (json_pairs.includes(pair)) {
            flag = true
            console.log('pair = ', pair)
            break
        }
        if (json_pairs.includes(pair_reverse)){
            flag = true
            console.log('pair_reverse = ', pair_reverse)
            break 
        }
    }
    if (flag == true) break
}

// console.log(flag)


const intersection = _.intersection(half_pair_1_rest, half_pair_2_rest)

// console.log('pair_1_1 = ', json_pairs.includes(pair_1_1))
// console.log('pair_1_2 = ', json_pairs.includes(pair_1_2))

// console.log('currency1 = ', currency1)
// console.log('currency2 = ', currency2)
// console.log('intersection = ', intersection)

