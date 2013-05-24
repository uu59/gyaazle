module Gyaazle
  class Config
    CLIENT_ID = "810975313441.apps.googleusercontent.com"
    CLIENT_SECRET = "0CJJ4jT2jcUsCWDrsHvXmARs"

    attr_reader :id, :secret, :file

    def initialize(file = nil)
      @id = CLIENT_ID
      @secret = CLIENT_SECRET
      @file = file
      dir = File.dirname(@file)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      FileUtils.touch(file) unless File.exists?(file)
    end

    def save(json)
      File.open(file, "w") do |f|
        f.write json.is_a?(String) ? json : MultiJson.dump(json, :pretty => true)
      end
    end

    def update(values)
      save self.load.merge(values)
    end

    def load
      MultiJson.load(File.read(file), :symbolize_keys => true) rescue nil
    end
  end
end
