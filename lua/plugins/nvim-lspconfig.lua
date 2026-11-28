vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

--[[ List of enabled language servers. In order to add new languages, you need to do the following:
--     1. Find and install the language server for the language.
--     2. Find the configuration for the language server in nvim-lspconfig in https://github.com/neovim/nvim-lspconfig/tree/master/lsp
--     3. Add the name of it (the name of the file without .lua extension) to below list.
--]]
local language_servers = {
	"bashls",
	"cssls",
	"gopls",
	"html",
	"jsonls",
	"lua_ls",
	"pyright",
	"tailwindcss",
	"ts_ls",
	"yamlls",
	"metals",
	"ruby_lsp",
	"kotlin_lsp",
}

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf, desc = "Go to definition" })
	end,
})

vim.keymap.set("n", "<leader>d", vim.diagnostic.setqflist, { desc = "Diagnostics" })

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		},
	},
})

vim.lsp.config("metals", {
	settings = {
		metals = {
			autoImportBuilds = "all",
		},
	},
})

vim.lsp.enable(language_servers)
