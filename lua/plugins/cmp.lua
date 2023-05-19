
function config()
    local cmp = require("cmp")
    cmp.setup({
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        preselect = cmp.PreselectMode.None,
        mapping = {
            ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
            ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
            ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
            ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
            ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
            ["<C-l>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
            ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            ["<C-e>"] = cmp.mapping({
                i = cmp.mapping.abort(),
                c = cmp.mapping.close(),
            }),
            ["<CR>"] = cmp.mapping.confirm({ select = false }),
        },
        sources = cmp.config.sources({
            { name = "path" },
            { name = "nvim_lsp" },
            { name = "buffer" },
            { name = "omni",      priority = -1 },
        }),
        formatting = {
            format = function(entry, vim_item)
                vim_item.menu = ({
                    buffer = "[Buf]",
                    path = "[Path]",
                    cmdline = "[Cmd]",
                    nvim_lsp = "[Lsp]",
                    tmux = "[Tmux]",
                    omni = "[Omni]",
                })[entry.source.name]
                vim_item.dup = ({
                    nvim_lsp = 0,
                    buffer = 1,
                    path = 1,
                })[entry.source.name] or 0
                return vim_item
            end,
        },
    })

    cmp.setup.cmdline("/", {
        sources = {
            { name = "buffer" },
        },
    })

    cmp.setup.cmdline(":", {
        sources = cmp.config.sources({
            { name = "path" },
            { name = "cmdline" },
        }),
    })
end
return  {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        config = config,
        version = false, -- last release is way too old
        dependencies = {
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-cmdline" },
            { "hrsh7th/cmp-omni" },
            { "uga-rosa/cmp-dictionary" },
        },
  }
