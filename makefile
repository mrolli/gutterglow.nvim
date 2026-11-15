.PHONY: test fmt lint

deps/mini.nvim:
	git clone --filter=blob:none --depth 1 https://github.com/nvim-mini/mini.nvim $@

test: deps/mini.nvim
	nvim --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run()"

fmt:
	stylua .

lint:
	stylua --check .
