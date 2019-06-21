const _ = require('lodash')
const AWSXRay = require('aws-xray-sdk-core')
const AWS = process.env.LAMBDA_RUNTIME_DIR
  ? AWSXRay.captureAWS(require('aws-sdk'))
  : require('aws-sdk')
const kinesis = require('@perform/lambda-powertools-kinesis-client')
const sns = require('@perform/lambda-powertools-sns-client')
const Log = require('@perform/lambda-powertools-logger')
const wrap = require('@perform/lambda-powertools-pattern-basic')

const streamName = process.env.order_events_stream
const topicArn = process.env.restaurant_notification_topic

module.exports.handler = wrap(async (event, context) => {
  const events = context.parsedKinesisEvents
  Log.debug('processing order events', { count: events.length })

  const promises = events
    .filter(evt => evt.eventType === 'order_placed')
    .map(async order => {
      order.logger.debug(
        'notified restaurant of order', 
        { restaurantName: order.restaurantName, orderId: order.orderId})

      const snsReq = {
        Message: JSON.stringify(order),
        TopicArn: topicArn
      };
      await sns.publishWithCorrelationIds(order.correlationIds, snsReq).promise()

      const data = _.clone(order)
      data.eventType = 'restaurant_notified'

      const kinesisReq = {
        Data: JSON.stringify(data), // the SDK would base64 encode this for us
        PartitionKey: order.orderId,
        StreamName: streamName
      }
      await kinesis.putRecordWithCorrelationIds(order.correlationIds, kinesisReq).promise()
      order.logger.debug(`published 'restaurant_notified' event to Kinesis`)
    })

  await Promise.all(promises)
})