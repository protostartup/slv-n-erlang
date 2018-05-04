-module(server_tests).
-include_lib("eunit/include/eunit.hrl").
-import(server, [start/0, sum_areas/1, stop/0]).
-include("server.hrl").

start_test() ->
    {ok, ServerPid} = start(),

    ?assertMatch(Pid when is_pid(Pid), ServerPid),

    stop().

sum_areas_test() ->
    Shapes = [{circle, 3}, {rectangle, 4, 6}],
    {ok, _Pid} = start(),

    Result = sum_areas(Shapes),

    ?assertEqual({ok, 52.27433388230814}, Result),

    stop().

stop_test() ->
    {ok, Pid} = start(),

    {ok, stopped} = stop(),

    receive after 10 -> ok end,
    ?assertNot(is_process_alive(Pid)),

    stop().

sum_unknown_areas_test() ->
    {ok, _Pid} = start(),
    Shapes = [{circle, 3, 3}],

    Result = sum_areas(Shapes),

    ?assertMatch({error, {function_clause, _Detail}}, Result),

    stop().

never_die_test() ->
    {ok, Pid} = start(),

    Pid ! crash,

    ?assert(is_process_alive(whereis(?math_server))),

    stop().

start_consecuative_twice_test() ->
    ok.
