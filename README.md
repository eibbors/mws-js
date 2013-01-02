mws-js
======

I find Node.js an absolute pleasure to work with and made this rough
Marketplace web services client as one of my first projects. I still find it
beats the snot out of PHP, Java, or C# packages Amazon publishes.  
I use it for real-time integration and/or dashboards for e-commerce clients.
Note: there may be tons of bugs since I updated the formatting to be a lot
more user-friendly, but almost all of the documented functions and objects
should work fine and dandy like cotton candy.

Usage
=====

Super simple example
--------------------

I will be creating some sample projects illustrating how to take advantage
of complex/enum params and other more useful features of this library, but
the most basic usage I could come up with goes something like:

```javascript
var mws = require('mws'),
    client = new AmazonMwsClient('accessKeyId', 'secretAccessKey', 'merchantId', {});

// Get the service status of Sellers API endpoint and print it
client.invoke(new mws.sellers.requests.GetServiceStatus(), console.log);

var listOrders = new mws.orders.requests.ListOrders();
listOrders.set('MarketplaceId', 'marketplaceId')
          .set('CreatedAfter', new Date(2,14,2012));
client.invoke(listOrders, function(result) {
  console.log(result);
  // Do something fun with the results...
});
```

It's worth noting that as it is, this code will not work.  This is because the mws object has no "orders" object.  Orders is an included module, representing one of Amazon's APIs.  Other included modules include: products, reports, sellers, and feeds.  You should include the modules you require in the mws-js/lib/mws.js file.  For example, to make the above code work, you would include the "orders.js" module as "orders":

```
exports.orders = require('./orders');
```