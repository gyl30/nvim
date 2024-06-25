vim.lsp.set_log_level 'trace'
require('vim.lsp.log').set_format_func(vim.inspect)
vim.lsp.set_log_level("off")

local outline_symbols = {
    File = { icon = " ", hl = "@text.uri" },
    Module = { icon = " ", hl = "@namespace" },
    Namespace = { icon = " ", hl = "@namespace" },
    Package = { icon = " ", hl = "@namespace" },
    Class = { icon = " ", hl = "@type" },
    Method = { icon = " ", hl = "@method" },
    Property = { icon = " ", hl = "@method" },
    Field = { icon = " ", hl = "@field" },
    Constructor = { icon = " ", hl = "@constructor" },
    Enum = { icon = " ", hl = "@type" },
    Interface = { icon = " ", hl = "@type" },
    Function = { icon = "󰡱 ", hl = "@function" },
    Variable = { icon = " ", hl = "@constant" },
    Constant = { icon = " ", hl = "@constant" },
    String = { icon = "󰅳 ", hl = "@string" },
    Number = { icon = "󰎠 ", hl = "@number" },
    Boolean = { icon = " ", hl = "@boolean" },
    Array = { icon = "󰅨 ", hl = "@constant" },
    Object = { icon = " ", hl = "@type" },
    Key = { icon = " ", hl = "@type" },
    Null = { icon = "󰟢 ", hl = "@type" },
    EnumMember = { icon = " ", hl = "@field" },
    Struct = { icon = " ", hl = "@type" },
    Event = { icon = " ", hl = "@type" },
    Operator = { icon = " ", hl = "@operator" },
    TypeParameter = { icon = " ", hl = "@parameter" },
    Component = { icon = " ", hl = "@function" },
    Fragment = { icon = " ", hl = "@constant" },
}

vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.reset(ns, bufnr)
    return true
end

vim.diagnostic.config {
    virtual_text = false,
    underline = false,
    update_in_insert = false,
    float = {
        focused = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
}
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local on_attach = function(client, bufnr)
    if client.name == "clangd" then
        require("clangd_extensions").setup()
    end

    require("symbols-outline").setup({
        symbols = outline_symbols,
        show_symbol_details = true,
        autofold_depth = 3,
    })
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    vim.lsp.inlay_hint.enable()
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd("CursorMoved", {
            callback = vim.lsp.buf.clear_references,
            buffer = bufnr,
        })
    end
end

local lua_ls_options = {
    on_attach = on_attach,
    settings = {
        Lua = {
            telemetry = { enable = false },
            runtime = {
                version = "LuaJIT",
                special = {
                    reload = "require",
                },
            },
            diagnostics = {
                globals = { "vim", "reload" },
            },
            completion = {
                callSnippet = "Replace"
            },
            workspace = {
                library = {
                    [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                    [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                    [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        }
    }
}
local gopls_options = {
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod" },
    on_attach = on_attach,
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
    },
    settings = {
        gopls = {
            staticcheck = true,
            semanticTokens = true,
            usePlaceholders = true,
            completeUnimported = true,
            gofumpt = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
            },
            analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
            },
            hints = {
                assignVariableTypes = false,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                constantValues = false,
                functionTypeParameters = false,
                parameterNames = false,
                rangeVariableTypes = false,
            },
        },
    },
}
local clangd_options = {
    on_attach = on_attach,
    settings = {
        clangd = {
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--clang-tidy-checks=bugprone-*, clang-analyzer-*, google-*, modernize-*, performance-*, portability-*, readability-*, -bugprone-too-small-loop-variable, -clang-analyzer-cplusplus.NewDelete, -clang-analyzer-cplusplus.NewDeleteLeaks, -modernize-use-nodiscard, -modernize-avoid-c-arrays, -readability-magic-numbers, -bugprone-branch-clone, -bugprone-signed-char-misuse, -bugprone-unhandled-self-assignment, -clang-diagnostic-implicit-int-float-conversion, -modernize-use-auto, -modernize-use-trailing-return-type, -readability-convert-member-functions-to-static, -readability-make-member-function-const, -readability-qualified-auto, -readability-redundant-access-specifiers,",
                "--all-scopes-completion",
                "--completion-style=detailed",
                "--cross-file-rename=true",
                "--pch-storage=memory",
                "--completion-parse=auto",
                "--function-arg-placeholders=false",
                "--ranking-model=decision_forest",
                "--pretty",
                "--compile-commands-dir=build",
                "--header-insertion-decorators",
                "--enable-config",
                "--pretty",
            }
        }
    }
}

local config = function()
    require("neodev").setup({})
    local lspconfig = require 'lspconfig'
    local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
    lsp_capabilities = vim.tbl_extend('force', require('cmp_nvim_lsp').default_capabilities() or {}, lsp_capabilities)
    lsp_capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }
    lsp_capabilities.textDocument.completion.completionItem = {
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
    gopls_options.capabilities = lsp_capabilities
    clangd_options.capabilities = lsp_capabilities
    lua_ls_options.capabilities = lsp_capabilities
    lspconfig.gopls.setup(gopls_options)
    lspconfig.clangd.setup(clangd_options)
    lspconfig.lua_ls.setup(lua_ls_options)
end

return {
    'neovim/nvim-lspconfig',
    config = config,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'L3MON4D3/LuaSnip' },
        { 'p00f/clangd_extensions.nvim' },
        { 'Civitasv/cmake-tools.nvim' },
        {
            'ray-x/lsp_signature.nvim',
            config = function()
                require 'lsp_signature'.setup()
            end
        },
        {
            'simrat39/symbols-outline.nvim',
            cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen' },
            keys = {
                {
                    '<Leader>o',
                    mode = { 'n' },
                    silent = true,
                    '<cmd>SymbolsOutline<CR>',
                    desc = 'Symbols Outline'
                },
            },
        },
    }
}
