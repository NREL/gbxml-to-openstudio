require 'json'

module EPlusOut
  module Models
    module Model
      def to_json(*args)
        to_h.to_json(*args)
      end
    end
  end
end