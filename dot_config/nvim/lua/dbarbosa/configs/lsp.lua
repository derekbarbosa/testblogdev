vim.lsp.config('bashls', {
	filetypes = { 'bash',},
})

vim.lsp.config('css-lsp', {
	filetypes = { 'css', 'scss', 'less',},
})

vim.lsp.config('html-lsp', {
	filetypes = { 'html', 'templ',},
})

vim.lsp.config('jsonls', {
	filetypes = { 'json', 'jsonc' },
})

vim.lsp.config('lua_ls', {
	filetypes = {'lua',},
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = {
					'vim',
					'require',
				},
			},
		},
	},
})

vim.lsp.config('marksman', {
	filetypes = { 'markdown', 'md' },
})

vim.lsp.config('ruby-lsp', {
	filetypes = { 'ruby', 'rb' },
})

vim.lsp.config('yamlls', {
	filetypes = { 'yaml', 'yml' },
})
