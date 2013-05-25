# -- coding: utf-8

require "spec_helper"

describe Gyaazle::Config do
  let(:file) { File.expand_path("../tmp/dummy_conf.json", __FILE__) }
  let(:config) { Gyaazle::Config.new(file) }

  after do
    File.unlink(file) if File.exists?(file)
  end

  describe "#load" do
    it "return nil if config file does not exists" do
      File.unlink(file) if File.exists?(file)
      config.load.should be_nil
    end

    it "return nil if config file invalid json" do
      File.open(file, "w"){|f| f.write "invalid json here" }
      config.load.should be_nil
    end

    it "return object with symbol keys" do
      obj = {"foo" => 1, :bar => 2}
      File.open(file, "w"){|f| f.write MultiJson.dump(obj) }
      config.load.should == {:foo => 1, :bar => 2}
    end
  end

  describe "#save" do
    it "write string to config file" do
      str = "str"
      config.save(str)
      File.read(file).should == str
    end

    it "dump object to config file" do
      obj = {"foo" => "bar"}
      config.save(obj)
      File.read(file).should == MultiJson.dump(obj, :pretty => true)
    end
  end

  describe "#update" do
    before do
      @obj = {:foo => 1, :bar => 2}
      config.save(@obj)
    end

    it "save an object that merged" do
      diff = {:foo => 66, :baz => 3}
      config.update(diff)
      config.load.should == {:foo => 66, :bar => 2, :baz => 3}
    end
  end
end
