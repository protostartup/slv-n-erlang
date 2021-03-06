-module(amqp_sp_exchange).

-export([start_link/1, declare/0]).

-export([init/2, system_continue/3, system_terminate/4,
	 write_debug/3,
	 system_get_state/1, system_replace_state/2]).

-include_lib("amqp_client/include/amqp_client.hrl").

-record(state, {exchange_declare_args, exchange_declared}).
-record(declare, {exchange_declare_args, from}).

-define(exchange_declare_proc, amqp_sp_exchange_declare_proc).

%% ===================================================================
%% API
%% ===================================================================

start_link(ExchangeDeclareArgs) ->
    proc_lib:start_link(?MODULE, init, [self(), ExchangeDeclareArgs]).

declare() ->
    io:format("Interface function 'declare/0' was called by ~p~n", [self()]),
    ?exchange_declare_proc ! #declare{exchange_declare_args = {}, from = self()}.

%%%===================================================================
%%% proc_lib callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initialises the process
%%--------------------------------------------------------------------
init(Parent, ExchangeDeclareArgs) ->
    register(?exchange_declare_proc, self()),
    Deb = sys:debug_options([statistics, trace]),
    proc_lib:init_ack(Parent, {ok, self()}),
    Deb2 = sys:handle_debug(Deb, fun ?MODULE:write_debug/3, ?MODULE, {"AMQP Exchange Declarer started"}),
    process_flag(trap_exit, true),
    active(#state{exchange_declare_args = ExchangeDeclareArgs, exchange_declared = {}}, Parent, Deb2).

%%%===================================================================
%%% system and debug callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%%--------------------------------------------------------------------
write_debug(Dev, Event, Name) ->
    io:format(Dev, "~p: event = ~p~n", [Name, Event]).

system_continue(Parent, Deb, State) ->
    active(State, Parent, Deb).

system_terminate(Reason, _Parent, Deb, _State) ->
    sys:handle_debug(Deb, fun ?MODULE:write_debug/3, ?MODULE, {shutdown, Reason}),
    unregister(whereis(?exchange_declare_proc)),
    exit(Reason).

system_get_state(State) ->
    {ok, State}.

system_replace_state(StateFun, State) ->
    NState = StateFun(State),
    {ok, NState, NState}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%%--------------------------------------------------------------------
active(#state{exchange_declare_args = ExchangeDeclareArgs, exchange_declared = ActualExchangeDeclaredArgs} = State, Parent, Deb) ->
    receive
	{system, From, Request} ->
	    sys:handle_system_msg(Request, From, Parent, ?MODULE, Deb, State);
	{'EXIT', Parent, Reason} ->
	    sys:handle_debug(Deb, fun ?MODULE:write_debug/3, ?MODULE, {"Receieved 'EXIT' from", Parent, "because", Reason}),
	    unregister(whereis(?exchange_declare_proc)),
	    exit(Reason);
	#declare{exchange_declare_args = _anotherExchangeArgs, from = From} ->
	    case has_been_declared(State) of
		false ->
		    case declare2(ExchangeDeclareArgs, Deb) of
			{ok, ExchangeDeclaredAs, Deb2} ->
			    From ! {ok, ExchangeDeclaredAs},
			    active(#state{exchange_declare_args = ExchangeDeclareArgs, exchange_declared = ExchangeDeclaredAs}, Parent, Deb2);
			{error, E, Deb2} ->
			    From ! {error, E},
			    active(State, Parent, Deb2)
		    end;
		true ->
		    Deb2 = sys:handle_debug(Deb, fun ?MODULE:write_debug/3, ?MODULE, {"Exchange", ActualExchangeDeclaredArgs, "has been already declared"}),
		    From ! {error, exchange_has_been_already_declared},
		    active(State, Parent, Deb2)
	    end
    end.

%%--------------------------------------------------------------------
%% @private
%%--------------------------------------------------------------------
declare2(ExchangeDeclareArgs, Deb) ->
    case open_channel(Deb) of
	{error, E, Deb2} ->
	    {error, E, Deb2};
	{Connection, Channel, Deb2} ->
	    Exchange_declare = #'exchange.declare'{exchange = ExchangeDeclareArgs},
	    case amqp_channel:call(Channel, Exchange_declare) of
		#'exchange.declare_ok'{} ->
		    Deb3 = sys:handle_debug(Deb2, fun ?MODULE:write_debug/3, ?MODULE, {"Exchange has been successfully declared at RabbitMQ", ExchangeDeclareArgs, Exchange_declare}),
		    amqp_channel:close(Channel),
		    amqp_connection:close(Connection),
		    {ok, Exchange_declare, Deb3};
		E ->
		    amqp_channel:close(Channel),
		    amqp_connection:close(Connection),
		    Deb3 = sys:handle_debug(Deb2, fun ?MODULE:write_debug/3, ?MODULE, {"Failed to declare an exchange", E}),
		    {error, E, Deb3}
	    end
    end.

%%--------------------------------------------------------------------
%% @private
%%--------------------------------------------------------------------
open_channel(Deb) ->
    case amqp_connection:start(#amqp_params_network{}) of
	{ok, Connection} ->
	    case amqp_connection:open_channel(Connection) of
		{ok, Channel} ->
		    {Connection, Channel, Deb};
		E ->
       		    {error, E, Deb}
	    end;
	E ->
	    {error, E, Deb}
    end.

%%--------------------------------------------------------------------
%% @private
%%--------------------------------------------------------------------
has_been_declared(#state{exchange_declare_args = _ExchangeDeclareArgs, exchange_declared = {}}) ->
    false;
has_been_declared(#state{exchange_declare_args = ExchangeDeclareArgs,
			 exchange_declared = #'exchange.declare'{exchange = ExchangeDeclareArgs,
								 ticket      = _,
								 type        = _,
								 passive     = _,
								 durable     = _,
								 auto_delete = _,
								 internal    = _,
								 nowait      = _,
								 arguments   = _}}) ->
    true.
