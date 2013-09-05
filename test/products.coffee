util = require 'util'
products = require '../src/products'
{ loginInfo, dump, print } = require './cfg'

client = new products.Client(loginInfo)


# Simple service status check
client.getServiceStatus (status, res) =>
	print "Products service status", status
	# Quick verification of optimum service status
	unless status in ['GREEN', 'GREEN_I']
		throw 'Products service is having issues, aborting...'
		
	client.getMatchingProductForId 'ASIN', 'B00BY7IZQE' , (res) =>
		if res.error
			console.error res.error
		else if res.result
			console.log util.inspect(res.result,false,10)
		