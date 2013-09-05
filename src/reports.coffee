# ----------------------------------------------------------
#  mws-js • reports.coffee • by robbie saunders [eibbors.com]
# ----------------------------------------------------------
# Description Soon
# ----------------------------------------------------------

mws = require "./core"

MWS_REPORTS = new mws.Service
  name: "Reports"
  group: "Reports & Report Scheduling"
  path: "/"
  version: "2009-01-01"
  legacy: true

# Report types
reportTypes =
  # Listing Reports
  '_GET_FLAT_FILE_OPEN_LISTINGS_DATA_':
    title: 'Inventory Report'
    group: 'Listings'
    format: 'flat'
    request: true
  '_GET_MERCHANT_LISTINGS_DATA_BACK_COMPAT_':
    title: 'Open Listings Report'
    group: 'Listings'
    format: 'flat'
    request: true
  '_GET_MERCHANT_LISTINGS_DATA_':
    title: 'Merchant Listings Report'
    group: 'Listings'
    format: 'flat'
    request: true
  '_GET_MERCHANT_LISTINGS_DATA_LITE_':
    title: 'Merchant Listings Report - Lite'
    group: 'Listings'
    format: 'flat'
    request: true
  '_GET_MERCHANT_LISTINGS_DATA_LITER_':
    title: 'Merchant Listings Report - Liter'
    group: 'Listings'
    format: 'flat'
    request: true
  '_GET_CONVERGED_FLAT_FILE_SOLD_LISTINGS_DATA':
    title: 'Sold Listings Report'
    group: 'Listings'
    format: 'flat'
    request: true
  '_GET_MERCHANT_CANCELLED_LISTINGS_DATA_':
    title: 'Canceled Listings Report'
    group: 'Listings'
    format: 'flat'
    request: true
  '_GET_MERCHANT_LISTINGS_DEFECT_DATA_':
    title: 'Quality Listing Report'
    group: 'Listings'
    format: 'flat'
    request: true
  # General Order Reports
  '_GET_FLAT_FILE_ACTIONABLE_ORDER_DATA_':
    title: 'Unshipped Orders Report'
    group: 'Orders'
    format: 'flat'
    request: true
  '_GET_ORDERS_DATA_':
    title: 'Scheduled XML Order Report'
    group: 'Orders'
    format: 'xml'
    schedule: true
  '_GET_FLAT_FILE_ORDER_REPORT_DATA_':
    title: 'Flat File Order Report'
    group: 'Orders'
    format: 'flat'
    request: true
  '_GET_FLAT_FILE_ORDERS_DATA_':
    title: 'Requested or Scheduled Flat File Order Report'
    group: 'Orders'
    format: 'flat'
    schedule: true
    request: true
  '_GET_CONVERGED_FLAT_FILE_ORDER_REPORT_DATA_':
    title: 'Flat File Order Report'
    group: 'Orders'
    format: 'flat'
    schedule: true
    request: true
  # Order Tracking Reports
  '_GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_':
    title: 'Flat File Orders By Last Update Report'
    group: 'Orders'
    format: 'flat'
    request: true
  '_GET_FLAT_FILE_ALL_ORDERS_DATA_BY_ORDER_DATE_':
    title: 'Flat File Orders By Order Date'
    group: 'Orders'
    format: 'flat'
    request: true
  '_GET_XML_ALL_ORDERS_DATA_BY_LAST_UPDATE_':
    title: 'XML Orders By Last Update Report'
    group: 'Orders'
    format: 'xml'
    request: true
  '_GET_XML_ALL_ORDERS_DATA_BY_ORDER_DATE_':
    title: 'XML Orders By Order Date'
    group: 'Orders'
    format: 'xml'
    request: true
  # Pending Order Reports
  '_GET_FLAT_FILE_PENDING_ORDERS_DATA_':
    title: 'Flat File Pending Orders Report'
    group: 'Orders'
    format: 'flat'
    schedule: true
    request: true
  '_GET_PENDING_ORDERS_DATA_':
    title: 'XML Pending Orders Report'
    format: 'xml'
    schedule: true
    request: true
  '_GET_CONVERGED_FLAT_FILE_PENDING_ORDERS_DATA_':
    title: 'Converged Flat File Pending Orders Report'
    group: 'Orders'
    format: 'flat'
    schedule: true
    request: true
  # Performance reports
  '_GET_SELLER_FEEDBACK_DATA_':
    title: 'Flat File Feedback'
    group: 'Performance'
    format: 'flat'
    request: true
  '_GET_AFN_INVENTORY_DATA_':
    title: 'FBA Inventory Report'
    group: 'Fulfillment'
    format: 'flat'
    request: true

