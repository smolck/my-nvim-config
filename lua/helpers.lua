local api = vim.api
local M = {}

-- @param maps table of form { [{mode, lhs}] = { rhs, opts }, ['default_opts'] = { ... } }
function M.set_keymaps(maps)
  local default_opts = maps['default_opts']
  vim.validate({ ['default_opts'] = { default_opts, 'table' } })
  maps['default_opts'] = nil

  for mode_and_lhs, mapping in pairs(maps) do
    if type(mapping) == 'string' then
      api.nvim_set_keymap(mode_and_lhs[1], mode_and_lhs[2], mapping, default_opts)
    else
      local opts = mapping[2] or default_opts
      api.nvim_set_keymap(mode_and_lhs[1], mode_and_lhs[2], mapping[1], opts)
    end
  end
end

function M.set_opts()
    local function set_opt(opt)
        if type(opt) == 'table' then
            vim.opt[opt[1]] = opt[2]
        else
            vim.opt[opt] = true
        end

	return set_opt
    end

    return set_opt
end

return M
