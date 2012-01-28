if ENV['SPEC_COVERAGE'].to_i == 1
  require 'simplecov'

  SimpleCov.adapters.define 'gem' do
    add_filter '/spec/'
    add_filter '/autotest/'
    add_group 'Libraries', '/lib/'
  end

  SimpleCov.start 'gem'
end

require 'typhoeus'
require 'orthrus'
require 'json'

RSpec.configure do |config|
  config.color_enabled = true

  config.before(:all) do
    hydra           = Typhoeus::Hydra.hydra
    @index_response = Typhoeus::Response.new(:code => 200, :body => '{ "planets" : ["mars", "earth", "venus"] }', :time => 0.3)
    @mars_response  = Typhoeus::Response.new(:code => 200, :body => '{ "mars" : { "density" : "3.9335 g/cm3" , "temperature" : "210K" } }', :time => 0.3)
    @moon_response  = Typhoeus::Response.new(:code => 200, :body => '{ "moon" : { "density" : "3.346 g/cm3", "temperature" : "57K" } }', :time => 0.3)
    @error_response = Typhoeus::Response.new(:code => 404, :body => '{ "eris" : "is no planet but a TNO" }', :time => 0.3)
    @put_response   = Typhoeus::Response.new(:code => 403, :body => 'Creating planets is not your business!', :time => 0.3)
    hydra.stub(:get, "http://astronomical.test/planets").and_return(@index_response)
    hydra.stub(:get, "http://astronomical.test/planets/mars").and_return(@mars_response)
    hydra.stub(:get, "http://astronomical.test/planets/moon").and_return(@moon_response)
    hydra.stub(:get, "http://astronomical.test/planets/eris").and_return(@error_response)
    hydra.stub(:put, "http://astronomical.test/planets").and_return(@put_response)
  end
end

class Planet
  include Orthrus

  remote_method_defaults do |config|
    config.headers  = { :authentication => "Basic authentication" }
    config.base_uri = "http://astronomy.test"
    config.params   = { :format => "json" }
  end

  define_remote_method :show do |method|
    method.path   = "planets/:identifier"
    method.params = { :include_details => true }
  end

  define_remote_method :index, :path => 'planets'

end

# class Biology < Astronomy
#   remote_defaults :base_uri => "http://biological.test",
#                   :params   => { :boring => false }
# end

