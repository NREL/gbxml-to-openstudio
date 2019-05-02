require 'json'

class JSONable
  def to_hash
    instance_variables.map do |iv|
      value = instance_variable_get(:"#{iv}")
      [
          iv.to_s[1..-1], # name without leading `@`
          case value
          when JSONable then value.to_hash # Base instance? convert deeply
          when Array # Array? convert elements
            value.map do |e|
              e.respond_to?(:to_hash) ? e.to_hash : e
            end
          else value # seems to be non-convertable, put as is
          end
      ]
    end.to_h
  end
end