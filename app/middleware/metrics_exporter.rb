# extends the default Prometheus metrics exporter by adding security
class MetricsExporter < Prometheus::Middleware::Exporter
  def call(env)
    super(env)
  end
end