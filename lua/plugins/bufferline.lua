local init = function()
    for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, function()
            require("bufferline").go_to_buffer(i, true)
        end)
    end

    vim.keymap.set("n", "<leader>" .. 0, function()
        require("bufferline").go_to_buffer(-1, true)
    end)

    vim.keymap.set("n", "<Tab>", function()
        require("bufferline").cycle(1)
    end)
    vim.keymap.set("n", "<S-Tab>", function()
        require("bufferline").cycle(-1)
    end)
end

local config = function()
    require("bufferline").setup({
        options = {
            mode = "buffers",
            numbers = "ordinal",
            indicator = { icon = "" },
            max_name_length = 20,
            max_prefix_length = 2,
            modified_icon = "●",
            persist_buffer_sort = false,
            show_buffer_close_icons = false,
            show_buffer_icons = false,
            show_close_icon = false,
            name_formatter = function(opts)
                return string.format("%s", opts.name)
            end,
        },
    })
end
return {
    "akinsho/nvim-bufferline.lua",
    event = "VeryLazy",
    init = init,
    config = config
}
