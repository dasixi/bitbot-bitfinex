require_relative 'spec_helper'

describe BitBot::Bitfinex do
  describe "calls private APIs" do
    before :all do
      ENV['bitfinex_key'] = 'key'
      ENV['bitfinex_secret'] = 'secret'
    end

    after :all do
      ENV['bitfinex_key'] = nil
      ENV['bitfinex_secret'] = nil
    end

    describe "#buy" do
      it 'bought without enough money' do
        expect{ VCR.use_cassette('authorized/failure/buy'){ BitBot[:bitfinex].new.buy amount: 100, price: 10 } }.to raise_error(BitBot::BalanceError)
      end
    end

    describe "#sell" do
      it 'sold without enough bitcoin' do
        expect{ VCR.use_cassette('authorized/failure/sell'){ BitBot[:bitfinex].new.sell amount: 100, price: 1234 } }.to raise_error(BitBot::BalanceError)
      end
    end

    describe "#cancel and #sync" do
      it 'cancel and sync without an error order id' do
        expect{ VCR.use_cassette('authorized/failure/cancel'){ BitBot[:bitfinex].new.cancel 1 } }.to raise_error(BitBot::Error)
        expect{ VCR.use_cassette('authorized/failure/sync'){ BitBot[:bitfinex].new.sync 1 } }.to raise_error(BitBot::OrderNotFoundError)
      end
    end

    describe "#orders" do
      subject { VCR.use_cassette('authorized/empty/orders'){ BitBot[:bitfinex].new.orders } }

      it "account has no orders" do
        expect(subject.size).to eq(0)
      end
    end
  end
end
