-module(rename).

-compile(export_all).

%% Change node name embedded in mnesia database
%% http://stackoverflow.com/questions/463400/how-to-rename-the-node-running-a-mnesia-database

go() ->
    change_node_name('dbm@ipa', 'nonode@nohost',
                     "ipa.mnesia.backup", "nohost.mnesia.backup").

change_node_name(From, To, Source, Target) ->
    Switch =
        fun(Node) when Node == From -> To;
           (Node) when Node == To -> throw({error, already_exists});
           (Node) -> Node
        end,
    Convert =
        fun({schema, db_nodes, Nodes}, Acc) ->
                {[{schema, db_nodes, lists:map(Switch,Nodes)}], Acc};
           ({schema, version, Version}, Acc) ->
                {[{schema, version, Version}], Acc};
           ({schema, cookie, Cookie}, Acc) ->
                {[{schema, cookie, Cookie}], Acc};
           ({schema, Tab, CreateList}, Acc) ->
                Keys = [ram_copies, disc_copies, disc_only_copies],
                OptSwitch =
                    fun({Key, Val}) ->
                            case lists:member(Key, Keys) of
                                true -> {Key, lists:map(Switch, Val)};
                                false-> {Key, Val}
                            end
                    end,
                {[{schema, Tab, lists:map(OptSwitch, CreateList)}], Acc};
           (Other, Acc) ->
                {[Other], Acc}
        end,
    Mod = mnesia_backup,
    mnesia:traverse_backup(Source, Mod, Target, Mod, Convert, switched).
