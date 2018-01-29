require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

def create_request
  MixRequest.create(distribution_addresses: [SecureRandom.hex, SecureRandom.hex, SecureRandom.hex])
end

class MixRequestTest < Test::Unit::TestCase

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    MixRequest.destroy_all

    @requests = []
    (MixRequest::TRANSFER_THRESHOLD - 1).times do
      @requests << create_request
    end
  end

  def test_deposits_are_received
    MixRequest.await_deposits
    assert_equal(@requests.count, MixRequest.where(status: :received).count)
  end

  def test_deposits_are_transferred_to_the_house_account
    MixRequest.await_deposits
    MixRequest.transfer_deposits

    assert_equal(@requests.count, MixRequest.where(status: :transferred).count)
  end

  def test_deposits_are_not_disbursed_until_threshold_is_met
    MixRequest.await_deposits
    MixRequest.transfer_deposits
    MixRequest.disburse_deposits

    assert_equal(0, MixRequest.where(status: :distributed).count)

    last_request = create_request
    last_request.poll_and_update!
    last_request.transfer_to_house!

    MixRequest.disburse_deposits
    assert_equal(MixRequest::TRANSFER_THRESHOLD, MixRequest.where(status: :distributed).count)
  end

end
