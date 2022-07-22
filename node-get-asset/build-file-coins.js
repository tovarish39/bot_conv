import fetch from 'node-fetch'
import _     from 'lodash'
import fsp   from 'fs/promises'

const get_coins = (symbols) => {
    const coins = []
    symbols.forEach(symbol=>{
        coins.push(symbol.baseAsset)
        coins.push(symbol.quoteAsset)
    })
    return _.uniq(coins)
}


const to_handled_string = (coins) => {
    return JSON.stringify(coins)
    // const str = JSON.stringify(coins)
    // return str.replace(/[\[\]"]/g, '')
}


fetch("https://api.binance.com/api/v3/exchangeInfo")
    .then(response=>response.json())
    .then(json=> get_coins(json.symbols))
    .then(coins=>fsp.writeFile('../asset/coins.txt',  to_handled_string(coins)))
