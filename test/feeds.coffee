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

	client.getFeedSubmissionList {
		'MaxCount': 3
		'FeedProcessingStatusList': {'_DONE_': true}
		'SubmittedFromDate': '2013-01-01'
		'SubmittedToDate': '2013-12-31'
		# 'FeedTypeList': {'_POST_PRODUCT_PRICING_DATA_': true}
	}, (res) =>
		if res.error
			console.error res.error
		else if res.result
			console.log util.inspect(res.result,false,10)
			res.result.FeedSubmissionInfo = [res.result.FeedSubmissionInfo] unless Array.isArray res.result.FeedSubmissionInfo
			for i,info of res.result.FeedSubmissionInfo when info
				client.getFeedSubmissionResult info.FeedSubmissionId, (res) =>
					if res.error
						console.error res.error
					else if res.response
						console.log util.inspect(res.response,false,10)
