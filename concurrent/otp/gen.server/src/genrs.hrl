-record(state, {free, allocated}).
-record(server_started,  {pid, name, state}).
-record(server_stopped, {event, reason, from}).
-record(server_received, {from, msg}).
-record(server_received_unexpected, {from, msg}).
-record(server_has_sent, {msg, to}).
-record(rh_started, {pid, name, state}).
-record(rh_stopped, {event, reason, from}).
-record(allocate_resource, {server, from_pid}).
-record(res_ds, {hash, value}).
-record(free_resource, {server, from_pid, resource}).
-record(data_structure, {free=#res_ds{}, allocated=#res_ds{}}).
-record(server_request_data, {server}).
-record(rh_ok, {more, new_state}).
-record(rh_error, {reason}).
-record(rh_reply_data, {data=#data_structure{}}).
-record(rh_refused, {reason}).

%%% Internal GenRS protocols
-record(cask2free, {resource}).
-record(cask2alloc, {}).

-record(ok, {more}).
-record(error, {reason}).
