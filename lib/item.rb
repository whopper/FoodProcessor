module Foodprocessor
  class Item
    def initialize(params)
      @name = params[:name]
      @required = params[:required]
    end
  end
end
