/**
 * Finances API requests and definitions for Amazon's MWS web services.
 * For information on using, please see examples folder.
 *
 * @author Mark Dickson
 */
var mws = require('./mws');

/**
 * Construct a Finances API request for mws.Client.invoke()
 *
 * @param {String} action Action parameter of request
 * @param {Object} params Schemas for all supported parameters
 */
function FinancesRequest(action, params) {
    var opts = {
        name: 'Finances',
        group: 'Finances',
        path: '/Finances/2015-05-01',
        version: '2015-05-01',
        legacy: false,
        action: action,
        params: params
    };
    return new mws.Request(opts);
}

/**
 * A collection of currently supported request constructors. Once created and
 * configured, the returned requests can be passed to an mws client `invoke` call
 * @type {Object}
 */
var calls = exports.requests = {

    /**
     *
     */
    ListFinancialEvents: function() {
        return new FinancesRequest('ListFinancialEvents', {
            AmazonOrderId: { name: 'AmazonOrderId', required: true }
        });
    }

};