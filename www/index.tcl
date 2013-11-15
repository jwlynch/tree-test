ad_page_contract {
} -query {
} -properties {
}

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set peeraddr [ad_conn peeraddr]

db_multirow nodes get_nodes {
    select
        n.tree_node_name,
        n.tree_node_id,
        n.parent_id
    from 
        tree_nodes n
    order by
        n.tree_node_name
}

ad_form -name new_node -form {
    tree_node_id:key
    {tree_node_name:text}
    {parent_id:integer,optional}
} -new_data {
    db_transaction {
	db_1row make_new_node {
	    select
	        tree_node__new
	        (
	            :tree_node_name,
                    :tree_node_id,
                    :parent_id,

                    :user_id,
		    now(),
		    :package_id,
		    :peeraddr,
		    :package_id -- context_id
	        )
	}
    }

    ad_returnredirect .
    ad_script_abort
}


