require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class MixRequestStateTest < Test::Unit::TestCase

  def waiting_state_can_not_transfer
    assert_raises(MixRequest::StateError) do
      mix_requests(:waiting).transfer_to_house!
    end
  end

  def waiting_state_can_not_distribute
    assert_raises(MixRequest::StateError) do
      mix_requests(:waiting).distribute_funds!
    end
  end

  def received_state_can_not_receive
    assert_raises(MixRequest::StateError) do
      mix_requests(:received).poll_and_update!
    end
  end

  def received_state_can_not_distribute
    assert_raises(MixRequest::StateError) do
      mix_requests(:received).distribute_funds!
    end
  end

  def transferred_state_can_not_receive
    assert_raises(MixRequest::StateError) do
      mix_requests(:transferred).poll_and_update!
    end
  end

  def transferred_state_can_not_transfer
    assert_raises(MixRequest::StateError) do
      mix_requests(:transferred).transfer_to_house!
    end
  end

end
