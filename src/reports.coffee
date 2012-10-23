# ----------------------------------------------------------
#  mws-js • reports.coffee • by robbie saunders [eibbors.com]
# ----------------------------------------------------------
# Description Soon
# ----------------------------------------------------------

mws = require("./core")

MWS_REPORTS = new mws.Service
    name: "Reports"
    group: "Reports & Report Scheduling"
    path: "/"
    version: "2009-01-01"
    legacy: true

###
Ojects to represent enum collections used by some request(s)
@type {Object}
###
enums = exports.enums =
  Schedules: ->
    new mws.Enum(["_15_MINUTES_", "_30_MINUTES_", "_1_HOUR_", "_2_HOURS_", "_4_HOURS_", "_8_HOURS_", "_12_HOURS_", "_72_HOURS_", "_1_DAY_", "_2_DAYS_", "_7_DAYS_", "_14_DAYS_", "_15_DAYS_", "_30_DAYS_", "_NEVER_"])

  ReportProcessingStatuses: ->
    new mws.Enum(["_SUBMITTED_", "_IN_PROGRESS_", "_CANCELLED_", "_DONE_", "_DONE_NO_DATA_"])

  ReportOptions: ->
    new mws.Enum(["ShowSalesChannel=true"])

  ReportTypes: ->

types = exports.types = ReportTypes: {}

# // Listing Reports
# '_GET_FLAT_FILE_OPEN_LISTINGS_DATA_': {title: 'Inventory Report', group: 'Listings', format: 'flat', request: true},
# '_GET_MERCHANT_LISTINGS_DATA_BACK_COMPAT_': {title: 'Open Listings Report', group: 'Listings', format: 'flat', request: true},
# '_GET_MERCHANT_LISTINGS_DATA_': {title: 'Merchant Listings Report', group: 'Listings', format: 'flat', request: true},
# '_GET_MERCHANT_LISTINGS_DATA_LITE_': {title: 'Merchant Listings Report - Lite', group: 'Listings', format 'flat', request: true},
# '_GET_MERCHANT_LISTINGS_DATA_LITER_': {title: 'Merchant Listings Report - Liter', group: 'Listings', format 'flat', request: true},
# '_GET_MERCHANT_CANCELLED_LISTINGS_DATA_': {title: 'Canceled Listings Report', group: 'Listings', format: 'flat', request: true},
# '_GET_MERCHANT_LISTINGS_DEFECT_DATA_': {title: 'Quality Listing Report', group: 'Listings', format: 'flat', request: true}
# // General Order Reports
# '_GET_FLAT_FILE_ACTIONABLE_ORDER_DATA_': {title: 'Unshipped Orders Report', group: 'Orders', format: 'flat', request: true},
# '_GET_ORDERS_DATA_': {title: 'Scheduled XML Order Report', group: 'Orders', format: 'xml', schedule: true},
# '_GET_FLAT_FILE_ORDER_REPORT_DATA_': {title: 'Flat File Order Report', group: 'Orders', format: 'flat', request: true},
# '_GET_FLAT_FILE_ORDERS_DATA_': {title: 'Requested or Scheduled Flat File Order Report', group: 'Orders', format: 'flat', schedule: true, request: true},
# '_GET_CONVERGED_FLAT_FILE_ORDER_REPORT_DATA_': {title: 'Flat File Order Report', group: 'Orders', format: 'flat', schedule: true, request: true},
# // Order Tracking Reports
# '_GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_': {title: 'Flat File Orders By Last Update Report', group: 'Orders', format: 'flat', request: true}
# '_GET_FLAT_FILE_ALL_ORDERS_DATA_BY_ORDER_DATE_': { title: 'Flat File Orders By Order Date', group: 'Orders', format: 'flat', request: true } 
# '_GET_XML_ALL_ORDERS_DATA_BY_LAST_UPDATE_': {title: 'XML Orders By Last Update Report', group: 'Orders', format: 'xml', request: true}
# '_GET_XML_ALL_ORDERS_DATA_BY_ORDER_DATE_': { title: 'XML Orders By Order Date', group: 'Orders', format: 'xml', request: true } 
# // Pending Order Reports
# '_GET_FLAT_FILE_PENDING_ORDERS_DATA_': {title: 'Flat File Pending Orders Report', group: 'Orders', format: 'flat', schedule: true, request: true },
# '_GET_PENDING_ORDERS_DATA_': {title: 'XML Pending Orders Report', format: 'xml', schedule: true, request: true },
# '_GET_CONVERGED_FLAT_FILE_PENDING_ORDERS_DATA_': {title: 'Converged Flat File Pending Orders Report', group: 'Orders', format: 'flat', schedule: true, request: true},

