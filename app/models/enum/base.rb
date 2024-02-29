class Enum::Base
  class << self
    include Enumerable

    def all
      raise NotImplementedError
    end

    def each(&block)
      all.each(&block)
    end

    def to_h
      all.map { |attribute| [attribute, attribute] }.to_h
    end
  end
end
