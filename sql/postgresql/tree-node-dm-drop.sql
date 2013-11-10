create function tmp1 () returns void as $$
  declare
  begin
    PERFORM acs_object_type__drop_type('tree_node','f');
  end;
$$ language 'plpgsql';

select tmp1();
drop function tmp1();

drop table tree_nodes;


