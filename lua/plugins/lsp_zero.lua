return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
        { 'neovim/nvim-lspconfig' }, -- Required
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
                set_sources = 'lsp',
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
        require('lsp-zero').extend_lspconfig()
        local tailwind_formatter = require("tailwindcss-colorizer-cmp").formatter
        local lspkind = require("lspkind")
        lsp.setup()
        local cmp = require('cmp')
        local cmp_action = require('lsp-zero').cmp_action()
        local types = require('cmp.types')
        cmp.setup({
            preselect = 'item',
            confirmation = {
                default_behavior = types.cmp.ConfirmBehavior.Replace,
            },
            completion = {
                completeopt = 'menu,menuone,noinsert'
            },
            formatting = {
                format = lspkind.cmp_format({
                    mode = 'symbol',
                    maxwidth = 50,
                    before = tailwind_formatter,
                })
            },

            mapping = {
                ['<Tab>'] = cmp_action.tab_complete(),
                ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
            }
        })
    end
}
