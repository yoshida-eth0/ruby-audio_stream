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
      if self===db
        db
      else
        new(db: db.to_f)
      end
    end

    def self.mag(mag)
      if self===mag
        mag
      else
        new(mag: mag.to_f)
      end
    end
  end
end
