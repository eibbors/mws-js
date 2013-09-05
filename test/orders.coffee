orders = require '../src/orders'
{ loginInfo, dump, print } = require './cfg'

client = new orders.Client(loginInfo)

# You can uncomment these to log / dump client data as triggered by
# the event system.
# client.on 'request', dump
# client.on 'response', dump
# client.on 'error', console.log 

# Start out by checking the orders service status
client.getServiceStatus (status, res) =>
  print "Orders Service Status", status
  if status isnt 'GREEN'
    print "Abnormal ServiceStatus response", res
    return console.log "aborting..."

  # List orders created after 10-01-2011 which will almost definitely return more than
  # the max number per request. Change this to an older date, if not
  client.listOrders { CreatedAfter: '10-01-2011' }, (orders, res) =>
    if orders 
      if Array.isArray(orders)
        order = orders[0]
        size = orders.length
      else
        order = orders
        size = 1
      print "First order of #{size} returned", order
    else 
      print "Invalid or empty ListOrders response", res
    
    # Sample of requesting more results using NextToken
    if res.nextToken?
      print "Requesting additional orders using formal NextToken request", res.nextToken

      # The formal method is more clear to those reading your code, but... (see callback)
      client.listOrdersByNextToken res.nextToken, (orders, res) =>
        if orders then console.log "Retrieved #{orders.length ? 1} order(s)"
        else print "NextToken response with no orders", res

        # You can also call getNext on any response with NextToken support
        if res.nextToken? 
          res.getNext (orders, res) =>
            "Retrieved #{orders.length ? 1} order(s)"

    # Using the orders from above to issue GetOrder request
    client.getOrder order.AmazonOrderId, (o, res) =>
      print "Order returned by GetOrder", o
      print "Matches order from before", order.AmazonOrderId is o.AmazonOrderId
    
    # Demonstrate the listing of single order's item details
    client.listOrderItems orders[5].AmazonOrderId, (items, res) =>
      print "Order items for #{orders[5].AmazonOrderId} (fifth result from before)", items
      # I don't have any sample data able to trigger this, but the same concept as
      #  above should apply here, as well.
      if res.nextToken?
        res.getNext dump