###
Ojects to represent enum collections used by some request(s)
@type {Object}
###
enums =
  Schedule: class extends mws.Enum
    constructor: ->
      super("Schedule", ["_15_MINUTES_", "_30_MINUTES_", "_1_HOUR_", "_2_HOURS_", "_4_HOURS_", "_8_HOURS_", "_12_HOURS_", "_72_HOURS_", "_1_DAY_", "_2_DAYS_", "_7_DAYS_", "_14_DAYS_", "_15_DAYS_", "_30_DAYS_", "_NEVER_"], true)

  ReportProcessingStatusList: class extends mws.EnumList
    constructor: ->
      super("ReportTypeList","Status",["_SUBMITTED_", "_IN_PROGRESS_", "_CANCELLED_", "_DONE_", "_DONE_NO_DATA_"], false)

  ReportOptions: class extends mws.Enum
    constructor: ->
      super("ReportOptions", ["ShowSalesChannel=true", "ShowSalesChannel=false"], false)

  RequestableReportType: class extends mws.Enum
    constructor: ->
      reqReportsTypes = ( k for k,v of reportTypes when v.request )
      super("ReportType", reqReportsTypes, true)

  SchedulableReportType: class extends mws.Enum
    constructor: ->
      schedReportsTypes = ( k for k,v of reportTypes when v.schedule )
      super("ReportType", schedReportsTypes, true)

  ReportTypeList: class extends mws.EnumList
    constructor: ->
      reportTypesList = ( k for k,v of reportTypes when v.schedule )
      super("ReportTypeList", "Type", reportTypesList, false)

###
A collection of currently supported request constructors. Once created and
configured, the returned requests can be passed to an mws client `invoke` call
@type {Object}
###
requests =
  RequestReport: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'RequestReport', [
        new enums.RequestableReportType(),
        new mws.Timestamp('StartDate'),
        new mws.Timestamp('EndDate'),
        new enums.ReportOptions(),
        new mws.ParamList('MarketplaceIdList', 'Id'),
      ], {}, null, init

  GetReportRequestList: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReportRequestList', [
        new mws.ParamList('ReportRequestIdList', 'Id'),
        new enums.ReportTypeList(),
        new enums.ReportProcessingStatusList(),
        new mws.Param('MaxCount'),
        new mws.Timestamp('RequestedFromDate')
        new mws.Timestamp('RequestedToDate')
      ], {}, null, init

  GetReportRequestListByNextToken: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReportRequestListByNextToken', [
        new mws.Param('NextToken', true),
      ], {}, null, init

  GetReportRequestCount: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReportRequestCount', [
        new enums.ReportTypeList(),
        new enums.ReportProcessingStatusList(),
        new mws.Timestamp('RequestedFromDate')
        new mws.Timestamp('RequestedToDate')
      ], {}, null, init

  CancelReportRequests: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'CancelReportRequests', [
        new mws.ParamList('ReportRequestIdList', 'Id'),
        new enums.ReportTypeList(),
        new enums.ReportProcessingStatusList(),
        new mws.Timestamp('RequestedFromDate')
        new mws.Timestamp('RequestedToDate')
      ], {}, null, init

  GetReportList: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReportList', [
        new mws.Param('MaxCount'),
        new enums.ReportTypeList(),
        new mws.Bool('Acknowledged'),
        new mws.Timestamp('AvailableFromDate')
        new mws.Timestamp('AvailableToDate')
        new mws.ParamList('ReportRequestIdList', 'Id'),
      ], {}, null, init

  GetReportListByNextToken: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReportListByNextToken', [
        new mws.Param('NextToken', true),
      ], {}, null, init

  GetReportCount: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReportCount', [
        new enums.ReportTypeList(),
        new mws.Bool('Acknowledged'),
        new mws.Timestamp('AvailableFromDate')
        new mws.Timestamp('AvailableToDate')
      ], {}, null, init

  GetReport: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReport', [
        new mws.Param('ReportId', true)
      ], {}, null, init

  ManageReportSchedule: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'ManageReportSchedule', [
        new enums.SchedulableReportType(),
        new enums.Schedule(),
        new mws.Timestamp('ScheduledDate')
      ], {}, null, init

  GetReportScheduleList: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReportScheduleList', [
        new enums.ReportTypeList(),
      ], {}, null, init

  GetReportScheduleListByNextToken: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReportScheduleListByNextToken', [
        new mws.Param('NextToken', true),
      ], {}, null, init

  GetReportScheduleCount: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'GetReportScheduleCount', [
        new enums.ReportTypeList(),
      ], {}, null, init

  UpdateReportAcknowledgements: class extends mws.Request
    constructor: (init) ->
      super MWS_REPORTS , 'UpdateReportAcknowledgements', [
        new mws.ParamList('ReportIdList', 'Id', true),
        new mws.Bool('Acknowledged'),
      ], {}, null, init

