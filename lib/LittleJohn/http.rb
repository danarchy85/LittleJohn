require "net/http"

module LittleJohn
  class HTTP
    def request(endpoint, method, auth = nil, extra_data = Hash.new)
      debug = false

      if debug == true
        puts "Endpoint: #{endpoint}"
        p method
        if auth
          p auth.payload
          p auth.header
        end
        if extra_data.any?
          p extra_data
        end
      end
      
      uri = URI(endpoint)
      req = nil

      if method == 'GET'
        req = Net::HTTP::Get.new(uri)
      elsif method == 'POST'
        req = Net::HTTP::Post.new(uri)
      elsif method == 'PUT'
        req = Net::HTTP::Put.new(uri)
      else
        puts "Invalid method provided: #{method}"
        return false
      end

      data = Hash.new
      if auth
        if ! auth.header['content-type']
          auth.header['content-type'] = 'application/json'
        end

        if ! auth.header['user-agent']
          auth.header['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:68.0)'
        end

        req.initialize_http_header(auth.header)
        data = auth.payload.dup if auth.payload.any?
      end

      data.merge!(extra_data) if extra_data.any?
      req.set_form_data(data) if data.any?
      commit_request(req)
    end

    private
    def commit_request(req)
      response = nil

      begin
        use_ssl = req.uri.port == 443 ? true : false
        Net::HTTP.start(req.uri.host, req.uri.port,
                        :use_ssl => use_ssl) do |http|

          response = http.request(req)

          unless response.kind_of?(Net::HTTPSuccess)
            handle_error(req, response) if response.body !~ /challenge issued/
            break
          end
        end
      rescue
        return JSON.parse("{\"error\":\"Connection Failed\",\"reason\":\"#{req.uri} is unreachable.\"}\n")
      end

      begin
        response.body.empty? ? Hash.new : JSON.parse(response.body)
      rescue
        { 'error' => "Invalid JSON response body",
          'uri'   => req.uri.origin + req.uri.request_uri }
      end
    end

    def handle_error(req, res)
      res.body = "{\"error\":\"#{res.code}:#{res.message}\",\"reason\":\"Authentication failed for: #{req.uri}\"}" if res.message == 'Unauthorized'
      res.body = "{\"error\":\"#{res.code}:#{res.message} #{res.uri}\"}" if res.body.class == String && ! res.body.empty?
      puts RuntimeError.new("#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.uri}\n#{res.body}")
    end
  end
end
