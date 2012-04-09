/**
 * Sellers API requests and definitions for Amazon's MWS web services.
 * For information on using, please see examples folder.
 * 
 * @author Robert Saunders
 */
var mws = require('./mws');

/**
 * Construct a Sellers API request for mws.Client.invoke()
 * 
 * @param {String} action Action parameter of request
 * @param {Object} params Schemas for all supported parameters
 */
function SellersRequest(action, params) {
    var opts = {
        name: 'Sellers',
        group: 'Sellers Retrieval',
        path: '/Sellers/2011-07-01',
        version: '2011-07-01',
        legacy: false,
        action: action,
        params: params
    };
    return new mws.Request(opts);
}

/**
 * Contains brief definitions for unique data type values.
 * Can be used to explain input/output to users via tooltips, for example
 * @type {Object}
 */
var types = exports.types = {

    ServiceStatus: {
        'GREEN':'The service is operating normally.',
        'GREEN_I':'The service is operating normally + additional info provided',
        'YELLOW':'The service is experiencing higher than normal error rates or degraded performance.',
        'RED':'The service is unabailable or experiencing extremely high error rates.' }

};

/**
 * A collection of currently supported request constructors. Once created and 
 * configured, the returned requests can be passed to an mws client `invoke` call
 * @type {Object}
 */
var calls = exports.requests = {

    /**
     * Requests the operational status of the Sellers API section.
     */
    GetServiceStatus: function() {
        return new SellersRequest('GetServiceStatus', {});
    },

    ListMarketplaceParticipations: function() {
        return new SellersRequest('ListMarketplaceParticipations', {});
    },

    ListMarketplaceParticipationsByNextToken: function() {
        return new SellersRequest('ListMarketplaceParticipationsByNextToken', {
            NextToken: { name: 'NextToken', required: true }
        });
    }

};