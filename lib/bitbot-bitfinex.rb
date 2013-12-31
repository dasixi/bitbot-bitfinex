require 'bitfinex'

module BitBot
  module Bitfinex
    ### INFO ###
    def ticker
      map = {last_price: :last, mid: nil}
      Ticker.new rekey(client.ticker, map)
    end

    #price, amount, timestamp
    def offers
      resp = client.orderbook
      asks = resp['asks'].collect do |offer|
        Offer.new offer
      end
      bids = resp['bids'].collect do |offer|
        Offer.new offer
      end
      {asks: asks, bids: bids}
    end

    def asks
      offers[:asks]
    end

    def bids
      offers[:bids]
    end

    ### TRADES ###
    #{"id"=>4880202, "symbol"=>"btcusd", "exchange"=>nil, "price"=>"1.0", "avg_execution_price"=>"0.0", "side"=>"buy",
    #"type"=>"exchange limit", "timestamp"=>"1388473334.231488559", "is_live"=>true, "is_cancelled"=>false, "was_forced"=>false,
    #"original_amount"=>"0.1", "remaining_amount"=>"0.1", "executed_amount"=>"0.0", "order_id"=>4880202}
    def buy(options)
      amount = options[:amount]
      price = options[:price]
      resp = client.order amount, price, 'exchange limit'
      build_order(resp)
    end

    #{"id"=>4880203, "symbol"=>"btcusd", "exchange"=>nil, "price"=>"10000.0", "avg_execution_price"=>"0.0", "side"=>"sell",
    #"type"=>"exchange limit", "timestamp"=>"1388473337.204447101", "is_live"=>true, "is_cancelled"=>false, "was_forced"=>false,
    #"original_amount"=>"0.1", "remaining_amount"=>"0.1", "executed_amount"=>"0.0", "order_id"=>4880203}
    def sell(options)
      amount = options[:amount]
      price = options[:price]
      resp = client.order (-amount), price, 'exchange limit'
      build_order(resp)
    end

    def cancel(order_id)
      client.cancel order_id
    end

    ### ACCOUNT ###
    def orders
      client.orders.collect do |hash|
        build_order(hash)
      end
    end

    private
    def build_order(hash)
      map = { symbol: nil,
              exchange: nil,
              avg_execution_price: :avg_price,
              type: nil,
              side: :type,
              is_live: nil,
              is_cancelled: nil,
              was_forced: nil,
              original_amount: :amount,
              remaining_amount: :remaining,
              executed_amount: nil,
              order_id: nil
      }
      order = Order.new rekey(hash, map)
      order.type = case order.type
                   when 'buy' then 'bid'
                   when 'sell' then 'ask'
                   else raise "Unexcepted order type: #{order.type}"
                   end
      order.status = if hash['is_live']
                       'open'
                     elsif hash['is_cancelled']
                       'cancelled'
                     else
                       'closed'
                     end
      order
    end

    def client
      @client ||= BitFinex.new @key, @secret
    end
  end
end

BitBot.define :bitfinex, BitBot::Bitfinex
