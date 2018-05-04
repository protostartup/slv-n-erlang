-module(server_tests).
-include_lib("eunit/include/eunit.hrl").
-import(server, [start/0, sum_areas/2, stop/1]).

start_test() ->
    {ok, ServerPid} = start(),

    ?assertMatch(Pid when is_pid(Pid), ServerPid),
    
    stop(ServerPid).

sum_areas_test() ->
    {ok, Pid} = start(),
    Shapes = [{circle, 3}, {rectangle, 4, 6}],

    Result = sum_areas(Shapes, Pid),

    ?assertEqual({ok, 52.27433388230814}, Result),

    stop(Pid).

stop_test() ->
    {ok, Pid} = start(),

    {ok, stopped} = stop(Pid),

    receive after 50 -> ok end,
    ?assertNot(is_process_alive(Pid)).

sum_unknown_areas_test() ->
    {ok, Pid} = start(),
    Shapes = [{circle, 3, 3}],

    Result = sum_areas(Shapes, Pid),

    ?assertMatch({error, {function_clause, _Detail}}, Result),

    stop(Pid).