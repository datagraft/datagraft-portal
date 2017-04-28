json.set! "@id", request.protocol+request.host_with_port+thing_path(@thing)
json.set! "query", @query.query

json.query_result @results_list
