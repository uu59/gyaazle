# -- coding: utf-8

require "spec_helper"

describe Gyaazle::CLI do
  describe "ensure oauth token" do
    let(:cli) { Gyaazle::CLI.new([]) }

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
end

