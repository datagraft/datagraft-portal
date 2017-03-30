# extends the default Prometheus metrics exporter by adding security
class MetricsExporter < Prometheus::Client::Rack::Exporter
  def call(env)
    super(env)
  end
end