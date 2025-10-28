require("dbarbosa.configs.lsp")

require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})

require('mason-tool-installer').setup({
	ensure_installed = {
		"bashls",
		"css-lsp",
		"html-lsp",
		"jsonls",
		"lua_ls",
		"marksman",
		"yamlls",
	},
})


-- Setup LSP Attachment keybinds here
local augroup = vim.api.nvim_create_augroup
local dbarbosa = augroup('dbarbosa', {})
local autocmd = vim.api.nvim_create_autocmd

autocmd('LspAttach', {
	group = dbarbosa,
	callback = function(e)
		local opts = { buffer = e.buf }
		vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
		vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
		vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
		vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
		vim.keymap.set("n", "gy", function() vim.lsp.buf.type_definition() end, opts)
		vim.keymap.set("n", "gn", function() vim.diagnostic.goto_next() end, opts)
		vim.keymap.set("n", "gp", function() vim.diagnostic.goto_prev() end, opts)
		vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
		vim.keymap.set("n", "<leader>fmt", function() vim.lsp.buf.format() end, opts)
		vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts)
		vim.keymap.set("n", "<leader>dl", function() vim.diagnostic.open_float(0, { scope = "line" }) end, opts)
		vim.keymap.set("n", "<leader>do", function() vim.diagnostic.open_float(0, { scope = "cursor" }) end, opts)
		vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
		vim.keymap.set({ "n", "v" }, "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
	end
})
