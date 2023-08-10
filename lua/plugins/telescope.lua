local function is_git_repo()
    vim.fn.system("git rev-parse --is-inside-work-tree")
    return vim.v.shell_error == 0
end
local telescope_builtin = function(builtin, opts)
    local params = { builtin = builtin, opts = opts or {} }


    return function()
        builtin = params.builtin
        opts = params.opts
        if builtin == "files" then
            if is_git_repo() then
                opts.show_untracked = true
                builtin = "git_files"
            else
                builtin = "find_files"
            end
        elseif builtin == "live_grep" then
            local function get_git_root()
                local dot_git_path = vim.fn.finddir(".git", ".;")
                return vim.fn.fnamemodify(dot_git_path, ":h")
            end

            if is_git_repo() then
                opts.cwd = get_git_root()
            end
        end
        require("telescope.builtin")[builtin](opts)
    end
end
local config = function()
    local status_ok, telescope = pcall(require, "telescope")
    if not status_ok then
        vim.notify("telescope not found!")
        return
    end

    local actions = require "telescope.actions"

    -- disable preview binaries
    local previewers = require("telescope.previewers")
    local Job = require("plenary.job")
    local new_maker = function(filepath, bufnr, opts)
        filepath = vim.fn.expand(filepath)
        Job:new({
            command = "file",
            args = { "--mime-type", "-b", filepath },
            on_exit = function(j)
                local mime_type = vim.split(j:result()[1], "/")[1]
                if mime_type == "text" then
                    previewers.buffer_previewer_maker(filepath, bufnr, opts)
                else
                    -- maybe we want to write something to the buffer here
                    vim.schedule(function()
                        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
                    end)
                end
            end
        }):sync()
    end
    telescope.setup {
        defaults = {
            buffer_previewer_maker = new_maker,
            winblend = 10,
            layout_strategy = 'horizontal',
            layout_config = {
                horizontal = { width = 0.9 },
                mirror = false,
                prompt_position = 'top',
            },
            sorting_strategy = 'ascending', -- with prompt_position='top'

            prompt_prefix = " ",
            selection_caret = " ",
            path_display = {
                shorten = {
                    len = 3,
                    exclude = { 1, -1 }
                },
            },

        },
        pickers = {
            find_files = {
                theme = "dropdown",
                previewer = true,
                find_command = { "fd", "-H", "-I" }, -- "-H" search hidden files, "-I" do not respect to gitignore
            },

        },
        extensions = {
            fzf = {
                fuzzy = true,                   -- false will only do exact matching
                override_generic_sorter = true, -- override the generic sorter
                override_file_sorter = true,    -- override the file sorter
                case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                -- the default case_mode is "smart_case"
            },
            ["ui-select"] = {
                require("telescope.themes").get_dropdown {
                    -- even more opts
                }
            },
            live_grep_raw = {
                auto_quoting = false, -- enable/disable auto-quoting
            }
        },
    }

    -- telescope.load_extension("frecency")
    telescope.load_extension('fzf')
    telescope.load_extension("ui-select")
    -- telescope.load_extension('vim_bookmarks')
    telescope.load_extension("live_grep_args")
    -- load project extension. see project.lua file
