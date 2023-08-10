local capabilities                                                 = require("cmp_nvim_lsp").default_capabilities(vim
    .lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach                                                    = function(_, bufnr)
    local keymap = vim.keymap.set
    local attach_opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set({ 'n', 'x' }, '<localleader>ft', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', attach_opts)
    keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", attach_opts)
    keymap({ "n", "v" }, "<localleader>ca", "<cmd>Lspsaga code_action<CR>", attach_opts)
    keymap("n", "gr", "<cmd>Lspsaga rename<CR>", attach_opts)
    keymap("n", "gr", "<cmd>Lspsaga rename ++project<CR>", attach_opts)
    keymap("n", "gp", "<cmd>Lspsaga peek_definition<CR>", attach_opts)
    keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", attach_opts)
    keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>", attach_opts)
    keymap("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>", attach_opts)
    keymap("n", "<localleader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>", attach_opts)
    keymap("n", "<localleader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>", attach_opts)
    keymap("n", "<localleader>sw", "<cmd>Lspsaga show_workspace_diagnostics<CR>", attach_opts)
    keymap("n", "<localleader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", attach_opts)
    keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", attach_opts)
    keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", attach_opts)
    keymap("n", "[E",
        function() require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR }) end)
    keymap("n", "]E",
        function() require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR }) end)
    keymap("n", "<localleader>o", "<cmd>Lspsaga outline<CR>", attach_opts)
    keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", attach_opts)
    keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>", attach_opts)
    keymap("n", "<localleader>ci", "<cmd>Lspsaga incoming_calls<CR>", attach_opts)
    keymap("n", "<localleader>co", "<cmd>Lspsaga outgoing_calls<CR>", attach_opts)
    keymap({ "n", "t" }, "<A-d>", "<cmd>Lspsaga term_toggle<CR>", attach_opts)
    require("clangd_extensions.inlay_hints").setup_autocmd()
    require("clangd_extensions.inlay_hints").set_inlay_hints()
    vim.api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = 'rounded',
                source = 'always',
                prefix = ' ',
                scope = 'cursor',
            }
            vim.diagnostic.open_float(nil, opts)
        end
    })
end
local lua_option                                                   = {
    settings = {
        Lua = {
            completion = {
                callSnippet = 'Replace',
            },
        },
    }
}
local clangd_options                                               = {
    settings = {
        clangd = {
            cmd = {
                "clangd",             -- NOTE: 只支持clangd 13.0.0 及其以下版本，新版本会有问题
                "--background-index", -- 后台建立索引，并持久化到disk
                "--clang-tidy",       -- 开启clang-tidy
                -- 指定clang-tidy的检查参数， 摘抄自cmu15445. 全部参数可参考 https://clang.llvm.org/extra/clang-tidy/checks
                "--clang-tidy-checks=bugprone-*, clang-analyzer-*, google-*, modernize-*, performance-*, portability-*, readability-*, -bugprone-too-small-loop-variable, -clang-analyzer-cplusplus.NewDelete, -clang-analyzer-cplusplus.NewDeleteLeaks, -modernize-use-nodiscard, -modernize-avoid-c-arrays, -readability-magic-numbers, -bugprone-branch-clone, -bugprone-signed-char-misuse, -bugprone-unhandled-self-assignment, -clang-diagnostic-implicit-int-float-conversion, -modernize-use-auto, -modernize-use-trailing-return-type, -readability-convert-member-functions-to-static, -readability-make-member-function-const, -readability-qualified-auto, -readability-redundant-access-specifiers,",
                "--completion-style=detailed",
                "--cross-file-rename=true",
                "--header-insertion=iwyu",
                "--pch-storage=memory",
                -- 启用这项时，补全函数时，将会给参数提供占位符，键入后按 Tab 可以切换到下一占位符
                "--function-arg-placeholders=false",
                "--log=verbose",
                "--ranking-model=decision_forest",
                -- 输入建议中，已包含头文件的项与还未包含头文件的项会以圆点加以区分
                "--header-insertion-decorators",
                "-j=12",
                "--pretty",
            }
        }
    }

}

local config                                                       = function()
    local lspconfig = require('lspconfig')

    local lua_lsp_options = vim.tbl_deep_extend("force", lua_option,
        { on_attach = on_attach, capabilities = capabilities, })

    local clangd_lsp_options = vim.tbl_deep_extend("force", clangd_options,
        { on_attach = on_attach, capabilities = capabilities, })
    require("clangd_extensions.config").setup {}
    require("clangd_extensions.ast").init()
    require('neodev').setup {}
    lspconfig.lua_ls.setup(lua_lsp_options)
    lspconfig.clangd.setup(clangd_lsp_options)
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
    })
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
    })
end

return {
    'neovim/nvim-lspconfig', -- Required
    config = config,
    dependencies = {
        {
            'williamboman/mason.nvim',
            build = ":MasonUpdate"
        },
        { 'williamboman/mason-lspconfig.nvim' },
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'L3MON4D3/LuaSnip' },
    }
}
