%% @author: wwhai
%% @description: Cloud api lib
-module(fweb_cloud_api).
%% ====================================================================
%% API functions
%% ====================================================================
-export([]).
-export([start/0]).
-export([f1/2]).
%% ====================================================================
%% Internal functions
%% ====================================================================
start() ->
    io:format("HelloWorld~n").

f1(Args, State) ->
    {Args, State}.