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

# some discussion from IRC:

# <jim> more recursive/CTE stuff. 

# reminder of where things are: 
# - http://jam.sessionsnet.org:8000/tree-test/ 
#     is where I display the results of the query, 
# - https://github.com/jwlynch/tree-test 
#     is where the code is. 
# - and, in the repo view, sql/postgresql has the table and 
#     function definitions

# There is now a third query (it's in index.tcl, and the query 
# name is recur_from_leaves. At the moment it just has the base 
# case; I'm trying to compose the recursive case. 

# <RhodiumToad> jim: as a general rule you shouldn't be trying 
#   to recurse that way
# if you need to start from a single node and work back to the 
#   root, that's ok
# <jim> it's just a test... it's not possible?
# <RhodiumToad> jim: oh, it's perfectly possible
#   just use the opposite comparison order to the one 
#   for recursing from the root
#   depending on how you do it you'll potentially get a lot 
#   of result rows, since with a union all you'll see every 
#   path from leaves to root
# <jim> and I'll end up with duplicate roots if there are >1 leaves?
# <RhodiumToad> jim: union will remove duplicates if you don't add 
#    any path info to the result rows yourself
# <jim> at the moment there are 4 rows in the table, one with parent 
#   NULL, the other three point at the parent... so then, union all 
#   will give me 3 root rows?
# <RhodiumToad> jim: yes
# <jim> looking at the second query, db_multirow recur_nodes,
#   I'm trying to understand the join after the union all
# <RhodiumToad> jim: the join is between the raw table and the 
#   set of rows produced in the previous pass of the query (or 
#   the non-recursive part if this is the first pass).
#   So when going from leaves to root, the CTE self-reference 
#   contains the leaf nodes returned by the non-recursive part,
#   and you join against the raw table to find the parents of 
#   those nodes. Then the next pass finds the parents of _those_ 
#   nodes, and so on.
# <jim> I'm also learning the terms, so I don't know what a "cte 
#   self reference" is
# <RhodiumToad> CTE is "common table expression", i.e. the WITH 
#   thing. In "WITH x AS (...)"   - "x" is a CTE; for WITH RECURSIVE, 
#   a CTE can refer to itself:  "WITH RECURSIVE x AS (select ... 
#   union all select ... from x join ...)"
#   Inside a recursive CTE, using the CTE name as a table means 
#   "use the rows generated by the previous pass here".
# <jim> so in the second query, tree_nodes is obviously the table, 
#   and childnodes (which is mentioned in the "with recursive childnodes 
#   as ...")
# <RhodiumToad> "childnodes" is the recursive self-reference, yes 
#   (you might choose a better name when working from leaf to root)

db_multirow recur_nodes get_recur_nodes {
    with recursive childnodes as
    (
        select
            n.tree_node_name,
            n.tree_node_id,
            n.parent_id,
            'no' as r
        from
            tree_nodes n
        where
	    n.parent_id is null

        union all

        select
            rn.tree_node_name,
            rn.tree_node_id,
            rn.parent_id,
            'yes' as r
        from
            tree_nodes as rn
        join
            childnodes as crn
            on rn.parent_id = crn.tree_node_id
    )
    select
        tree_node_name,
        tree_node_id,
        parent_id,
        r
    from
        childnodes
   order by
        parent_id
}

db_multirow recur_from_leaves get_recur_from_leaves {
    with recursive parentnodes as (
        select
            tn.tree_node_name,
            tn.tree_node_id,
            tn.parent_id
        from
            tree_nodes tn
        where
            not exists
	    (
                select
                    1
                from
                    tree_nodes tst_tn
                where
                    tst_tn.parent_id = tn.tree_node_id
            )

        union all

        select
            rn.tree_node_name,
            rn.tree_node_id,
            rn.parent_id
        from
            tree_nodes as rn
        join
            parentnodes as prn
            on rn.tree_node_id = prn.parent_id
    )
    select
        tree_node_name,
        tree_node_id,
        parent_id
    from
        parentnodes
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


