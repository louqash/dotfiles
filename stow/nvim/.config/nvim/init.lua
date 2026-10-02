if vim.fn.has("nvim-0.11.3") == 0 or vim.fn.has("nvim-0.12") == 1 then
  error("This configuration uses Neovim 0.11.x. Run install/neovim.sh and use ~/.local/bin/nvim.")
end
require("louqash")
