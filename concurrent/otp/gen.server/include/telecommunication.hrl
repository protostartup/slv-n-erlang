-record(connect, {client_pid}).
-record(server_reply,{message}).

-record(cask4stats, {client_pid}).
-record(abort_client, {message}).
-record(stats, {name, length}).
-record(stats_reply, {stats_free=#stats{}, stats_allocated=#stats{}}).
-record(request_stats, {from_pid, free, allocated}).
