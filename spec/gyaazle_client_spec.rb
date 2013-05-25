# -- coding: utf-8

require "spec_helper"

describe Gyaazle::Client do
  let(:file) { File.expand_path("../tmp/dummy_conf.json", __FILE__) }
  let(:config) { Gyaazle::Config.new(file) }
  let(:client) { Gyaazle::Client.new(config) }
  let(:folder_id) { "ididid" }

  before do
    config.save(:foo => 1)
  end

  after do
    File.unlink(file) if File.exists?(file)
  end

  describe "#credentials" do
    it "return hash with symbol key" do
      client.credentials.class.should == Hash
      client.credentials.keys.all?{|key| key.class == Symbol}.should be_true
    end
  end

  describe "#folder_id" do
    context "Gyaazle folder does exists" do
      before do
        client.stub(:credentials).and_return({
          :folder_id => folder_id
        })
        client.stub(:get_file_info).and_return({
          :id => folder_id,
          :labels => {
            :trashed => false
          }
        })
      end

      it "invoke #create_folder" do
        client.should_not_receive(:create_folder)
        client.folder_id.should == folder_id
      end
    end

    context "Gyaazle folder does not exists" do
      before do
        client.stub(:credentials).and_return({})
      end

      it "invoke #create_folder" do
        client.should_receive(:create_folder)
        client.folder_id
      end
    end

    context "Gyaazle folder is in trash" do
      before do
        client.stub(:credentials).and_return({
          :folder_id => folder_id
        })
        client.stub(:get_file_info).and_return({
          :id => folder_id,
          :labels => {
            :trashed => true
          }
        })
      end

      it "invoke #create_folder" do
        client.should_receive(:create_folder)
        client.folder_id
      end
    end
  end
end

