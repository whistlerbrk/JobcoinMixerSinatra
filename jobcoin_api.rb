require 'net/http'

class JobcoinAPI

  API_BASE_URI = "http://jobcoin.gemini.com/antelope/api"

  # GET transaction history from an address
  def self.address_info(address)
    return {"status" => "OK", "balance" => "20.0"} if ENV['RACK_ENV'] == 'test'

    uri = URI.parse("#{API_BASE_URI}/addresses/#{address}")
    raw_response = Net::HTTP.get_response(uri)

    # parse and return response
    JSON.parse(raw_response.body)
  end

  # POST funds between addresses
  def self.transfer(from, to, amount)
    return {"status" => "OK"} if ENV['RACK_ENV'] == 'test'

    uri = URI.parse("#{API_BASE_URI}/transactions")
    params = {
      fromAddress: from,
      toAddress: to,
      amount: amount
    }

    raw_response = Net::HTTP.post_form(uri, params)

    # parse and return response
    JSON.parse(raw_response.body)
  end

end
