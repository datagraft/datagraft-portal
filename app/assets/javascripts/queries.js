redirectToSparqlEndpoint = function(base_url, select_id, select_slug){
    console.log(" base_url " + base_url + " select_id " + select_id + " select_slug " +select_slug);
    var obj_id = document.getElementById(select_id);
    var sel_id_idx = obj_id.selectedIndex;
    var sel_id_val = obj_id[sel_id_idx].value;
    var obj_slug = document.getElementById(select_slug);
    var sel_slug_val = obj_slug[sel_id_idx].value;
    var redir_url = base_url + '/' + sel_slug_val;
    console.log(" idx " + sel_id_idx + " id_val " + sel_id_val + " slug_val " +sel_slug_val);
    console.log("Redirect to " + redir_url);
    //debugger;
    window.location = redir_url;
}
