return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 2000,

    config = function()
      require("catppuccin").setup({
        transparent_background = false, 
      })
      vim.cmd.colorscheme "catppuccin"
    end
  }
}
