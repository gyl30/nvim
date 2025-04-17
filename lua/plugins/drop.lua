return {
  "folke/drop.nvim",
  event = "UIEnter",
  config = function()
    require("drop").setup()
  end,
}