# New client class providing more convenient access to service via camelCased
# versions of the request as methods.
class ReportsClient extends mws.Client
  # callback gets (reportReqInfo, res)
  requestReport: (options, cb)->
    req = new requests.RequestReport options
    @invoke  req, {}, (res) =>
      reportReqInfo = res.result?.ReportRequestInfo ? null
      cb reportReqInfo , res

  # callback gets (reportReqInfoList, res)
  getReportRequestList: (options, cb)->
    req = new requests.GetReportRequestList options
    @invoke  req, { nextTokenCall: requests.GetReportRequestListByNextToken, nextTokenCallUseHasNext: true }, (res) =>
      reportReqInfoList = res.result?.ReportRequestInfo ? null
      cb reportReqInfoList, res

  # callback gets (reportReqInfoList, res)
  getReportRequestListByNextToken: (token, cb)->
    req = new requests.GetReportRequestListByNextToken {NextToken: token}
    @invoke  req, { nextTokenCall: requests.GetReportRequestListByNextToken, nextTokenCallUseHasNext: true }, (res) =>
      reportReqInfoList = res.result?.ReportRequestInfo ? null
      cb reportReqInfoList, res

  # Callback function should be (count, res) ->
  getReportRequestCount: (options, cb)->
    req = new requests.GetReportRequestCount options
    @invoke  req, {}, (res) =>
      count = res.result?.Count ? null
      cb count, res

  # callback gets (canceledReportReqInfoList, res)
  cancelReportRequests: (options, cb)->
    req = new requests.CancelReportRequests options
    @invoke  req, {}, (res) =>
      canceledReportReqInfoList = res.result?.ReportRequestInfo ? null
      cb canceledReportReqInfoList, res

  # callback gets (reportInfo, res)
  getReportList: (options, cb)->
    req = new requests.GetReportList options
    @invoke  req, { nextTokenCall: requests.GetReportListByNextToken, nextTokenCallUseHasNext: true }, (res) =>
      reportInfo = res.result?.ReportInfo ? null
      cb reportInfo, res

  getReportListByNextToken: (token, cb)->
    req = new requests.GetReportListByNextToken {NextToken: token}
    @invoke  req, { nextTokenCall: requests.GetReportListByNextToken, nextTokenCallUseHasNext: true }, (res) =>
      reportInfo = res.result?.ReportInfo ? null
      cb reportInfo, res

  # Callback function should be (count, res) ->
  getReportCount: (options, cb)->
    req = new requests.GetReportCount options
    @invoke  req, {}, (res) =>
      count = res.result?.Count ? null
      cb count, res

  # Callback function should be (report, res) ->
  getReport: (options, cb)->
    req = new requests.GetReport options
    @invoke  req, { allowedContentTypes: [ 'application/octet-stream' ] }, (res) =>
      report = res.response
      cb report, res

  # Callback function should be (reportSchedules, res) ->
  manageReportSchedule: (options, cb)->
    req = new requests.ManageReportSchedule options
    @invoke  req, {}, (res) =>
      reportSchedules = res.result?.ReportSchedule ? null
      cb reportSchedules , res

  # Callback function should be (reportSchedule, res) ->
  getReportScheduleList: (options, cb)->
    req = new requests.GetReportScheduleList options
    @invoke  req, { nextTokenCall: requests.GetReportScheduleListByNextToken }, (res) =>
      reportSchedule = res.result?.ReportSchedule ? null
      cb reportSchedule, res

  getReportScheduleListByNextToken: (token, cb)->
    req = new requests.GetReportScheduleListByNextToken {NextToken: token}
    @invoke  req, { nextTokenCall: requests.GetReportScheduleListByNextToken }, (res) =>
      reportSchedule = res.result?.ReportSchedule ? null
      cb reportSchedule, res

  # Callback function should be (count, res) ->
  getReportScheduleCount: (options, cb)->
    req = new requests.GetReportScheduleCount options
    @invoke  req, {}, (res) =>
      count = res.result?.Count ? null
      cb count, res

  # Callback function should be (reportInfo, res) ->
  updateReportAcknowledgements: (options, cb)->
    req = new requests.UpdateReportAcknowledgements options
    @invoke  req, {}, (res) =>
      reportInfo = res.result?.ReportInfo ? null
      cb reportInfo , res

module.exports =
  service: MWS_REPORTS
  enums: enums
  requests: requests
  Client: ReportsClient