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
    context "folder_id given" do
      before do
        config.update(:folder_id => folder_id)
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

    context "folder_id does not given" do
      before do
        config.update(:folder_id => nil)
      end

      it "invoke #create_folder" do
        client.should_receive(:create_folder)
        client.folder_id
      end
    end

    context "folder_id given but its in trash" do
      before do
        config.update(:folder_id => folder_id)
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

  describe "#get_file_info" do
    let(:response) { {:folder_id => folder_id, :labels => {:trashed => false}} }
    before do
      @requset = stub_request(:get, "https://www.googleapis.com/drive/v2/files/#{folder_id}").with(
        :headers => {
          "Authorization" => client.authorization_header_value
        }
      ).to_return(
        :body => MultiJson.dump(response)
      )
    end

    it "GET www.googleapis.com with folder_id" do
      client.get_file_info(folder_id)
      WebMock.should have_requested(:get, "https://www.googleapis.com/drive/v2/files/#{folder_id}")
    end

    it "return response as object" do
      client.get_file_info(folder_id).should == response
    end
  end

  describe "#create_folder" do
    let(:new_folder_id) { "foobardir" }
    let(:new_folder_name) { "Gyaazle" }

    before do
      @request = stub_request(:post, "https://www.googleapis.com/drive/v2/files").with(
        :headers => {
          "Authorization" => client.authorization_header_value
        }
      ).to_return(
        :body => MultiJson.dump(:id => new_folder_id)
      )
    end

    it "POST www.googleapis.com with new_folder_name" do
      client.create_folder(new_folder_name)
      WebMock.should have_requested(:post, "https://www.googleapis.com/drive/v2/files").with{|req| req.body[new_folder_name] }
    end

    it "config[:folder_id] should update" do
      client.create_folder(new_folder_name)
      config.load[:folder_id].should == new_folder_id
    end

    it "return new folder_id" do
      client.create_folder(new_folder_name).should == new_folder_id
    end
  end

  describe "#refresh_token!" do
    let(:access_token) { "ACCESS_TOKEN" }
    before do
      @request = stub_request(:post, "https://accounts.google.com/o/oauth2/token").to_return(
        :body => MultiJson.dump(:access_token => access_token)
      )
    end

    it "POST accounts.google.com" do
      client.refresh_token!
      WebMock.should have_requested(:post, "https://accounts.google.com/o/oauth2/token")
    end

    it "update access token" do
      client.refresh_token!
      config.load[:access_token].should == access_token
    end
  end
end

