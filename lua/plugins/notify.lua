return {
  "rcarriga/nvim-notify", 
  event = "VimEnter",
  config = function()
      vim.notify = require("notify")
  end
}
