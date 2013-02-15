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


#
# Some example calls 
#
# #Get report count
# client.getReportCount {}, (count, res)->
# 	console.log "Count :" + count
	
# # List all reports 4 result per call , uses NextToken
# client.getReportList {MaxCount : 4}, (reportInfo,res)->
# 	console.log "===================================="
# 	console.log reportInfo
# 	if res.nextToken?
# 		res.getNext()
		
# # List all reports Schedules
# client.getReportScheduleList {}, (reportSchedule,res)->
# 	console.log "===================================="
# 	console.log reportSchedule
# 	if res.nextToken?
# 		res.getNext()

# #Get report schedule count
# client.getReportScheduleCount {}, (count, res)->
# 	console.log "Count: " + count

# # Get report data
# client.getReport {ReportId : '16038618804'}, (report, res)->
# 	file = 'report.txt'
# 	console.log "Writing #{ report.length } bytes  to #{ file }"
# 	require('fs').writeFileSync(file, report)

# # Request report
# client.requestReport {ReportType: '_GET_FLAT_FILE_OPEN_LISTINGS_DATA_', StartDate: '2013-01-01'}, (repReqInfo,res)->
# 	console.log repReqInfo

# # List all reports requests 4 result per call , uses NextToken
# client.getReportRequestList {MaxCount: 4}, (repReqList,res)->
# 	console.log "===================================="
# 	console.log repReqList
# 	if res.nextToken?
# 		res.getNext()

# # Get report requests count
# client.getReportRequestCount {}, (count, res)->
# 	console.log "Count: " +count

# # Cancel all requests
# client.cancelReportRequests {}, (canceledReportReqInfoList, res)->
# 	console.log "Canceled: " , canceledReportReqInfoList

# # Set report as aknowledged
# client.updateReportAcknowledgements {ReportIdList: '16038618804', Acknowledged: true}, (updatedReportInfoList, res)->
# 	console.log "Updated: " , updatedReportInfoList

# #Schedule a report to be generated every day
# client.manageReportSchedule {ReportType: '_GET_ORDERS_DATA_', Schedule: '_1_DAY_'}, (reportSchedules, res)->
# 	console.log "Scheduled: " , reportSchedules
