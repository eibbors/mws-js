/**
 * Orders API requests and definitions for Amazon's MWS web services.
 * For information on using, please see examples folder.
 * 
 * @author Robert Saunders
 */
var mws = require('./mws');

/**
 * Construct an Orders API request for mws.Client.invoke()
 * 
 * @param {String} action Action parameter of request
 * @param {Object} params Schemas for all supported parameters
 */
function OrdersRequest(action, params) {
	var opts = {
		name: 'Orders',
		group: 'Order Retrieval',
		path: '/Orders/2011-01-01',
		version: '2011-01-01',
		legacy: false,
		action: action,
		params: params
	};
	return new mws.Request(opts);
}

/**
 * Ojects to represent enum collections used by some request(s)
 * @type {Object}
 */
var enums = exports.enums = {

	FulfillmentChannels:  function() { 
		return new mws.Enum(['AFN', 'MFN']); 
	},

	OrderStatuses:  function() { 
		return new mws.Enum(['Pending', 'Unshipped', 'PartiallyShipped', 'Shipped', 'Canceled', 'Unfulfillable']);
	},

	PaymentMethods:  function() { 
		return new mws.Enum(['COD', 'CVS', 'Other']);
	}

};

/**
 * Contains brief definitions for unique data type values.
 * Can be used to explain input/output to users via tooltips, for example
 * @type {Object}
 */
var types = exports.types = {

	FulfillmentChannel: {
		'AFN':'Amazon Fulfillment Network', 
		'MFN':'Merchant\'s Fulfillment Network' },

	OrderStatus: {
		'Pending':'Order placed but payment not yet authorized. Not ready for shipment.', 
		'Unshipped':'Payment has been authorized. Order ready for shipment, but no items shipped yet. Implies PartiallyShipped.', 
		'PartiallyShipped':'One or more (but not all) items have been shipped. Implies Unshipped.',
		'Shipped':'All items in the order have been shipped.', 
		'Canceled':'The order was canceled.',
		'Unfulfillable':'The order cannot be fulfilled. Applies only to Amazon-fulfilled orders not placed on Amazon.' },

	PaymentMethod: {
		'COD':'Cash on delivery',
		'CVS':'Convenience store payment',
		'Other':'Any payment method other than COD or CVS' },

	ServiceStatus: {
		'GREEN':'The service is operating normally.',
		'GREEN_I':'The service is operating normally + additional info provided',
		'YELLOW':'The service is experiencing higher than normal error rates or degraded performance.',
		'RED':'The service is unabailable or experiencing extremely high error rates.' },

	ShipServiceLevelCategory: {
		'Expedited':'Expedited shipping',
		'NextDay':'Overnight shipping',
		'SecondDay':'Second-day shipping',
		'Standard':'Standard shipping' }

};

/**
 * A collection of currently supported request constructors. Once created and 
 * configured, the returned requests can be passed to an mws client `invoke` call
 * @type {Object}
 */
var calls = exports.requests = {

	/**
	 * Requests the operational status of the Orders API section.
	 */
	GetServiceStatus: function() {
		return new OrdersRequest('GetServiceStatus', {});
	},

	/**
	 * Returns orders created or updated during a time frame you specify.
	 */
	ListOrders: function() {
		return new OrdersRequest('ListOrders', { 
            CreatedAfter: { name: 'CreatedAfter', type: 'Timestamp' },
            CreatedBefore: { name: 'CreatedBefore', type: 'Timestamp' },
            LastUpdatedAfter: { name: 'LastUpdatedAfter', type: 'Timestamp' },
            MarketplaceId: { name: 'MarketplaceId.Id', list: true, required: true },
            LastUpdatedBefore: { name: 'LastUpdatedBefore', type: 'Timestamp' },
            OrderStatus: { name: 'OrderStatus.Status', type: 'orders.OrderStatuses', list: true },
            FulfillmentChannel: { name: 'FulfillmentChannel.Channel', type: 'orders.FulfillmentChannels', list: true },
            PaymentMethod: { name: 'PaymentMethod.Method', type: 'orders.PaymentMethods', list: true },
            BuyerEmail: { name: 'BuyerEmail' },
            SellerOrderId: { name: 'SellerOrderId' },
            MaxResultsPerPage: { name: 'MaxResultsPerPage' }
        });
	},

	/**
	 * Returns the next page of orders using the NextToken parameter.
	 */
	ListOrdersByNextToken: function() {
		return new OrdersRequest('ListOrdersByNextToken', { 
			NextToken: { name: 'NextToken', required: true } 
		});
	},

	/**
	 * Returns orders based on the AmazonOrderId values that you specify.
	 */
    GetOrder: function() {
		return new OrdersRequest('GetOrder', { 
			AmazonOrderId: { name: 'AmazonOrderId.Id', required: true, list: true } 
		});
    },

    /**
     * Returns order items based on the AmazonOrderId that you specify.
     */
    ListOrderItems: function() {
		return new OrdersRequest('ListOrderItems', { 
			AmazonOrderId: { name: 'AmazonOrderId', required: true } });
    },

    /**
     * Returns the next page of order items using the NextToken parameter.
     */
    ListOrderItemsByNextToken: function() {
		return new OrdersRequest('ListOrderItemsByNextToken', { 
			NextToken: { name: 'NextToken', required: true } 
		});
    }

};