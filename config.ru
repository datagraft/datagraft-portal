# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)


# prometheus Rack server
require 'rack'

# tracing of HTTP requests
require 'prometheus/middleware/collector'

# HTTP endpoint to be scraped by a prometheus server 
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Collector
use MetricsExporter

run Proc.new { |env| [200, {'Content-Type' => 'text/html'}, ['OK']] }
#run ->(env) { [200, {'Content-Type' => 'text/html'}, ['OK']] }
run Rails.application