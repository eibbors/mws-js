products = require '../src/products'
# { locales } = require '../src/core'
{ loginInfo, dump, print } = require './cfg'

client = new products.Client(loginInfo)


print 'products Client', client

# Simple service status check
client.getServiceStatus (status, res) =>
	print "Products service status", status
	# Quick verification of optimum service status
	unless status in ['GREEN', 'GREEN_I']
		throw 'Products service is having issues, aborting...'
		
	# client.listMarketplaceParticipations (goodies, res) =>
	# 		print "The good stuff", goodies
	# 		dump res 