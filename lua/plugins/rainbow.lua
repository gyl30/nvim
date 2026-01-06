return {
  'luochen1990/rainbow',
  event = { 'BufReadPre', 'BufNewFile' },
  init = function()
    vim.g.rainbow_active = 1
  end,
  config = function()
    vim.cmd('RainbowToggleOn')
  end,
}
