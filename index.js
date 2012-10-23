// Pull in our core mws-js module
var mws = require('./lib/core');

// Pull in each of the the individual API modules
mws.fba = require('./lib/fba');
mws.feeds = require('./lib/feeds');
mws.orders = require('./lib/orders');
mws.products = require('./lib/products');
mws.reports = require('./lib/reports');
mws.sellers = require('./lib/sellers');

var util = require('util');
console.log(util.inspect(mws));

// console.log(util.inspect(mws.orders.requests));