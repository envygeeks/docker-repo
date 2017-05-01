# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

ENV.delete("CI")
require "support/coverage"
require "luna/rspec/formatters/checks"
require "docker/template"
require "rspec/helpers"

ENV["RSPEC_RUNNING"] ||= "true"
Dir[File.expand_path("../../support/**/*.rb", __FILE__)].each do |f|
  require f
end
