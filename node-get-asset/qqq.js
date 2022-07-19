import fetch from 'node-fetch'

// fetch('https://api.binance.com/api/v3/ticker/price?symbols=["BTCUSDT","BNBUSDT"]')
fetch('https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT')
.then(result=>result.json())
.then(q=>console.log(q))