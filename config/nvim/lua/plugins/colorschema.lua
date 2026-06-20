return {
  {
    "talha-akram/noctis.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local function set_transparent()
        local groups = {
          "Normal",
          "NormalNC",
          "NormalFloat",
          "FloatBorder",
          "SignColumn",
          "LineNr",
          "EndOfBuffer",
        }
        for _, g in ipairs(groups) do
          vim.api.nvim_set_hl(0, g, { bg = "none" })
        end
      end
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_transparent,
      })
      -- 起動時に既に適用済みのスキームにも反映
      set_transparent()
    end,
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  -- Configure LazyVim to load the active colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized-osaka",
    },
  },
}
