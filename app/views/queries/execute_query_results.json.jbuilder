json.set! "@id", request.protocol+request.host_with_port+thing_path(@sparql_endpoint)
json.set! "query_string", @query.query_string

json.query_result @results_list
json.query_error @query_error
