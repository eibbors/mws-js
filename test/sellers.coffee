sellers = require '../src/sellers'
{ loginInfo, dump, print } = require './cfg'

client = new sellers.Client(loginInfo)

# print 'Sellers Client', client

# Simple service status check
client.getServiceStatus (status, res) =>
	print "Sellers service status", status
	# Quick verification of optimum service status
	unless status in ['GREEN', 'GREEN_I']
		throw 'Seller service is having issues, aborting...'
		
	client.listMarketplaceParticipations (goodies, res) =>
			print "The good stuff", goodies
			dump res 