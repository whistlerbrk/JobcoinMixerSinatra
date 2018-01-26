require 'securerandom'
require './jobcoin_api'

class MixRequest < ActiveRecord::Base

  class StateError < StandardError ; end

  # we take a 2 percent fee for our lovely service
  SERVICE_FEE_IN_PCT = 0.02

  # this is the "house account" to which funds are
  # ultimately transferred and disbursed from
  HOUSE_ACCOUNT_ADDRESS = "8b0c6a05dd1f34089a4226b3c67177b8"

  # we don't want to distribute funds unless there is a minimum number of pending transfers
  TRANSFER_THRESHOLD = 5

  # waiting - we're waiting to receive coins
  # received - we've received them and now can distribute
  # distributed - we've disbursed coins and taken our fee
  enum status: [ :waiting, :received, :transferred, :distributed, :failed ]

  # since we're not using postgres for this demo,
  # just serialize the distribution addresses directly
  # as an Array of Strings
  serialize :distribution_addresses, Array

  validates :distribution_addresses, presence: true
  validates :deposit_address, uniqueness: true, allow_nil: true

  before_create :generate_deposit_address

  class << self
    # poll all outstanding mix requests in the
    # waiting state to see if there deposits have arrived
    def await_deposits
      requests = MixRequest.where(status: :waiting)
      puts "awaiting deposits for #{requests.count} requests\n"

      requests.each do |request|
        request.poll_and_update!
      end

      return true
    end

    # transfer to the house account deposits which have been received
    def transfer_deposits
      requests = MixRequest.where(status: :received)

      puts "transfering deposits from #{requests.count} requests\n"

      requests.each do |request|
        request.transfer_to_house!
      end

      return true
    end

    # distribute from the house account to the deposit addresses
    # coins which been transferred to the house account
    def disburse_deposits
      requests = MixRequest.where(status: :transferred)

      if requests.count >= TRANSFER_THRESHOLD

        puts "Distributing funds for #{requests.count} requests\n"

        requests.each do |request|
          request.distribute_funds!
        end

      else
        puts "awaiting #{TRANSFER_THRESHOLD} requests to distribute, currently #{requests.count}\n"
      end

      return true
    end
  end

  # since we're not using a fancy form, just filter out blanks
  def distribution_addresses=(addresses)
    super(addresses.reject(&:blank?))
  end

  # string casted
  def amount
    BigDecimal.new(deposit_amount)
  end

  def amount_less_fee
    amount * (1.0 - SERVICE_FEE_IN_PCT)
  end

  def amount_per_address
    @amount_per_address ||= (amount_less_fee / distribution_addresses.count.to_f)
  end

  def poll_and_update!
    raise StateError unless waiting?

    api_response = JobcoinAPI.address_info(deposit_address)

    # funds are present! advance state, otherwise ignore
    if api_response['balance'] != '0'
      update({ deposit_amount: api_response['balance'], status: :received })
    end
  end

  def transfer_to_house!
    raise StateError unless received?

    api_response = JobcoinAPI.transfer(deposit_address, HOUSE_ACCOUNT_ADDRESS, deposit_amount)

    if api_response['status'] == 'OK'
      update({ status: :transferred })
    else
      # TODO handle failure
      update({ status: :failed })
    end
  end

  def distribute_funds!
    raise StateError unless transferred?

    api_responses = []

    distribution_addresses.each do |address|
      api_responses.push JobcoinAPI.transfer(HOUSE_ACCOUNT_ADDRESS, address, amount_per_address)
    end

    if api_responses.all?{ |r| r['status'] == 'OK' }
      update({ status: :distributed })
    else
      # TODO handle complete / partial failure
      update({ status: :failed })
    end
  end

  private

  # just a random string for convenience
  def generate_deposit_address
    self.deposit_address = SecureRandom.hex
  end
end
