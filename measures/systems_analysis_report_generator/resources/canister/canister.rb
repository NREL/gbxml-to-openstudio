class Canister
  def initialize
    @stack = []
    @registry = {}
    @resolved = {}
    @dependents = Hash.new do |hash, key|
      hash[key] = []
    end
    yield self if block_given?
  end

  # We override method_missing to enable dot notation
  # for accessing registered values.
  def method_missing(method, *args, &block) # rubocop:disable Style/MethodMissingSuper
    if handles?(method)
      resolve(method)
    else
      super(method, *args, block)
    end
  end

  # We override respond_to? to enable dot notation
  # for accessing registered values.
  def respond_to_missing?(method, include_all = false)
    handles?(method) || super(method, include_all)
  end

  # Register a value to a key by passing a block. Note that
  # the value will be that returned by the block. If the key
  # has been registered before, the old registration is
  # overwritten. Dependents of the original registration
  # are automatically invalidated.
  # @param key [Symbol]
  # @yield self [Container] Yields this container.
  # @return the value defined in the block
  def register(key, &block)
    invalidate(key) if registered?(key)
    registry[key.to_sym] = block
    self
  end

  # Recursively resolves the object that was registered to
  # the key. This value is memoized.
  # @param key [Symbol]
  def resolve(key)
    add_dependent(key)
    stack << key
    value = resolved[key.to_sym] ||= registry[key.to_sym].call(self)
    stack.pop
    value
  end
  alias_method :[], :resolve

  def keys
    registry.keys
  end

  private

  attr_reader :dependents, :registry, :resolved, :stack

  def handles?(method)
    registered?(method)
  end

  def add_dependent(key)
    unless stack.empty?
      dependents[key.to_sym] << stack.last
    end
  end

  def registered?(key)
    registry.key?(key.to_sym)
  end

  def unresolve(key)
    resolved.delete(key.to_sym)
  end

  def invalidate(key, first = true)
    unresolve(key)
    dependents[key.to_sym]
        .each {|child| invalidate(child, false) }
    dependents.delete(key.to_sym) if first
  end
end