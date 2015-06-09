<master>

<formtemplate id="new_node"></formtemplate>

<ul>
  <multiple name="nodes">
    <li>name |@nodes.tree_node_name@|,id=@nodes.tree_node_id@, parent_id=@nodes.parent_id@</li>
  </multiple>
</ul>

<ul>
  <multiple name="recur_nodes">
    <li>
      name |@recur_nodes.tree_node_name@|,
      id=@recur_nodes.tree_node_id@,
      parent_id=@recur_nodes.parent_id@
    </li>
  </multiple>
</ul>
