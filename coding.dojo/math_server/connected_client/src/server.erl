-module(server).
-export([start/0, stop/0, sum_areas/1,
	 connect_client/1,
	 init/1]).

-include("server.hrl").

-define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").

start() ->
    start(?math_server).

stop() ->
    stop(?math_server).

sum_areas(Shapes) ->
    call({sum_areas, Shapes}).

connect_client(Pid) ->
    call({connect_client, Pid}).

call({connect_client, Client}) ->
    ?math_server ! {request, self(), {connect_client, Client}},
    receive
	{reply, {connect_client, {ok, client_connected, Client}}} ->
	    {ok, client_connected, Client}
    end;
call({sum_areas, Shapes}) ->
    ?math_server ! {request, self(), {sum_areas, Shapes}},
    receive
	{reply, {sum_areas, error, Why}} ->
	    {error, Why};
	{reply, {sum_areas, ok, Areas}} ->
	    {ok, Areas}
    after 50 ->
	    exit(timeout)
    end.

init(F) ->
    process_flag(trap_exit, true),
    loop(F).

start(Name) ->
    case whereis(Name) of
	undefined ->
	    Pid = spawn(?MODULE, init, [fun geometry:areas/1]),
	    register(Name, Pid),
	    {ok, Pid};
	Pid when is_pid(Pid) ->
	    {error, already_started}
    end.

stop(Name) ->
    stop(whereis(Name), Name).

stop(undefined, _Name) ->
    ok;
stop(Pid, Name) ->
    case is_process_alive(Pid) of
	true ->
	    send_stop_protocol(Name);
	false ->
	    ok
    end.

send_stop_protocol(Name) ->
    Name ! stop.

loop(F) ->
    receive
	{'EXIT', From, Why} ->
	    io:format("Server has received an Exit flag from ~p and will shutdown immediately. Reason: ~p~n", [From, Why]),
	    exit(Why);
	stop ->
            exit(shutdown);
	{request, From, {sum_areas, Shapes}} ->
	    handle_sum_areas(F, From, Shapes),
	    loop(F);
	{request, From, {connect_client, Client}} ->
	    handle_connect_client(From, Client),
	    loop(F)
    after 40000 ->
	    io:format("Timeout. Server shutdown.~n", []),
	    exit(timeout)
    end.

handle_sum_areas(F, From, Shapes) ->
    case catch F(Shapes) of
	Areas when is_float(Areas); is_integer(Areas) ->
	    From ! {reply, {sum_areas, ok, Areas}};
	Result ->
	    From ! {reply, {sum_areas, error, Result}}
    end.

handle_connect_client(From, Client) ->
    link(Client),
    From ! {reply, {connect_client, {ok, client_connected, Client}}}.
