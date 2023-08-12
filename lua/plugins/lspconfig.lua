vim.lsp.set_log_level 'trace'
require('vim.lsp.log').set_format_func(vim.inspect)
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

local on_attach = function(client, bufnr)
    require('lsp-status').on_attach(client)
    if client.server_capabilities.semanticTokensProvider then
        vim.api.nvim_create_autocmd("TextChanged", {
            group = vim.api.nvim_create_augroup("semantic_tokens", { clear = true }),
            buffer = bufnr,
            callback = function()
                vim.lsp.semantic_tokens.force_refresh(bufnr)
            end,
        })
        --vim.notify(client.name .. " semantic tokens start client " .. client["id"] .. " on buffer " .. bufnr)
        vim.lsp.semantic_tokens.start(bufnr, client["id"], {})
    end
    if client.name == "clangd" then
        require("clangd_extensions").setup()
    end
    if client.server_capabilities.documentSymbolProvider then
        require("nvim-navic").attach(client, bufnr)
    end
    require("symbols-outline").setup()
    --vim.notify(client.name .. " on attach client " .. client["id"] .. " on buffer " .. bufnr)
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
    local opts = { buffer = bufnr, noremap = true, silent = true }
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
    vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
    vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
    vim.keymap.set('n', '<space>d', builtin.diagnostics, opts)
    vim.keymap.set('n', '<space>o', "<cmd>SymbolsOutline<CR>", opts)

    vim.api.nvim_create_autocmd("CursorHold,CursorHoldI,InsertLeave", {
        callback = function() vim.api.nvim_command "silent! vim.lsp.codelens.refresh()" end,
        buffer = bufnr,
    })

    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd("CursorMoved", {
            callback = vim.lsp.buf.clear_references,
            buffer = bufnr,
        })
        vim.api.nvim_create_autocmd("CursorHold,CursorHoldI", {
            callback = vim.lsp.buf.document_highlight,
            buffer = bufnr,
        })
    end
end

local lua_ls_options = {
    on_attach = on_attach,
    on_init = on_init,
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
                checkThirdParty = false,
            },
        }
    }
}
local gopls_options = {
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod" },
    on_attach = on_attach,
    on_init = on_init,
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
    on_init = on_init,
    on_new_config = function(new_config, new_cwd)
        local status, cmake = pcall(require, "cmake-tools")
        if status then
            cmake.clangd_on_new_config(new_config)
        end
    end,
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
                "--completion-style=detailed",
                "--cross-file-rename=true",
                "--header-insertion=iwyu",
                "--pch-storage=memory",
                "--function-arg-placeholders=false",
                "--log=verbose",
                "--ranking-model=decision_forest",
                "--header-insertion-decorators",
                "-j=12",
                "--pretty",
            }
        }
    }
}

local config = function()
    require("neodev").setup({})
    require('lsp-status').register_progress()
    local lspconfig = require 'lspconfig'
    local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
    lsp_capabilities = vim.tbl_extend('force', lsp_capabilities or {}, require('lsp-status').capabilities)
    lsp_capabilities = vim.tbl_extend('force', require('cmp_nvim_lsp').default_capabilities() or {}, lsp_capabilities)
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
        { 'nvim-lua/lsp-status.nvim' },
        { 'p00f/clangd_extensions.nvim' },
        { 'Civitasv/cmake-tools.nvim' },
        { 'simrat39/symbols-outline.nvim' },
        {
            'aznhe21/actions-preview.nvim',
            event = "LspAttach",
            config = function()
                vim.keymap.set({ "v", "n" }, "<space>ca", require("actions-preview").code_actions)
                require("actions-preview").setup {
                    backend = { "telescope" },
                    telescope = {
                        sorting_strategy = "ascending",
                        layout_strategy = "vertical",
                        layout_config = {
                            width = 0.8,
                            height = 0.9,
                            prompt_position = "top",
                            preview_cutoff = 20,
                            preview_height = function(_, _, max_lines)
                                return max_lines - 15
                            end,
                        },
                    },
                }
            end
        },
        {
            'SmiteshP/nvim-navic',
            event = "LspAttach",
            config = function()
                require("nvim-navic").setup()
            end
        },
    }
}
