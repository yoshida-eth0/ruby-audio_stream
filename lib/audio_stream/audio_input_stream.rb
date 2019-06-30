module AudioStream
  module AudioInputStream
    include Enumerable

    def stream
      Rx::Observable.create do |observer|
        each {|buf|
          observer.on_next(buf)
        }
        observer.on_completed
      end.publish
    end
  end
end
