mws-js
======

Complete Amazon marketplace web services client for Node.js.  This project is still a work in progress, not all interfaces are fully tested and working.

Usage
=====

config
------
```javascript
loginInfo = {
  locale: 'US',
  merchantId: 'XXXXXXX',
  marketplaceId: 'XXXXXXX',
  accessKeyId: 'XXXXXXX',
  secretAccessKey: 'XXXXX'
}

```

.js Example
-------------
Fetching a product info:
```javascript
var mws = require('mws-js');
var client = new mws.products.Client(loginInfo);

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
