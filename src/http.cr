require "http/client"

module HTTPUtils
    extend self
    
    # TODO: take a block here so that the caller
    # can deal with the HTTP::Client::Response in that block,
    # and still get access to the response's IO
    def get(
        url : String,
        &block : HTTP::Client::Response -> T
    ) : T | Nil forall T
        response = HTTP::Client.get url do |response|
            if response.status_code == 302
                headers = response.headers
                mb_new_location = headers["Location"]?
                if mb_new_location.nil?
                    return nil
                else
                    return get(mb_new_location, &block)
                end
            else
                return block.call(response)
            end
        end
    end
end
