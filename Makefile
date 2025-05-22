REBAR?=rebar3

all: compile

compile:
	@$(REBAR) compile

clean:
	@$(REBAR) clean

test:
	@$(REBAR) eunit -v -c
	@$(REBAR) ct -v -c
	@$(REBAR) cover -v

xref:
	@$(REBAR) xref

check-format:
	@echo "Checking format..."
	@$(REBAR) format -v

format:
	@$(REBAR) format

checks: xref check-format

.PHONY: all compile clean test xref checks format check-format
