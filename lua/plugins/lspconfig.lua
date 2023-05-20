local options = {
    servers = {
        bashls = {
            filetypes = { "bash", "sh" },
        },
        clangd = {
            cmd = {
                "clangd",
                "--clang-tidy",
                "--completion-style=detailed",
                "--cross-file-rename=true",
                "--pch-storage=memory",
                "--function-arg-placeholders=false",
                "--log=verbose",
                "--ranking-model=decision_forest",
                "--header-insertion-decorators",
                "--pretty",
            },
            filetypes = { "c", "cpp" },
        },
        lua_ls = {
            settings = {
                Lua = {
                    workspace = {
                        checkThirdParty = false,
                    },
                    completion = {
                        callSnippet = "Replace",
                    },
                },
            },
        },
    },
    setup = {
        lua_ls = function(server, opts)
            require("neodev").setup()
            require("lspconfig")[server].setup(opts)
        end
    },
}
local lsp_highlight_document = function(client)
    local status_ok, highlight_supported = pcall(function()
        return client.supports_method('textDocument/documentHighlight')
    end)
    if not status_ok or not highlight_supported then
        return
    end

    local group_name = 'lsp_document_highlight'
    local ok, hl_autocmds = pcall(vim.api.nvim_get_autocmds, {
        group = group_name,
        buffer = bufnr,
        event = 'CursorHold',
    })

    if ok and #hl_autocmds > 0 then
        return
    end

    vim.api.nvim_create_augroup(group_name, { clear = false })
    vim.api.nvim_create_autocmd('CursorHold', {
        group = group_name,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd('CursorMoved', {
        group = group_name,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
    })
end
local format_on_save = function(client, bufnr, format_opts)
    local format_group = 'lsp_sync_format'
    local autocmd = vim.api.nvim_create_autocmd
    local augroup = vim.api.nvim_create_augroup
    local format_id = augroup(format_group, { clear = false })

    client = client or {}
    format_opts = format_opts or {}
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })

    if vim.b.lsp_zero_enable_autoformat == nil then
        vim.b.lsp_zero_enable_autoformat = 1
    end

    local config = vim.tbl_deep_extend(
        'force',
        { timeout_ms = 1000 },
        format_opts,
        {
            async = false,
            name = client.name,
            bufnr = bufnr,
        }
    )

    local apply_format = function()
        local autoformat = vim.b.lsp_zero_enable_autoformat
        local enabled = (autoformat == 1 or autoformat == true)
        if not enabled then
            return
        end

        vim.lsp.buf.format(config)
    end

    local desc = 'Format current buffer'

    if client.name then
        desc = string.format('Format buffer with %s', client.name)
    end

    autocmd('BufWritePre', {
        group = format_id,
        buffer = bufnr,
        desc = desc,
        callback = apply_format
    })
end
local config = function()
    local lspconfig = require('lspconfig')


    vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
            local opts = { noremap = true, silent = true }

            vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
            vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
            vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
            vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
            vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
            vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
            vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
            vim.keymap.set('n', '<localleader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
            vim.keymap.set({ 'n', 'x' }, '<localleader>ft', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
            vim.keymap.set('n', '<localleader>qf', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
            vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
            vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
        end
    })

    local on_attach = function(client, bufnr)
        _ = client;
        _ = bufnr;
        require "lsp_signature".on_attach()
        lsp_highlight_document(client)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format { async = false }
            end
        })
    end


    local function setup(server, server_config)
        if options.setup[server] then
            if options.setup[server](server, server_config) then
                return
            end
        end
        require("lspconfig")[server].setup(server_config)
    end

    local servers = options.servers
    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }
    capabilities.textDocument.completion.completionItem = {
        documentationFormat = { "markdown", "plaintext" },
        snippetSupport = true,
        preselectSupport = true,
        insertReplaceSupport = true,
        labelDetailsSupport = true,
        deprecatedSupport = true,
        commitCharactersSupport = true,
        tagSupport = { valueSet = { 1 } },
        resolveSupport = {
            properties = {
                "documentation",
                "detail",
                "additionalTextEdits",
            },
        },
    }

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
    })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
    })
    for server, _ in pairs(servers) do
        local server_config = vim.tbl_deep_extend("force", {
            capabilities = vim.deepcopy(capabilities),
            on_attach = on_attach,
        }, servers[server] or {})
        setup(server, server_config)
    end
end

return {
    'neovim/nvim-lspconfig', -- Required
    config = config,
    dependencies = {
        {
            'williamboman/mason.nvim',
            build = function()
                pcall(vim.cmd, 'MasonUpdate')
            end,
        },
        { 'williamboman/mason-lspconfig.nvim' },
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'L3MON4D3/LuaSnip' },
    }
}
