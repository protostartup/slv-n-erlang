-module(server).
-export([start/0, sum_areas/1, stop/0,
	 init/1]).

-include("server.hrl").

start() ->
    case whereis(?math_server) of
	undefined ->
	    Pid = spawn(?MODULE, init, [fun geometry:areas/1]),
	    register(?math_server, Pid),
	    on_exit(Pid, fun keep_alive/1),
	    {ok, Pid};
	Pid when is_pid(Pid) ->
	    {error, already_started}
    end.

sum_areas(Shapes) ->
    ?math_server ! {request, self(), {sum_areas, Shapes}},
    receive
	{reply, ?math_server, Result} ->
	    Result
    end.

stop() ->
    case whereis(?math_server) of
	undefined ->
	    {error, already_stopped};
	Pid when is_pid(Pid) ->
	    ?math_server ! stop,
	    {ok, stopped}
    end.

init(F) ->
    loop(F).

loop(F) ->
    receive
	{request, Client, {sum_areas, Shapes}} ->
	    Result = eval(F, Shapes),
	    Client ! {reply, ?math_server, Result},
	    loop(F);
	stop ->
	    exit(normal);
	intented_crash ->
	    exit(intended_crash);
	_M ->
	    loop(F)
    end.

eval(Fun, Args) ->
    case catch Fun(Args) of
	{'EXIT', Why} ->
	    {error, Why};
	Result ->
	    {ok, Result}
    end.

on_exit(Pid, Fun) ->
    spawn(fun() ->
		  process_flag(trap_exit, true),
		  link(Pid),
		  receive
		      {'EXIT', Pid, Why} ->
			  Fun(Why),
			  exit(normal);
		      M ->
			  M
		  end
	  end).

keep_alive(intended_crash) ->
    start();
keep_alive(_Why) ->
    ok.
