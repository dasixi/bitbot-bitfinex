require 'bitfinex'

module BitBot
  module Bitfinex
    ### INFO ###
    def ticker
      client.ticker
    end

    def asks
      client.orderbook['asks']
    end

    def bids
      client.orderbook['bids']
    end

    ### TRADES ###

    def buy(options)
      amount = options[:amount]
      price = options[:price]
      client.order amount, price, 'exchange limit'
    end

    def sell(options)
      amount = options[:amount]
      price = options[:price]
      client.order (-amount), price, 'exchange limit'
    end

    def cancel(order_id)
      client.cancel order_id
    end

    ### ACCOUNT ###
    def orders
      client.orders
    end

    private
    def client
      @client ||= BitFinex.new @key, @secret
    end
  end
end

BitBot.define :bitfinex, BitBot::Bitfinex
