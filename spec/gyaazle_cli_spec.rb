# -- coding: utf-8

require "spec_helper"

describe Gyaazle::CLI do
  let(:cli) { Gyaazle::CLI.new([]) }

  describe "ensure oauth token" do
    before do
      cli.stub(:authorize).and_return("verification code")
    end

    it "invoke #check_credentials! before #upload" do
      cli.should_receive(:check_credentials!)
      cli.run!
    end

    context "config file does not exists" do
      before do
        cli.config.stub(:load).and_return(nil)
      end

      it "invoke #initialize_tokens" do
        cli.should_receive(:initialize_tokens)
        cli.run!
      end
    end

    context "config file is sane" do
      before do
        cli.config.stub(:load).and_return(:client_id => "id", :client_secret => "secret", :refresh_token => "refresh")
      end

      it "invoke #refresh_token!" do
        cli.client.should_receive(:refresh_token!)
        cli.run!
      end
    end
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

      it "set config file" do
        cli.config.file.should == file
        File.unlink(file) if File.exists?(file)
      end
    end

    context "--capture" do
      let(:cli) { Gyaazle::CLI.new(%W!--capture!) }
      before do
        cli.stub(:upload)
      end

      it "invoke #capture" do
        cli.should_receive(:capture)
        cli.run!
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
end

