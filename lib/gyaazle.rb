require "fileutils"

require "httpclient"
require "multi_json"
require "nokogiri"
require "trollop"
require "launchy"

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)
require "gyaazle/version"
require "gyaazle/cli"
require "gyaazle/client"
require "gyaazle/config"

module Gyaazle
  # Your code goes here...
end
