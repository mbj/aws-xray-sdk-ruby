require 'aws-xray-sdk/exceptions'

module XRay
  # Metadata are key-value pairs with values of any type, including objects
  # and lists, but that are not indexed. Use metadata to record data
  # you want to store in the trace but don't need to use for searching traces.
  class Metadata
    def initialize(entity)
      @data = {}
      @entity = entity
    end

    def sub_meta(namespace)
      @data[namespace] = SubMeta.new(@entity) unless @data[namespace]
      @data[namespace]
    end

    def to_h
      @data
    end
  end

  # The actual class that stores all data under a certain namespace.
  class SubMeta
    def initialize(entity)
      @data = {}
      @entity = entity
    end

    def [](key)
      @data[key]
    end

    def []=(k, v)
      raise EntityClosedError if @entity.closed?
      @data[k] = v
    end

    def update(h)
      raise EntityClosedError if @entity.closed?
      @data.merge!(h)
    end

    def to_h
      @data
    end

    def to_json(*args)
      @to_json ||= to_h.to_json(*args)
    end
  end

  # Singleton facade metadata class doing no-op for performance
  # in case of not sampled X-Ray entities.
  module FacadeMetadata
    class << self
      def [](key)
        # no-op
      end

      def []=(k, v)
        # no-op
      end

      def update(h)
        # no-op
      end

      def to_h
        # no-op
      end
    end
  end
end
