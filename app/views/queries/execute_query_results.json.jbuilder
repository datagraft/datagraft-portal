json.set! "@id", request.protocol+request.host_with_port+thing_path(@sparql_endpoint)
json.set! "query", @query.query

json.query_result @results_list
