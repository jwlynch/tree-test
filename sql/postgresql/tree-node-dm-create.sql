create table tree_nodes
(
    tree_node_id integer 
      constraint tree_nodes__tree_node_ID__pk
        primary key
      constraint tree_nodes__tree_node_ID__acsobjs__fk
        references acs_objects(object_id) on delete cascade,
    tree_node_name varchar,
    parent_id integer 
      constraint tree_nodes__tree_node_ID__fk
        references tree_nodes(tree_node_id) on delete cascade
);

create function tmp() returns void as $$
  declare
  begin
    PERFORM
      acs_object_type__create_type
      (
          'tree_node',
          'Tree node',
          'Tree nodes',
          'acs_object',
          'tree_nodes',
          'tree_node_id',
          'tree_nodes',
          'f',
          NULL,
          NULL
      );
  end;
$$ language 'plpgsql';

select tmp();
drop function tmp();

