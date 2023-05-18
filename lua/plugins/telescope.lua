return { 
  'nvim-telescope/telescope.nvim', 
  tag = '0.1.1', 
  dependencies = { 'nvim-lua/plenary.nvim' } ,
  cmd = "Telescope",
  keys = {
    {"<leader>f",":Telescope find_files<cr>",desc = "find files"}
  }
}
