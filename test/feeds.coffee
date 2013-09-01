util = require 'util'
feeds = require '../src/feeds'
{ loginInfo, dump, print } = require './cfg'

client = new feeds.Client(loginInfo)


# Simple service status check
client.getServiceStatus (status, res) =>
	print "Feeds service status", status
	# Quick verification of optimum service status
	unless status in ['GREEN', 'GREEN_I']
		throw 'Feeds service is having issues, aborting...'

	# client.getFeedSubmissionCount ['_POST_PRODUCT_DATA_'], '_IN_PROGRESS_', '2013-08-01', '2013-08-31', (res) =>
	# 	if res.error
	# 		console.error res.error
	# 	else if res.result
	# 		console.log util.inspect(res.result,false,10)

	client.getFeedSubmissionList {
		'MaxCount': 30
		'FeedTypeList': [{'_POST_PRODUCT_DATA_': true}]
	}, (res) =>
		if res.error
			console.error res.error
		else if res.result
			console.log util.inspect(res.result,false,10)
		