module XRay
  # Represents cause section in segment and subsegment document.
  # It records information about application runtime exceptions.
  class Cause
    attr_reader :id
    @@depth = 15

    def initialize(exception: nil, id: nil, remote: false)
      if exception
        @exception_h = normalize e: exception, remote: remote
      end
      @id = id
    end

    def to_h
      return id if id
      h = {
        working_directory: Dir.pwd,
        paths:             Gem.paths.path,
        exceptions:        @exception_h
      }
      h
    end

    def to_json(*args)
      @to_json ||= to_h.to_json(*args)
    end

    private

    def normalize(e:, remote: false)
      exceptions = []
      exceptions << normalize_exception(e: e, remote: remote)

      # don't propagate remote flag
      while e.cause
        exceptions << normalize_exception(e: e.cause)
        e = e.cause
      end

      exceptions
    end

    def normalize_exception(e:, remote: false)
      h = {
        message: e.to_s,
        type:    e.class.to_s
      }
      h[:remote] = true if remote

      backtrace = e.backtrace_locations
      return h unless backtrace

      h[:stack] = backtrace.map do |t|
        {
          path:  t.path,
          line:  t.lineno,
          label: t.label
        }
      end

      h
    end
  end
end
