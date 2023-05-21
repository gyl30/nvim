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
local lsp_highlight_document = function(client, bufnr)
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
local config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(_)
            local keymap = vim.keymap.set

            -- LSP finder - Find the symbol's definition
            -- If there is no definition, it will instead be hidden
            -- When you use an action in finder like "open vsplit",
            -- you can use <C-t> to jump back
            keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>")

            -- Code action
            keymap({ "n", "v" }, "<localleader>ca", "<cmd>Lspsaga code_action<CR>")

            -- Rename all occurrences of the hovered word for the entire file
            keymap("n", "gr", "<cmd>Lspsaga rename<CR>")

            -- Rename all occurrences of the hovered word for the selected files
            keymap("n", "gr", "<cmd>Lspsaga rename ++project<CR>")

            -- Peek definition
            -- You can edit the file containing the definition in the floating window
            -- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
            -- It also supports tagstack
            -- Use <C-t> to jump back
            keymap("n", "gp", "<cmd>Lspsaga peek_definition<CR>")

            -- Go to definition
            keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>")

            -- Peek type definition
            -- You can edit the file containing the type definition in the floating window
            -- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
            -- It also supports tagstack
            -- Use <C-t> to jump back
            keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>")

            -- Go to type definition
            keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>")


            -- Show line diagnostics
            -- You can pass argument ++unfocus to
            -- unfocus the show_line_diagnostics floating window
            keymap("n", "<localleader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>")

            -- Show buffer diagnostics
            keymap("n", "<localleader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")

            -- Show workspace diagnostics
            keymap("n", "<localleader>sw", "<cmd>Lspsaga show_workspace_diagnostics<CR>")

            -- Show cursor diagnostics
            keymap("n", "<localleader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")

            -- Diagnostic jump
            -- You can use <C-o> to jump back to your previous location
            keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
            keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")

            -- Diagnostic jump with filters such as only jumping to an error
            keymap("n", "[E", function()
                require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
            end)
            keymap("n", "]E", function()
                require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
            end)

            -- Toggle outline
            keymap("n", "<localleader>o", "<cmd>Lspsaga outline<CR>")

            -- Hover Doc
            -- If there is no hover doc,
            -- there will be a notification stating that
            -- there is no information available.
            -- To disable it just use ":Lspsaga hover_doc ++quiet"
            -- Pressing the key twice will enter the hover window
            keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>")

            -- If you want to keep the hover window in the top right hand corner,
            -- you can pass the ++keep argument
            -- Note that if you use hover with ++keep, pressing this key again will
            -- close the hover window. If you want to jump to the hover window
            -- you should use the wincmd command "<C-w>w"
            keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>")

            -- Call hierarchy
            keymap("n", "<localleader>ci", "<cmd>Lspsaga incoming_calls<CR>")
            keymap("n", "<localleader>co", "<cmd>Lspsaga outgoing_calls<CR>")

            -- Floating terminal
            keymap({ "n", "t" }, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")
            --local opts = { noremap = true, silent = true }
            --vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
            --vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
            --vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
            --vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
            --vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
            --vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
            --vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
            --vim.keymap.set('n', '<localleader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
            --vim.keymap.set({ 'n', 'x' }, '<localleader>ft', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
            --vim.keymap.set('n', '<localleader>qf', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            --vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
            --vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
            --vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
        end
    })

    local on_attach = function(client, bufnr)
        _ = client;
        _ = bufnr;
        require "lsp_signature".on_attach()
        lsp_highlight_document(client, bufnr)
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
