-record(allocate_resource, {server, from_pid}).
-record(free_resource, {server, from_pid, resource}).
-record(data_structure, {free, allocated}).
-record(server_request_data, {server, from_pid}).
-record(handler_reply_data, {from_pid, data=#data_structure{}}).
-record(request_stats, {from_pid, free, allocated}).
-record(stats, {name, length}).
-record(stats_reply, {stats_free=#stats{}, stats_allocated=#stats{}}).
