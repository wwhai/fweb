
REBAR_GIT_CLONE_OPTIONS += --depth 1
export REBAR_GIT_CLONE_OPTIONS

REBAR = rebar3
all: compile

compile:
	$(REBAR) compile

ct: compile
	$(REBAR) ct -v --name fweb@127.0.0.1

eunit: compile
	$(REBAR) as test eunit

dialyzer:
	$(REBAR) dialyzer

xref:
	$(REBAR) xref

proper:
	$(REBAR) proper -d test/props

cover:
	$(REBAR) cover

clean:
	@rm -rf _build