###
A collection of currently supported request constructors. Once created and
configured, the returned requests can be passed to an mws client `invoke` call
@type {Object}
###
calls = exports.requests =
  GetReport: ->
    new ReportsRequest("GetReport",
      ReportId:
        name: "ReportId"
        required: true
    )

  GetReportCount: ->
    new ReportsRequest("GetReportCount",
      ReportTypes:
        name: "ReportTypeList.Type"
        list: true

      Acknowledged:
        name: "Acknowledged"
        type: "Boolean"

      AvailableFrom:
        name: "AvailableFromDate"
        type: "Timestamp"

      AvailableTo:
        name: "AvailableToDate"
        type: "Timestamp"
    )

  GetReportList: ->
    new ReportsRequest("GetReportList",
      MaxCount:
        name: "MaxCount"

      ReportTypes:
        name: "ReportTypeList.Type"
        list: true

      Acknowledged:
        name: "Acknowledged"
        type: "Boolean"

      AvailableFrom:
        name: "AvailableFromDate"
        type: "Timestamp"

      AvailableTo:
        name: "AvailableToDate"
        type: "Timestamp"

      ReportRequestIds:
        name: "ReportRequestIdList.Id"
        list: true
    )

  GetReportListByNextToken: ->
    new ReportsRequest("GetReportListByNextToken",
      NextToken:
        name: "NextToken"
        required: true
    )

  GetReportRequestCount: ->
    new ReportsRequest("GetReportRequestCount",
      RequestedFrom:
        name: "RequestedFromDate"
        type: "Timestamp"

      RequestedTo:
        name: "RequestedToDate"
        type: "Timestamp"

      ReportTypes:
        name: "ReportTypeList.Type"
        list: true

      ReportProcessingStatuses:
        name: "ReportProcessingStatusList.Status"
        list: true
        type: enums.ReportProcessingStatuses
    )

  GetReportRequestList: ->
    new ReportsRequest("GetReportRequestList",
      MaxCount:
        name: "MaxCount"

      RequestedFrom:
        name: "RequestedFromDate"
        type: "Timestamp"

      RequestedTo:
        name: "RequestedToDate"
        type: "Timestamp"

      ReportRequestIds:
        name: "ReportRequestIdList.Id"
        list: true

      ReportTypes:
        name: "ReportTypeList.Type"
        list: true

      ReportProcessingStatuses:
        name: "ReportProcessingStatusList.Status"
        list: true
        type: "reports.ReportProcessingStatuses"
    )

  GetReportRequestListByNextToken: ->
    new ReportsRequest("GetReportRequestListByNextToken",
      NextToken:
        name: "NextToken"
        required: true
    )

  CancelReportRequests: ->
    new ReportsRequest("CancelReportRequests",
      RequestedFrom:
        name: "RequestedFromDate"
        type: "Timestamp"

      RequestedTo:
        name: "RequestedToDate"
        type: "Timestamp"

      ReportRequestIds:
        name: "ReportRequestIdList.Id"
        list: true

      ReportTypes:
        name: "ReportTypeList.Type"
        list: true

      ReportProcessingStatuses:
        name: "ReportProcessingStatusList.Status"
        list: true
        type: "reports.ReportProcessingStatuses"
    )

  RequestReport: ->
    new ReportsRequest("RequestReport",
      ReportType:
        name: "ReportType"
        required: true

      MarketplaceIds:
        name: "MarketplaceIdList.Id"
        list: true
        required: false

      StartDate:
        name: "StartDate"
        type: "Timestamp"

      EndDate:
        name: "EndDate"
        type: "Timestamp"

      ReportOptions:
        name: "ReportOptions"
        type: "reports.ReportOptions"
    )

  ManageReportSchedule: ->
    new ReportsRequest("ManageReportSchedule",
      ReportType:
        name: "ReportType"
        required: true

      Schedule:
        name: "Schedule"
        type: "reports.Schedules"
        required: true

      ScheduleDate:
        name: "ScheduleDate"
        type: "Timestamp"
    )

  GetReportScheduleList: ->
    new ReportsRequest("GetReportScheduleList",
      ReportTypes:
        name: "ReportTypeList.Type"
        list: true
    )

  GetReportScheduleListByNextToken: ->
    new ReportsRequest("GetReportScheduleListByNextToken",
      NextToken:
        name: "NextToken"
        required: true
    )

  GetReportScheduleCount: ->
    new ReportsRequest("GetReportScheduleCount",
      ReportTypes:
        name: "ReportTypeList.Type"
        list: true
    )

  UpdateReportAcknowledgements: ->
    new ReportsRequest("UpdateReportAcknowledgements",
      ReportIds:
        name: "ReportIdList.Id"
        list: true
        required: true

      Acknowledged:
        name: "Acknowledged"
        type: "Boolean"
    )