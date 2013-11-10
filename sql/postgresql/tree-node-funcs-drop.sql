drop function tree_node__delete
(
    integer
);

drop function tree_node__edit
(
    p_tuning_id       integer,
    p_tuning_name     varchar
);

drop function tree_node__new
(
    varchar,
    integer,
    integer,

    integer,
    timestamptz,
    integer,
    varchar,
    integer
);

