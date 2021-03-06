%%
%% Author:wwhai
%%
-module(fweb_cloud_function).
-behaviour(gen_server).

-include("fweb_type.hrl").
-export([start_link/1]).
-export([code_change/3, handle_call/3, handle_cast/2, handle_info/2, init/1, terminate/2]).
-record(state, {luavm, options}).

start_link(Options) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], [Options]).

init(Options) ->
    LuaVM = luerl:init(),
    {ok, #state{luavm = luerl:set_table([<<"test_fun">>],fun fweb_cloud_api:f1/2, LuaVM), options = Options}}.

handle_call({run_script,
             Script,
             Reduction,
             Period,
             Timeout,
             CallBackFunction,
             CallBackArgs}, _From, #state{luavm = LuaVM} = State) ->
    Result = luerl_sandbox:run(Script,
                               LuaVM,
                               Reduction,
                               Period,
                               Timeout,
                               [[CallBackFunction], CallBackArgs]),
    Reply = case Result of
        {error, Reason} -> {error, Reason};
        {R, NewState} -> R
    end,
    {reply, Reply, State};
handle_call({load_lib, Libs}, _From, #state{luavm = LuaVM, options = Options}) ->
    {reply, ok, #state{luavm = load_lib(Libs, LuaVM), options = Options}};
handle_call(Msg, _From, State) ->
    {reply, ignore, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Internal functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% K: Lua called name
%% F: Erlang function
load_lib([], LuaVM) -> LuaVM;
load_lib([[K, F] | T] = _Libs, LuaVM) ->
    load_lib(T, luerl:set_table([K], F, LuaVM)).