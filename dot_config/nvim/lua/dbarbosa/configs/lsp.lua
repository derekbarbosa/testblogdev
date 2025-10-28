vim.lsp.config('bashls', {
	filetypes = { 'bash',},
})

vim.lsp.config('dockerls', {
	filetypes = { 'Dockerfile', 'dockerfile', 'containerfile',},
	root_markers = {
		'Dockerfile',
		'Containerfile',
	},
})

vim.lsp.config('jsonls', {
	filetypes = { 'json', 'jsonc' },
})

vim.lsp.config('just-lsp', {
	filetypes = { 'justfile', },
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

vim.lsp.config('yamlls', {
	filetypes = { 'yaml', 'yml' },
})
