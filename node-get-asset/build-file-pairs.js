import fsp from "fs/promises"
import fetch from 'node-fetch'

const data = await fetch('https://api.binance.com/api/v3/ticker/price')
fsp.writeFile('../asset/all-pairs.txt', await data.text())

