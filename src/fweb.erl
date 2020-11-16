%% @author wangwenhai
%% @doc @todo Add description to fweb.


-module(fweb).
-behaviour(gen_server).
-include("fweb_type.hrl").
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/1, add_mapping/1, add_interceptor/1, render/1]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([]).


%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, {}).

start_link({port, Port}) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).

init([Port]) ->
  Dispatch = cowboy_router:compile([{'_', [{'_', fweb_dispatcher, #{}}]}]),
  Started = cowboy:start_clear(fweb_http_listener, [{port, Port}],
    #{env => #{dispatch => Dispatch}}),
  case Started of
    {ok, _} -> ok;
    {error, eaddrinuse} -> error(addr_in_use);
    {error, Any} -> error({fweb_start_error, Any})
  end,
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


%% ====================================================================
%% Internal functions
%% ====================================================================


add_mapping(Handlers) ->
  lists:foreach(fun(#{name := Handler, mapping := Mapping}) when
    is_atom(Handler) and is_list(Mapping) ->
    ets:insert(fweb_mapping, #handler{name = Handler, mapping = Mapping})
                end, Handlers).

add_interceptor(Interceptors) ->
  lists:foreach(fun(#{name := Name, path := Path}) when is_atom(Name) and is_list(Path) ->
    ets:insert(fweb_interceptor, #interceptor{name = Name, path = Path})
                end, Interceptors).

render(Template) ->
  {ok, Root} = file:get_cwd(),
  Path = string:concat(Root, "/template"),
  {ok, R} = file:read_file(string:concat(Path, Template)),
  R.

