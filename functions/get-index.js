const fs = require("fs")
const Mustache = require('mustache')
const AWSXRay = require('aws-xray-sdk-core')
const https = process.env.LAMBDA_RUNTIME_DIR
  ? AWSXRay.captureHTTPs(require('https'))
  : require('https')
const aws4 = require('aws4')
const URL = require('url')
const Log = require('@perform/lambda-powertools-logger')
const wrap = require('@perform/lambda-powertools-pattern-basic')
const CorrelationIds = require('@perform/lambda-powertools-correlation-ids')

const restaurantsApiRoot = process.env.restaurants_api
const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
const ordersApiRoot = process.env.orders_api

let html

function loadHtml () {
  if (!html) {
    Log.debug('loading index.html...')
    html = fs.readFileSync('static/index.html', 'utf-8')
    Log.debug('loaded')
  }
  
  return html
}

const getRestaurants = () => {
  const url = URL.parse(restaurantsApiRoot)
  const opts = {
    host: url.hostname, 
    path: url.pathname
  }

  aws4.sign(opts)

  return new Promise((resolve, reject) => {
    const options = {
      hostname: url.hostname,
      port: 443,
      path: url.pathname,
      method: 'GET',
      headers: Object.assign({}, CorrelationIds.get(), opts.headers)
    }

    const req = https.request(options, res => {
      res.on('data', buffer => {
        const body = buffer.toString('utf8')
        resolve(JSON.parse(body))
      })
    })

    req.on('error', err => reject(err))

    req.end()
  })
}

module.exports.handler = wrap(async (event, context) => {
  const template = loadHtml()
  const restaurants = await getRestaurants()
  Log.debug('received restaurants', { count: restaurants.length })

  const dayOfWeek = days[new Date().getDay()]
  const html = Mustache.render(template, { 
    dayOfWeek, 
    restaurants, 
    searchUrl: `${restaurantsApiRoot}/search`,
    placeOrderUrl: `${ordersApiRoot}`
  })
  const response = {
    statusCode: 200,
    headers: {
      'content-type': 'text/html; charset=UTF-8'
    },
    body: html
  }

  return response
})