end
return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",

        dependencies = {
            { 'nvim-telescope/telescope-fzf-native.nvim', build = "make" },
            { "nvim-telescope/telescope-ui-select.nvim" },
            "nvim-telescope/telescope-rg.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",


        },
        keys = {
            {
                "<leader>,",
                telescope_builtin("buffers", { show_all_buffers = true }),
                desc = "Switch Buffer"
            },
            {
                "<leader>fb",
                telescope_builtin("buffers"),
                desc = "Buffers"
            },
            {
                "<leader>:",
                telescope_builtin("command_history"),
                desc = "Command History"
            },
            -- find
            {
                "<leader><space>",
                telescope_builtin("files"),
                desc = "Find Files (root dir)"
            },
            {
                "<leader>ff",
                telescope_builtin("files"),
                desc = "Find Files (root dir)"
            },
            {
                "<leader>fr",
                telescope_builtin("oldfiles"),
                desc = "Recent"
            },
            -- git
            {
                "<leader>gc",
                telescope_builtin("git_commits"),
                desc = "commits"
            },
            {
                "<leader>gs",
                telescope_builtin("git_status"),
                desc = "status"
            },
            -- search
            {
                "<leader>sa",
                telescope_builtin("autocommands"),
                desc = "Auto Commands"
            },
            {
                "<leader>sb",
                telescope_builtin("current_buffer_fuzzy_find"),
                desc = "Buffer"
            },
            {
                "<leader>sc",
                telescope_builtin("command_history"),
                desc = "Command History"
            },
            {
                "<leader>sC",
                telescope_builtin("commands"),
                desc = "Commands"
            },
            {
                "<leader>/",
                telescope_builtin("live_grep"),
                desc = "Find in Files (Grep)"
            },
            {
                "<leader>sg",
                telescope_builtin("live_grep"),
                desc = "Grep (root dir)"
            },
            {
                "<leader>sh",
                telescope_builtin("help_tags"),
                desc = "Help Pages"
            },
            {
                "<leader>sH",
                telescope_builtin("highlights"),
                desc = "Search Highlight Groups"
            },
            {
                "<leader>sk",
                telescope_builtin("keymaps"),
                desc = "Key Maps"
            },
            {
                "<leader>sM",
                telescope_builtin("man_pages"),
                desc = "Man Pages"
            },
            {
                "<leader>sm",
                telescope_builtin("marks"),
                desc = "Jump to Mark"
            },
            {
                "<leader>so",
                telescope_builtin("vim_options"),
                desc = "Options"
            },
            {
                "<leader>sw",
                telescope_builtin("grep_string"),
                desc = "Word (root dir)"
            },
            {
                "<leader>uC",
                telescope_builtin("colorscheme", { enable_preview = true }),
                desc = "Colorscheme with preview"
            },
            {
                "<leader>ss",
                telescope_builtin("lsp_document_symbols"),
                desc = "List Symbols (current buffer)",
            },
            {
                "<leader>sS",
                telescope_builtin("lsp_workspace_symbols"),
                desc = "List Symbols (Workspace)",
            },
            {
                "<leader>sr",
                telescope_builtin("lsp_references"),
                desc = "List LSP references for word under the cursor",
            },
            {
                "<leader>R",
                telescope_builtin("resume"),
                desc = "Resume"
            },
            {
                "<leader>sd",
                telescope_builtin("diagnostics", { bufnr = 0 }),
                desc = "Lists Diagnostics for the current buffer"
            },
            {
                "<leader>sD",
                telescope_builtin("diagnostics"),
                desc = "Lists all Diagnostics for all open buffers"
            },
        },
        config = config,
        opts = function()
            local actions = require("telescope.actions")
            return {
                defaults = {
                    prompt_prefix = " ",
                    selection_caret = " ",
                    mappings = {
                        i = {
                            ["<C-[>"] = actions.close,
                            ["<c-t>"] = function(...)
                                return require("trouble.providers.telescope").open_with_trouble(...)
                            end,
                            ["<a-t>"] = function(...)
                                return require("trouble.providers.telescope").open_selected_with_trouble(...)
                            end,
                            ["<a-i>"] = function()
                                telescope_builtin("find_files", { no_ignore = true })()
                            end,
                            ["<a-h>"] = function()
                                telescope_builtin("find_files", { hidden = true })()
                            end,
                            ["<C-Down>"] = function(...)
                                return require("telescope.actions").cycle_history_next(...)
                            end,
                            ["<C-Up>"] = function(...)
                                return require("telescope.actions").cycle_history_prev(...)
                            end,
                            ["<C-f>"] = function(...)
                                return require("telescope.actions").preview_scrolling_down(...)
                            end,
                            ["<C-b>"] = function(...)
                                return require("telescope.actions").preview_scrolling_up(...)
                            end,
                        },
                        n = {
                            ["q"] = function(...)
                                return require("telescope.actions").close(...)
                            end,
                            ["<C-[>"] = actions.close,
                        },
                    },
                    winblend = 10,
                    layout_strategy = 'horizontal',
                    layout_config = {
                        horizontal = { width = 0.9 },
                        mirror = false,
                        prompt_position = 'top',
                    },
                    sorting_strategy = 'ascending', -- with prompt_position='top'
                    vimgrep_arguments = (function()
                        if is_git_repo() then
                            return { "git", "grep", "--full-name", "--line-number", "--column", "--extended-regexp",
                                "--ignore-case",
                                "--no-color", "--recursive", "--recurse-submodules", "-I" }
                        else
                            return {
                                "grep", "--extended-regexp", "--color=never", "--with-filename", "--line-number",
                                "-b", -- grep doesn't support a `--column` option :(
                                "--ignore-case", "--recursive", "--no-messages", "--exclude-dir=*cache*",
                                "--exclude-dir=*.git",
                                "--exclude=.*", "--binary-files=without-match"
                            }
                        end
                    end)()
                },
            }
        end
    },
}
