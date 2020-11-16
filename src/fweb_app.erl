-module(fweb_app).

-behaviour(application).

-export([start/2, stop/1]).

-include("fweb_type.hrl").

start(_StartType, _StartArgs) ->
    fweb_sup:start_link().

stop(_State) -> ok.
