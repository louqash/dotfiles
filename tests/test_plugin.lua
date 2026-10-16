-- Verify dotfiles resolve and load the standalone local lazy.nvim plugin.
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/config/nvim")
local found = false
package.loaded.lazy = { setup = function(specs)
  for _, spec in ipairs(specs) do
    if type(spec) == "table" and spec[1] == "louqash/farwork.nvim" then
      assert(spec.dir, "Clone farwork.nvim to ~/farwork.nvim before running this test")
      assert(vim.fn.isdirectory(spec.dir .. "/lua/farwork") == 1)
      vim.opt.rtp:prepend(spec.dir)
      spec.config()
      found = true
    end
  end
end }
require("louqash.lazy")
assert(found and vim.fn.exists(":RemoteStart") == 2)
assert(require("farwork").status().upload.enabled == false)
print("PASS: dotfiles Farwork loading and command registration")
vim.cmd("qa!")
