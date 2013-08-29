mws-js
======

This is a continuation of the continuation of this code.  I have made changes to the
explicit .js files, as I do not use coffee script.  I have fixed some of the bugs with
the feed upload, core file, and FBA API requests.  Note: I have not made any changes to
the .coffee files in this library.

This is a continuation of the unstable branch of https://github.com/eibbors/mws-js .
While having very nice ideas, it was incomplete and a bit buggy.
I needed only the products, orders and feeds APIs, so I have no idea what is the status
of the rest of the apis

I find Node.js an absolute pleasure to work with and made this rough
Marketplace web services client as one of my first projects. I still find it
beats the snot out of PHP, Java, or C# packages Amazon publishes.  
I use it for real-time integration and/or dashboards for e-commerce clients.
Note: there may be tons of bugs since I updated the formatting to be a lot
more user-friendly, but almost all of the documented functions and objects
should work fine and dandy like cotton candy.

Usage
=====

.js Example
-------------
Fetching a product info:
```javascript
var mws = require('./mws-js');
client = new mws.products.Client(loginCredentials);

client.getMatchingProductForId('ASIN', 'B005ISQ7JC', function(res){
  if (res.error) {
    console.error(res.error);
  } else if (res.result) {
    console.log(res.result);
  }
});

```


Coffee Script example
--------------
Fetching a product info:
```
mws = require equire 'mws-js'
client = new mws.products.Client(loginInfo)

client.getMatchingProductForId 'ASIN', ASIN_ID , (res) =>
	if res.error
		console.error res.error
	else if res.result
		console.log util.inspect(res.result,false,10)

```


You can have a look at test directory for more examples.
