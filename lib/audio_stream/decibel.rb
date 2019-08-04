module AudioStream
  class Decibel
    def initialize(db: nil, mag: nil)
      @db = db
      @mag = mag
    end

    def db
      @db || 20 * Math.log10(@mag)
    end

    def mag
      @mag || 10 ** (@db / 20.0)
    end

    def self.db(db)
      new(db: db)
    end

    def self.mag(mag)
      new(mag: mag)
    end
  end
end
