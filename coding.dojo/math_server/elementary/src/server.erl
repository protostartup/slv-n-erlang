-module(server).
-export([start/0, sum_areas/2, stop/1,
	 loop/1]).

start() ->
    Pid = spawn(?MODULE, loop, [fun geometry:areas/1]),
    {ok, Pid}.

sum_areas(Shapes, ServerPid) ->
    ServerPid ! {request, self(), {sum_areas, Shapes}},
    receive
	{reply, ServerPid, Result} ->
	    Result
    end.

stop(ServerPid) ->
    ServerPid ! stop,
    {ok, stopped}.

loop(F) ->
    receive
	{request, Client, {sum_areas, Shapes}} ->
	    Result = eval(F, Shapes),
	    Client ! {reply, self(), Result},
	    loop(F);
	stop ->
	    ok
    end.

eval(Fun, Args) ->
    case catch Fun(Args) of
	{'EXIT', Why} ->
	    {error, Why};
	Result ->
	    {ok, Result}
    end.
