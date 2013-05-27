# -- coding: utf-8

require "spec_helper"

describe Gyaazle::CLI do
  let(:cli) { Gyaazle::CLI.new([]) }

  describe "#run!" do
    it "invoke #capture when ARGV is empty" do
      cli.stub(:check_credentials!)
      cli.stub(:upload)
      cli.should_receive(:capture)
      cli.run!
    end

    describe "options" do
      context "-e" do
        let(:cli) { Gyaazle::CLI.new(%w!-e!) }
        before do
          cli.stub(:edit_config)
        end

        it "invoke #edit_config" do
          cli.should_receive(:edit_config)
          cli.run!
        end

        it "not invoke #upload and #check_credentials!" do
          cli.should_not_receive(:check_credentials!)
          cli.should_not_receive(:upload)
          cli.run!
        end
      end

      context "--config filepath" do
        let(:file) { File.join("/tmp", rand.to_s) }
        let(:cli) { Gyaazle::CLI.new(%W!--config #{file}!) }

        it "config.file == file" do
          cli.config.file.should == file
          File.unlink(file) if File.exists?(file)
        end
      end

      context "--capture" do
        let(:cli) { Gyaazle::CLI.new(%W!--capture!) }
        before do
          cli.stub(:check_credentials!)
          cli.stub(:upload)
        end

        it "invoke #capture" do
          cli.should_receive(:capture)
          cli.run!
        end
      end
    end
  end

  describe "#check_credentials!" do
    let(:verifier) { "verification code" }

    before do
      cli.stub(:authorize).and_return(verifier)
    end

    context "when config is nil" do
      before do
        cli.config.stub(:load).and_return(nil)
      end

      it "invoke #initialize_tokens" do
        cli.should_receive(:initialize_tokens).with(verifier)
        cli.check_credentials!
      end
    end

    context "when config is broken" do
      before do
        cli.config.stub(:load).and_return(:foo => :bar)
      end

      it "invoke #initialize_tokens" do
        cli.should_receive(:initialize_tokens).with(verifier)
        cli.check_credentials!
      end
    end

    context "when config is fine" do
      before do
        cli.config.stub(:load).and_return(:client_id => "id", :client_secret => "secret", :refresh_token => "refresh")
      end

      it "invoke client#refresh_token!" do
        cli.client.should_receive(:refresh_token!)
        cli.check_credentials!
      end
    end
  end

  describe "#initialize_tokens" do
    let(:token) { {:foo => 1, :bar => 44} }

    it "save response to config file" do
      cli.client.stub(:get_tokens).and_return(token)
      cli.initialize_tokens("code")
      cli.config.load.should == token
    end
  end

  describe "#upload" do
    let(:files) { %w!foo.jpg! }
    let(:cli) { Gyaazle::CLI.new(files) }

    before do
      cli.stub(:check_credentials!)

      @orig_stdout = $stdout
      $stdout = File.new("/dev/null", "w")
    end

    after do
      $stdout = @orig_stdout
    end

    it "invoke client.upload" do
      cli.client.should_receive(:upload).with(files.first).and_return(:alternateLink => "dummy")
      cli.client.should_receive(:set_permissions)
      cli.upload
    end
  end

  describe "#edit_config" do
    let(:conf) { "dummy_config_file" }
    let(:cli) { Gyaazle::CLI.new(%W!-e --config #{conf}!) }

    it "invoke #system with $EDITOR" do
      cli.should_receive(:system).at_least(1).with(ENV["EDITOR"], anything)
      cli.edit_config
      File.unlink(conf) if File.exists?(conf)
    end
  end

  describe "#capture" do
    let(:cli) { Gyaazle::CLI.new(%W!--capture!) }
    let(:cmd) { "my-capture-cmd tmpfile" }

    before do
      cli.stub(:capture_cmd).and_return(cmd)
    end

    it "invoke #system with #capture_cmd" do
      cli.should_receive(:system).with(cmd)
      cli.capture
    end
  end
end

