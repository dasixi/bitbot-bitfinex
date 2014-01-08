require_relative 'spec_helper'

describe BitBot::Bitfinex do
  describe "#initialized without key and secret" do
    subject { BitBot[:bitfinex].new }

    it "doesn't send request and raises UnauthorizedError" do
      expect{ subject.orders }.to raise_error(BitBot::UnauthorizedError)
    end
  end

  describe "calls private APIs with incorrect key and secret" do
    before :all do
      ENV['bitfinex_key'] = 'key'
      ENV['bitfinex_secret'] = 'secret'
    end

    after :all do
      ENV['bitfinex_key'] = nil
      ENV['bitfinex_secret'] = nil
    end

    it "raises UnauthorizedError" do
      expect { VCR.use_cassette('unauthorized/buy'){ BitBot[:bitfinex].new.buy amount: 0.01, price: 833 } }.to raise_error(BitBot::UnauthorizedError)
      expect { VCR.use_cassette('unauthorized/sell'){ BitBot[:bitfinex].new.sell amount: 0.01, price: 799 } }.to raise_error(BitBot::UnauthorizedError)
      expect { VCR.use_cassette('unauthorized/cancel'){ BitBot[:bitfinex].new.cancel 1 } }.to raise_error(BitBot::UnauthorizedError)
      expect { VCR.use_cassette('unauthorized/sync'){ BitBot[:bitfinex].new.sync 1 } }.to raise_error(BitBot::UnauthorizedError)
      expect { VCR.use_cassette('unauthorized/orders'){ BitBot[:bitfinex].new.orders } }.to raise_error(BitBot::UnauthorizedError)
    end
  end
end
