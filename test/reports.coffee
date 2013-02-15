reports= require '../src/reports'
# { locales } = require '../src/core'
{ loginInfo, dump, print } = require './cfg'
fs = require 'fs'

client = new reports.Client(loginInfo)
#
# Fetch all reports in files
#
client.getReportList {}, (reportInfoList,res)->
	for reportInfo in reportInfoList
		print "Fetching  report: #{ reportInfo.ReportId } with type: #{ reportInfo.ReportType }"
		do (reportInfo) ->
			client.getReport {ReportId : reportInfo.ReportId }, (report, res)->
				id = reportInfo.ReportId
				file = "report-#{ id }.txt"
				if res?.responseType is 'Error'
					print "failed to fetch report with id : #{ id }"
					print res?.error
					#print res?.responseWithInvalidMD5
				else
					print "Writing #{ report.length } bytes  to #{ file }"
					fs.writeFileSync(file, report)
	if res.nextToken?
		res.getNext()
