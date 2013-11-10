create or replace function tree_node__new
(
    p_tree_node_name varchar,
    p_tree_node_id   integer,
    p_parent_id      integer,

    p_creation_user  integer,
    p_creation_date  timestamptz,
    p_package_id     integer,
    p_creation_ip    varchar,
    p_context_id     integer
)
returns int4
as $$
declare
    v_object_id integer;
begin
    -- make row in objects table for the tuning
    v_object_id :=
      acs_object__new
      (
        p_tree_node_id,
        'tree_node',
        p_creation_date,
        p_creation_user,
        p_creation_ip,
        p_context_id,
        '', -- title
        p_package_id
      );

    -- make row in tunings table
    insert into tree_nodes
      (tree_node_id, tree_node_name, parent_id)
    values
      (v_object_id, p_tree_node_name, p_parent_id);

    return v_object_id;
end;
$$ language 'plpgsql';

create or replace function tree_node__edit
(
    p_tree_node_id       integer,
    p_tree_node_name     varchar
) returns void
as $$
    begin
        update
            tree_nodes
        set
            tree_node_name = p_tree_node_name
        where
            tree_node_id = p_tree_node_id;
    end;
$$ language 'plpgsql';


create or replace function tree_node__delete
(
    delete_tree_node_id integer
)
returns void
as $$
begin
    delete from tree_nodes where tree_node_id = delete_tree_node_id;

    perform acs_object__delete(delete_tree_node_id);
end;
$$ language 'plpgsql';

