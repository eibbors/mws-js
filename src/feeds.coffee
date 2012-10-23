



mws = require("./core")


MWS_FEEDS = new mws.Service
    name: "Feeds"
    group: "Feeds"
    path: "/"
    version: "2009-01-01"
    legacy: true


enums = exports.enums =
  FeedProcessingStatus: ->
    new mws.Enum(["_SUBMITTED_", "_IN_PROGRESS_", "_CANCELLED_", "_DONE_"])


types = 

  FeedTypes: ->
    XML: [
      '_POST_PRODUCT_DATA_'
      '_POST_PRODUCT_RELATIONSHIP_DATA_'
      '_POST_ITEM_DATA_'
      '_POST_PRODUCT_OVERRIDES_DATA_'
      '_POST_PRODUCT_IMAGE_DATA_'
      '_POST_PRODUCT_PRICING_DATA_'
      '_POST_INVENTORY_AVAILABILITY_DATA_'
      '_POST_ORDER_ACKNOWLEDGEMENT_DATA_'
      '_POST_ORDER_FULFILLMENT_DATA_'
      '_POST_FULFILLMENT_ORDER_REQUEST_DATA_'
      '_POST_FULFILLMENT_ORDER_CANCELLATION_REQUEST_DATA_'
      '_POST_PAYMENT_ADJUSTMENT_DATA_' 
    ]
    Flat: [
      '_POST_FLAT_FILE_LISTINGS_DATA_'
      '_POST_FLAT_FILE_ORDER_ACKNOWLEDGEMENT_DATA_'
      '_POST_FLAT_FILE_FULFILLMENT_DATA_'
      '_POST_FLAT_FILE_PAYMENT_ADJUSTMENT_DATA_'
      '_POST_FLAT_FILE_INVLOADER_DATA_'
      '_POST_FLAT_FILE_CONVERGENCE_LISTINGS_DATA_'
      '_POST_FLAT_FILE_BOOKLOADER_DATA_'
      '_POST_FLAT_FILE_PRICEANDQUANTITYONLY_UPDATE_DATA_'
    ]
    Other: [
      '_POST_UIEE_BOOKLOADER_DATA_'
    ]
          # }    new mws.Enum(["_POST_PRODUCT_DATA_", "_POST_PRODUCT_RELATIONSHIP_DATA_", "_POST_ITEM_DATA_", "_POST_PRODUCT_OVERRIDES_DATA_", "_POST_PRODUCT_IMAGE_DATA_", "_POST_PRODUCT_PRICING_DATA_", "_POST_INVENTORY_AVAILABILITY_DATA_", "_POST_ORDER_ACKNOWLEDGEMENT_DATA_", "_POST_ORDER_FULFILLMENT_DATA_", "_POST_FULFILLMENT_ORDER_REQUEST_DATA_", "_POST_FULFILLMENT_ORDER_CANCELLATION", "_POST_PAYMENT_ADJUSTMENT_DATA_", "_POST_INVOICE_CONFIRMATION_DATA_", "_POST_FLAT_FILE_LISTINGS_DATA_", "_POST_FLAT_FILE_ORDER_ACKNOWLEDGEMENT_DATA_", "_POST_FLAT_FILE_FULFILLMENT_DATA_", "_POST_FLAT_FILE_FBA_CREATE_INBOUND_SHIPMENT_", "_POST_FLAT_FILE_FBA_UPDATE_INBOUND_SHIPMENT_", "_POST_FLAT_FILE_PAYMENT_ADJUSTMENT_DATA_", "_POST_FLAT_FILE_INVOICE_CONFIRMATION_DATA_", "_POST_FLAT_FILE_INVLOADER_DATA_", "_POST_FLAT_FILE_CONVERGENCE_LISTINGS_DATA_", "_POST_FLAT_FILE_BOOKLOADER_DATA_", "_POST_FLAT_FILE_LISTINGS_DATA_", "_POST_FLAT_FILE_PRICEANDQUANTITYONLY", "_POST_UIEE_BOOKLOADER_DATA_"])


###
A collection of currently supported request constructors. Once created and
configured, the returned requests can be passed to an mws client `invoke` call
@type {Object}
###
calls = exports.requests =
  CancelFeedSubmissions: ->
    new FeedsRequest("CancelFeedSubmissions",
      FeedSubmissionIds:
        name: "FeedSubmissionIdList.Id"
        list: true
        required: false

      FeedTypes:
        name: "FeedTypeList.Type"
        list: true

      SubmittdFrom:
        name: "SubmittedFromDate"
        type: "Timestamp"

      SubmittedTo:
        name: "SubmittedToDate"
        type: "Timestamp"
    )

  GetFeedSubmissionList: ->
    new FeedsRequest("GetFeedSubmissionList",
      FeedSubmissionIds:
        name: "FeedSubmissionIdList.Id"
        list: true
        required: false

      MaxCount:
        name: "MaxCount"

      FeedTypes:
        name: "FeedTypeList.Type"
        list: true

      FeedProcessingStatuses:
        name: "FeedProcessingStatusList.Status"
        list: true
        type: "bde.FeedProcessingStatuses"

      SubmittedFrom:
        name: "SubmittedFromDate"
        type: "Timestamp"

      SubmittedTo:
        name: "SubmittedToDate"
        type: "Timestamp"
    )

  GetFeedSubmissionListByNextToken: ->
    new FeedsRequest("GetFeedSubmissionListByNextToken",
      NextToken:
        name: "NextToken"
        required: true
    )

  GetFeedSubmissionCount: ->
    new FeedsRequest("GetFeedSubmissionCount",
      FeedTypes:
        name: "FeedTypeList.Type"
        list: true

      FeedProcessingStatuses:
        name: "FeedProcessingStatusList.Status"
        list: true
        type: "bde.FeedProcessingStatuses"

      SubmittedFrom:
        name: "SubmittedFromDate"
        type: "Timestamp"

      SubmittedTo:
        name: "SubmittedToDate"
        type: "Timestamp"
    )

  GetFeedSubmissionResult: ->
    new FeedsRequest("GetFeedSubmissionResult",
      FeedSubmissionId:
        name: "FeedSubmissionId"
        required: true
    )

  SubmitFeed: ->
    new FeedsRequest("SubmitFeed",
      FeedContents:
        name: "_BODY_"
        required: true

      FeedType:
        name: "FeedType"
        required: true

      MarketplaceIds:
        name: "MarketplaceIdList.Id"
        list: true
        required: false

      PurgeAndReplace:
        name: "PurgeAndReplace"
        required: false
        type: "Boolean"
    )