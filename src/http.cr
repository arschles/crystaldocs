require "http/client"

module HTTPUtils
    extend self
    
    def get(url : String) : HTTP::Client::Response | Nil
        response = HTTP::Client.get url
        if response.status_code == 302
            headers = response.headers
            mb_new_location = headers["Location"]?
            if mb_new_location.nil?
                return nil
            else
                return get(mb_new_location)
            end
        else
            return response
        end
    end
end
