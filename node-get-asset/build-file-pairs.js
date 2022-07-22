import fsp from "fs/promises"
import fetch from 'node-fetch'

const symbols = []
fetch('https://api.binance.com/api/v3/ticker/price')
    .then(data=> data.json())
    .then(json=>{
        json.forEach(el=>{
            symbols.push(el.symbol)
        })
        // fsp.writeFile('../asset/all-pairs.txt', JSON.stringify(symbols).replace(/[\[\]"]/g, ''))
        fsp.writeFile('../asset/all-pairs.txt', JSON.stringify(symbols))
    })


