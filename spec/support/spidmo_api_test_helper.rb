module SpidmoApi
  module TestHelper
    DEFAULT_APIKEY = 'WHITELISTED69'
    DEFAULT_ERRBACK = Proc.new{|c| fail "HTTP Request failed #{c.response}" }

    def config_file
      Goliath.root_path('config', 'app.rb')
    end

    def get_api_request query={}, params={}, errback=DEFAULT_ERRBACK, &block
      query.reverse_merge!( :_apikey => DEFAULT_APIKEY )
      params[:query] = query
      get_request(params, errback, &block)
    end

    def get_account apikey, hsh={}
      hsh = hsh.reverse_merge(:valid => true, :max_call_rate => 1e6, :max_ip_rate => 1e6, :max_balance => 1e6, :calls => 0, :balance => 0)
      AccountInfo.new(apikey, hsh).save(db)
    end

    def get_usage_info apikey
      UsageInfo.load(db, apikey)
    end

    def get_request_info query_hsh
      db.first('RequestInfo', query_hsh)
    end

    def db
      @db ||= DirectMongoDb.new
    end

    def should_have_ok_response(c)
      [c.response, c.response_header.status].should == ['Hello from Responder', 200]
    end
  end
end
