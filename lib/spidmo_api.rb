require 'goliath'
require 'em-mongo'
require 'em-http'
require 'em-synchrony/em-http'
require 'goliath/synchrony/mongo_receiver'
#
require 'gorillib'
require 'gorillib/metaprogramming/class_attribute'
require 'yajl/json_gem'

require 'spidmo_api/exception_handler'
require 'spidmo_api/errors'
require 'spidmo_api/plugins/statsd_plugin'

require 'auth_and_rate_limit'
require 'statsd_logger'
