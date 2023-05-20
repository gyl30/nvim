return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
        { 'neovim/nvim-lspconfig' }, -- Required
        { "p00f/clangd_extensions.nvim" },
        {
            'williamboman/mason.nvim',
            build = function()
                pcall(vim.cmd, 'MasonUpdate')
            end,
        },
        { 'williamboman/mason-lspconfig.nvim' }, -- Optional

        { 'hrsh7th/nvim-cmp' },                  -- Required
        { 'hrsh7th/cmp-nvim-lsp' },              -- Required
        { 'L3MON4D3/LuaSnip' },                  -- Required
    },
    config = function()
        require("neodev").setup({})
        local lsp = require('lsp-zero').preset({
            manage_nvim_cmp = {
                set_sources = 'recommended',
                set_basic_mappings = true,
                set_extra_mappings = false,
                use_luasnip = true,
                set_format = true,
                documentation_window = true,
            }
        })
        lsp.on_attach(function(client, bufnr)
            lsp.default_keymaps({ buffer = bufnr })
            local opts = { buffer = true }
            vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
            vim.keymap.set({ 'n', 'x' }, '<leader>ft', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
            vim.keymap.set('n', '<localleader>qf', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        end)
        lsp.format_on_save({
            format_opts = {
                async = false,
                timeout_ms = 10000,
            },
            servers = {
                ['lua_ls'] = { 'lua' },
                ['rust_analyzer'] = { 'rust' },
                ['clangd'] = { 'cpp', 'c', 'cc', 'h', 'hpp' },
            }
        })
        require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
        lsp.set_sign_icons({
            error = '✘',
            warn = '▲',
            hint = '⚑',
            info = '»'
        })
        lsp.omnifunc.setup({
            tabcomplete = true,
            use_fallback = true,
            update_on_delete = true,
        })
        lsp.skip_server_setup({ 'clangd' })
        lsp.setup()
        require('lsp-zero').extend_lspconfig()
        require('clangd_extensions').setup()
        require('luasnip.loaders.from_vscode').lazy_load()
        local lspkind = require("lspkind")
        local cmp = require('cmp')
        local cmp_action = require('lsp-zero').cmp_action()
        local types = require('cmp.types')
        cmp.setup({
            preselect = require('cmp').PreselectMode.None,
            confirmation = {
                default_behavior = types.cmp.ConfirmBehavior.Replace,
            },
            completion = {
                completeopt = "menu, menuone, noinsert, noselect"
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            sources = {
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'nvim_lua' },
                { name = 'buffer',  keyword_length = 3 },
                { name = 'luasnip', keyword_length = 2 },
            },
            formatting = {
                format = lspkind.cmp_format({
                    mode = 'symbol',
                    maxwidth = 50,
                })
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            mapping = {
                ['<Tab>'] = cmp_action.luasnip_supertab(),
                ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
                --['<Tab>'] = cmp_action.tab_complete(),
                --['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
                ['<C-f>'] = cmp_action.luasnip_jump_forward(),
                ['<C-b>'] = cmp_action.luasnip_jump_backward(),
            }
        })
    end
}
