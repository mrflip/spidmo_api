#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '../lib/boot')
require 'rack/utils'
require File.join(File.dirname(__FILE__), '../lib/spidmo_api')
require 'spidmo_api'

# Searches twitter, decorates with infochimps' trstrank API
#
# Usage:
#   ruby ./app/infochimps_decorator.rb -sv --config=$PWD/config/app.rb -p 9002
#
class InfochimpsDecorator < Goliath::API
  include Rack::Utils
  #
  use Goliath::Rack::Heartbeat                     # respond to /status with 200, OK (monitoring, etc)
  use Goliath::Rack::Tracer, 'X-Tracer'            # log trace statistics
  use Goliath::Rack::Params                        # parse & merge query and body parameters
  #
  # use SpidmoApi::ExceptionHandler                   # catch errors and present as non-200 responses
  use Goliath::Rack::StatsdLogger, 'spidmo_api'      # send request logs to statsd
  # use Goliath::Rack::AsyncAroundware, AuthReceiver, 'api_auth_db'
  #
  plugin Goliath::Plugin::StatsdPlugin             # send internal stats to statsd

  # Pass the request on to host given in config[:forwarder]
  def response(env)
    env.trace :response_beg

    result_set = fetch_twitter_search(env.params['q'])

    fetch_trstrank(result_set)
    
    body = JSON.pretty_generate(result_set)

    env.trace :response_end
    [200, {}, body]
  end

  def fetch_twitter_search term
    encoded_term = escape(term)
    url =  "http://localhost:9003/search.json?q=#{encoded_term}" #  "http://search.twitter.com/search.json?q=#{encoded_term}"
    resp = EM::HttpRequest.new(url).get(params)
    JSON.parse(resp.response)
  end

  def fetch_trstrank result_set
    apikey = 'flip69' # config[:infochimps_apikey]

    multi = EM::Synchrony::Multi.new
    result_set['results'].each do |result|
      handle = escape(result['from_user'])
      url = "http://api.infochimps.com/social/network/tw/influence/trstrank?_apikey=#{apikey}&screen_name=#{handle}"
      multi.add handle, EM::HttpRequest.new(url).get(params)
    end
    multi.perform

    result_set['results'].each do |result|
      handle = escape(result['from_user'])
      resp = multi.responses[:callback][handle] or next
      result['trstrank'] = JSON.parse(resp.response)    
    end
  end
  
end
