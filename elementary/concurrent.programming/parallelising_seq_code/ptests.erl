-module(ptests).
-export([tests/1, fib/1]).
-import(lists, [map/2]).
-import(lib_misc, [pmap/2]).

tests(N) ->
    %io:format("~w~n", [N]),
    %Nsched = list_to_integer(N),
    run_tests(1, N).%Nsched).

run_tests(N, Nsched) ->
    case test(N) of 
	stop ->
	    init:stop();
	Val ->
	    io:format("~p.~n", [{Nsched, Val}]),
	    run_tests(N+1, Nsched)
    end.

test(1) ->
    %% Male 100 lists
    %% Each list contains 1000 random integers
    seed(),
    S = lists:seq(1, 1000),
    L = map(fun(_) -> mklist(1000) end, S),
    {Time1, S1} = timer:tc(lists, map, [fun lists:sort/1, L]),
    {Time2, S2} = timer:tc(lib_misc, pmap, [fun lists:sort/1, L]),
    {sort, Time1, Time2, equal(S1, S2)};
test(2) ->
    %% L = [27,27,27,27,..] 100 times
    L = lists:duplicate(100, 10),
    {Time1, S1} = timer:tc(lists, map, [fun ptests:fib/1, L]),
    {Time2, S2} = timer:tc(lib_misc, pmap, [fun ptests:fib/1, L]),
    {fib, Time1, Time2, equal(S1,S2)};
test(3) ->
    stop.

%% Equal is used to test that map and pmap compute the same thing
equal(S,S) -> true;
equal(S1,S2) -> {differ, S1, S2}.

%% recursive (inefficient fibonacci)
%fib(0) -> 1;
%fib(1) -> 1;
%fib(N) -> fib(N-1) + fib(N-2).
fib(N) ->
    fib(N, 1, 0).
fib(0, _, Acc) ->
    Acc;
fib(N, Fib1,Fib0)->
    fib(N-1, Fib0, Fib1+Fib0).

%% Reset the random number generator. This is so we 
%% get the same sequence of random numbers each time we run
%% the program

seed() ->
    random:seed(44,55,66).

%% Make a list of K random numbers 
%% Each random number in the range 1..1000000
mklist(K)->
    mklist(K,[]).
mklist(0,L)->
    L;
mklist(N,L) ->
    mklist(N-1, [random:uniform(1000000)|L]).

    

    
