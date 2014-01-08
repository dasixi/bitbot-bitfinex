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
      subject { VCR.use_cassette('authorized/success/buy'){ BitBot[:bitfinex].new.buy amount: 0.01, price: 822 } }

      it 'bought 0.01 bitcoin at price USD 822' do
        expect(subject.side).to eq('buy')
        expect(subject.price).to eq(822.0)
        expect(subject.amount).to eq(0.01)
        expect(subject.remaining).to eq(0.01)
        expect(subject.status).to eq('open')
      end
    end

    describe "#sell" do
      subject { VCR.use_cassette('authorized/success/sell'){ BitBot[:bitfinex].new.sell amount: 0.01, price: 788 } }

      it 'sold 0.01 bitcoin at price USD 788' do
        expect(subject.side).to eq('sell')
        expect(subject.price).to eq(788.0)
        expect(subject.amount).to eq(0.01)
        expect(subject.remaining).to eq(0.01)
        expect(subject.status).to eq('open')
      end
    end

    describe "#cancel and #sync" do
      subject { VCR.use_cassette('authorized/success/cancel'){ BitBot[:bitfinex].new.cancel 5263705 } }

      it 'cancelled an order' do
        expect(subject).to eq(true)
      end
    end

    describe "#sync" do
      subject { VCR.use_cassette('authorized/success/sync'){ BitBot[:bitfinex].new.sync 5263705 } }

      it 'updated an order status' do
        expect(subject.side).to eq('sell')
        expect(subject.price).to eq(1000.0)
        expect(subject.amount).to eq(0.01)
        expect(subject.remaining).to eq(0.01)
        expect(subject.status).to eq('cancelled')
      end
    end

    describe "#orders" do
      subject { VCR.use_cassette('authorized/success/orders'){ BitBot[:bitfinex].new.orders } }

      it 'fetched all account orders' do
        expect(subject.size).to eq(3)
        expect(subject.first.side).to eq('buy')
        expect(subject.first.price).to eq(123.0)
        expect(subject[1].side).to eq('buy')
        expect(subject[1].price).to eq(234.0)
        expect(subject.last.side).to eq('sell')
        expect(subject.last.price).to eq(1234.0)
      end
    end
  end
end
