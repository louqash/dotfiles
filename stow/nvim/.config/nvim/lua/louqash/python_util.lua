local M = {}

local function python_in(environment)
  if not environment or environment == "" then return nil end
  for _, suffix in ipairs({ "/bin/python", "/Scripts/python.exe" }) do
    local python = environment .. suffix
    if vim.fn.executable(python) == 1 then return python end
  end
end

function M.get_python_executable(root)
  root = root or vim.fn.getcwd()
  -- Prefer the project's environment over an unrelated activated environment.
  for _, name in ipairs({ ".venv", "venv", "build/venv", "build/.venv" }) do
    local python = python_in(root .. "/" .. name)
    if python then return python end
  end
  local active = python_in(vim.env.VIRTUAL_ENV) or python_in(vim.env.CONDA_PREFIX)
  if active then return active end
  if vim.fn.executable("poetry") == 1 then
    local result = vim.system({ "poetry", "env", "info", "--executable" }, {
      cwd = root, text = true,
    }):wait()
    if result.code == 0 then
      local python = vim.trim(result.stdout or "")
      if vim.fn.executable(python) == 1 then return python end
    end
  end
  for _, name in ipairs({ "python3", "python" }) do
    local python = vim.fn.exepath(name)
    if python ~= "" then return python end
  end
end

return M
