-module(cdl).
-include_lib("eunit/include/eunit.hrl").
-export([run/1]).

compress_lastDg0_test()->
    ?assertEqual(120, run([1,2,0])).
compress_lastDg0_2_test()->
    ?assertEqual(120, run([1,20])).
compress_lastDg0_3_test()->
    ?assertEqual(120, run([120])).
compress_first_and_lastDg0_test()->
    ?assertEqual(120, run([0,1,20])).
compress_all0_test()->
    ?assertEqual(0, run([000000,0000,0,0,0,000000])).
compress_otwice_10th_test()->
    ?assertEqual(343, run([3, 43])).
compress_twice_10th_test()->
    ?assertEqual(433, run([43, 3])).
compress_10th_test()->
    ?assertEqual(43, run([43])).
compress_lotsofDs_test() ->
    ?assertEqual(98765434109, run([9,8,7,6,5,4,3,4,1,0,9])).
compress_0lotsofDs_test() ->
    ?assertEqual(98765434109, run([0,9,8,7,6,5,4,3,4,1,0,9])).
compress_44lotsofDs_test() ->
    ?assertEqual(4409876543410944555, run([44,0,9,8,7,6,5,4,3,4,1,0,9,44,555])).
compress_uptpPower22Ds_test() ->
    ?assertEqual(44441094455542526282901, run([4,4,4,4,1,0,9,4,4,5,5,5,4,2,5,2,6,2,8,2,9,0,1])).
compress_uptpPower23Ds_test() ->
    ?assertEqual(2191644441094455542526282901, run([219164,4,4,4,1,0,9,4,4,5,5,5,4,2,5,2,6,2,8,2,9,0,1])).
compress_10944555Ds_test() ->
    ?assertEqual(10944555, run([1,0,9,44,555])).
compress_3Ds_test() ->
    ?assertEqual(123, run([1,2,3])).
compress_1D_test() ->
    ?assertEqual(1, run([1])).
compress_empty_test() ->
    ?assertEqual(na, run([])).

%%% failing tests
compress_uptpPower23_14Ds_test() ->
    ?assertEqual(21916414441094455542526282901, run([219164,14,4,4,1,0,9,4,4,5,5,5,4,2,5,2,6,2,8,2,9,0,1])).
compress_4422222lotsofDs_test() ->
    ?assertEqual(4409876543444410944555222222222, run([44,0,9,8,7,6,5,4,3,4,44,4,1,0,9,44,555,2,2,2,2,2,2,2,2,2])).

int_pow_test()->
    ?assertEqual(100000000000000000000000000, int_pow(10,26)).

run([])->
    na;
run(L) ->
    compress(L).

compress(L) ->
compress(lists:reverse(L), 0, 0).

compress([], Acc, _N) ->
    Acc;
compress([0|T], Acc, N)->
    compress(T, Acc, N + 1);
compress([H|T], Acc, N) ->
    Nr = trunc(math:log10(H))+1,
    %Zrs = trunc(math:pow(10, N)),
    Zrs = int_pow(10, N),
    compress(T,  Acc + H * Zrs,  Nr + N).

%% Bob Ippolito implemented functino 'int_pow' 
%% Reference of Source Origin
%% https://github.com/mochi/mochiweb/blob/master/src/mochinum.erl#L50
%% http://erlang.org/pipermail/erlang-questions/2012-March/065257.html
%% The function is copied and utilized here free of use according the terms of the source origin's license

int_pow(_X, 0) ->
    1;
int_pow(X, N) when N > 0 ->
    int_pow(X, N, 1).

int_pow(X, N, R) when N < 2 ->
    R * X;
int_pow(X, N, R) ->
    int_pow(X * X, N bsr 1, case N band 1 of 1 -> R * X; 0 -> R end).
