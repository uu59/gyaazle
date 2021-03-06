module Gyaazle
  class CLI
    attr_reader :config, :client

    def initialize(argv)
      @argv = argv
      @opts = Trollop.options(@argv) do
        version "Gyaazle #{Gyaazle::VERSION}"
        banner <<TEXT
Gyaazle #{Gyaazle::VERSION}

Upload file(s) to Google Drive.
See https://github.com/uu59/gyaazle for more information.

Usage: #{$0} [options] <file1> <file2> ..

[options] are:
TEXT
        opt :config, "Use config file", :default => File.join(ENV["HOME"], ".gyaazle", "config.json"), :short => :none
        opt :edit, "Edit config file by $EDITOR", :type => :boolean, :default => false
        opt :capture, "Capture screenshot to go upload", :type => :boolean, :default => false, :short => "-c"
        opt :open, "Open uploaded file by browser", :type => :boolean, :default => false
      end
      @config = Config.new(@opts[:config])
      @client = Client.new(@config)
    end

    def run!
      if @opts[:edit]
        edit_config
      else
        check_credentials!

        if @opts[:capture] || @argv.empty?
          @argv = [capture]
        end

        upload
      end
    end

    def upload
      @argv.each do |file|
        fileobj = client.upload(file)
        puts "#{file}:"
        puts "  * url: #{fileobj[:alternateLink]}"
        puts "  * download: #{fileobj[:downloadUrl]}"
        puts "  * deep link: https://drive.google.com/uc?export=view&id=#{fileobj[:id]}"
        puts
        if @opts[:open]
          Launchy.open fileobj[:alternateLink]
        end
        client.set_permissions(fileobj[:id])
      end
    end

    def capture
      tmpfile = "/tmp/gyaazle_capture_#{Time.now.strftime("%F %T")}.png"
      system capture_cmd(tmpfile)
      tmpfile
    end

    def edit_config
      tmpfile = Tempfile.new("gyaazle-")
      tmpfile.close
      FileUtils.cp(config.file, tmpfile.path)
      system(ENV["EDITOR"], tmpfile.path)
      begin
        MultiJson.load File.read(tmpfile.path)
        FileUtils.cp(tmpfile.path, config.file)
      rescue MultiJson::LoadError => e
        $stderr.puts e.message
        $stderr.puts "Does not saved"
      end
    end

    def initialize_tokens(verifier = nil)
      tokens = client.get_tokens(verifier || authorize)
      config.save(tokens)
      tokens
    end

    def authorize
      puts "Open this link by your browser, and authorize"
      puts client.authorize_url
      print "Paste code here: "
      STDIN.gets.strip
    end

    def check_credentials!
      if config.load.nil? || config.load[:refresh_token].nil?
        initialize_tokens(authorize)
      else
        client.refresh_token!
      end
    end

    private

    def capture_cmd(save_to)
      case RUBY_PLATFORM
        when /darwin/
          "screencapture -i '#{save_to}'"
        else
          case
          when system('which import > /dev/null')
            "import '#{save_to}'"
            
          when system('which gm > /dev/null')
            "gm import '#{save_to}'"

          else
            raise "You should install ImageMagick or GraphicsMagick "
          end
      end
    end
  end
end
