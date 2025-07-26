local ok_status, lspconfig = pcall(require, "nvim-lspconfig")

if not ok_status then
	return
end


-- Case 1. For CMake Users
--	$ cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
-- Case 2. For Bazel Users, use https://github.com/hedronvision/bazel-compile-commands-extractor
-- Case 3. If you don't use any build tool and all files in a project use the same build flags
--	Place your compiler flags in the compile_flags.txt file, located in the root directory 
--	of your project. Each line in the file should contain a single compiler flag.
-- src: https://clangd.llvm.org/installation#compile_commansjson
lspconfig.clangd.setup({})
lspconfig.gopls.setup({})
lspconfig.bashls.setup({})
lspconfig.rust_analyzer.setup({})
lspconfig.hls.setup({})
lspconfig.ocamllsp.setup({})
lspconfig.ruby_lsp.setup({})
-- src: https://docs.astral.sh/ruff/editors/setup/#neovim
lspconfig.ruff.setup({})
lspconfig.ts_ls.setup({})
lspconfig.fsautocomplete.setup({})
-- Run this first: julia --project=~/.julia/environment/nvim-lspconfig -e 'using Pkg; Pkg.add("LauguageServer")'
lspconfig.julials.setup({})
lspconfig.elixirls.setup({
	-- Note: The cmd must be set and the $HOME and ~ are not expanded.
	cmd = { "/Users/chuanghs/.local/share/nvim/mason/packages/exlixir-ls/language_server.sh" },
})
lspconfig.tinymist.setup({
	settings = {
		formatterMode = "typstyle",
		exportPdf = "onType",
		semanticTokens = "disable",
	},
})
lspconfig.pylsp.setup({
	settings = {
		-- configure plugins in pylsp
		pylsp = {
			plugins = {
				pyflakes = { enabled = false },
				pylint = { enabled = false },
				pycodestyle = { enabled = false },
			},
		},
	},
})
lspconfig.lua_ls.setup({
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				global = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = fase,
			},
		},
	},
})
