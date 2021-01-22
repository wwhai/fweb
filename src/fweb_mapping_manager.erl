%% @author wangwenhai
%% @doc @todo Add description to fweb_mapping_manager.

-module(fweb_mapping_manager).
-behaviour(gen_server).
-include("fweb_type.hrl").
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/1]).
%% ====================================================================
%% API functions
%% ====================================================================
-export([]).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {}).
start_link(_) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    EtsOptions = [named_table, public, set, {write_concurrency, true},
                                            {read_concurrency, true}],
    ets:new(fweb_mapping, EtsOptions ++ [{keypos, #handler.mapping}]),
    fweb:add_mapping([#{name =>index,mapping =>"/index"}]),
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


handle_cast(_Msg, State) ->
    {noreply, State}.


handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
