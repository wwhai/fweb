-module(fweb_dispatcher).
-export([init/2]).

init(Request, State) ->
    MF = parse_mf(Request),
    case valid_mf(MF) of
        true ->
            handle_interceptor(Request, State);
        _False ->
            {ok, Request, State}
    end.

handle_interceptor(Request, State) ->
    UrlParams = parse_url_params(Request),
    case ets:match_object(fweb_interceptor, {'_', '$1', lists:nth(1, parse_mf(Request))}, 1) of
        {[{_, Interceptor, _}], _} ->
            try Interceptor:handle(UrlParams) of
                accept ->
                    accept(Request, State);
                _Deny ->
                    deny(Request, State)
            catch W : E  ->
                throw({handle_interceptor, W, E})
            end;
        _Not ->
            accept(Request, State)
    end.

accept(Request, State) ->
    MF =parse_mf(Request),
    case length(MF) of
        2 ->
            handle_mapping(Request, State);
        _Not2 ->
            {ok, Request, State}
    end.

deny (Request, State) ->
    r(text, 403, Request, State, <<"403">>).

handle_mapping(Request, State) ->
    [Mapping, Action] =parse_mf(Request),
    #{path := Path} = Request,
    R = case ets:match_object(fweb_mapping, {'_', '$1', "/" ++ Mapping}, 1) of
        {[{_, HandleModule, _}], _} when is_atom(HandleModule), is_list(Action) ->
                    try list_to_existing_atom(Action) of
                        Fun ->
                            Args = parse_args(Request, parse_url_params(Request)),
                            apply(HandleModule, Fun, Args)
                    catch
                        _W : _E -> 404
                    end;
        _ -> 404
    end,
    case R of
        {Type, Return} -> r(Type, 200 ,Request, State, Return);
        _ -> r(text ,404, Request, State, "Http result code :404, message: no route to path:" ++ Path)
    end.
% 

r(Type, Code ,Request, State, Info) when is_binary(Info) ; is_list(Info)->
    HttpHeader = case Type of
        html ->
            #{<<"content-type">> => <<"text/html">>};
        _   ->
            #{<<"content-type">> => <<"text/plain">>}
    end,
    Response = cowboy_req:reply(Code, HttpHeader, Info, Request),
    {ok, Response, State}.


covert(M) ->
    case M of
        <<"GET">> -> get;
        <<"POST">> -> post;
        <<"DELETE">> -> delete;
        <<"PUT">> -> put;
        _ -> get
    end.

parse_body(#{body_length := BodyLength, has_body := HasBody} = Request) ->
    case HasBody of
            true ->
                {ok, Data, _} = cowboy_req:read_body(Request, #{length => BodyLength}),
                Data;
            _False ->
                <<>>
    end.

parse_args(#{method := Method} = Request, Params) ->
    case lists:member(Method, [<<"POST">>, <<"PUT">>]) of
        true ->
            [covert(Method), Params, parse_body(Request)];
        _False ->
            [covert(Method), Params]
    end.

parse_mf(Request) ->
    #{path := Path} = Request,
    string:tokens(string:sub_string(binary_to_list(Path), 2), "@").

valid_mf(MF) ->
    length(MF) == 2.

parse_url_params(Request) ->
    lists:map(fun ({K, V}) -> {K, V} end, cowboy_req:parse_qs(Request)).
