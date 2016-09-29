# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)


# prometheus Rack server
require 'rack'

# tracing of HTTP requests
require 'prometheus/client/rack/collector'

# HTTP endpoint to be scraped by a prometheus server 
require 'prometheus/client/rack/exporter'
use Prometheus::Client::Rack::Collector
use Prometheus::Client::Rack::Exporter

run ->(env) { [200, {'Content-Type' => 'text/html'}, ['OK']] }
run Rails.application