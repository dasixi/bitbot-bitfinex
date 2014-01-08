require_relative 'spec_helper'

describe BitBot::Bitfinex do
  describe "public APIs" do
    describe "#tickers" do
      subject { VCR.use_cassette('tickers'){ BitBot[:bitfinex].new.ticker } }

      it 'gets a ticker' do
        expect(subject.last).to eq(888.09)
        expect(subject.converted.last).to eq((888.09 * Settings.rate).round(5))
      end
    end

    describe "#offers" do
      subject { VCR.use_cassette('offers'){ BitBot[:bitfinex].new.offers } }

      it 'gets 10 bids and 10 asks' do
        expect(subject[:asks].size).to eq(10)
        expect(subject[:bids].size).to eq(10)
      end
    end

    describe "#bids" do
      subject { VCR.use_cassette('offers'){ BitBot[:bitfinex].new.bids } }

      it 'gets 10 bids' do
        expect(subject.size).to eq(10)
        expect(subject.first.price).to eq(811.03)
        expect(subject.first.converted.price).to eq((811.03 * Settings.rate).round(5))

        expect(subject.first.amount).to eq(1)
        expect(subject.first.timestamp).to eq(Time.at(1389149516))
      end
    end

    describe "#asks" do
      subject { VCR.use_cassette('offers'){ BitBot[:bitfinex].new.asks } }

      it 'gets 10 bids' do
        expect(subject.size).to eq(10)
        expect(subject.first.price).to eq(819.993)
        expect(subject.first.converted.price).to eq((819.993 * Settings.rate).round(5))

        expect(subject.first.amount).to eq(0.20269)
        expect(subject.first.timestamp).to eq(Time.at(1389149517))
      end
    end
  end
end
