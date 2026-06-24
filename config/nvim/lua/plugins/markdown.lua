local config = vim.fn.stdpath("config") .. "/markdownlint.yaml"
return {
  -- markdown コードブロック内の mermaid をシンタックスハイライト
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "mermaid" } },
  },
  -- 診断(リンター)に --config を渡す
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", config, "-" },
        },
      },
    },
  },
  -- 保存時フォーマッタ(整形)にも同じ --config を渡す
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          prepend_args = { "--config", config },
        },
      },
    },
  },
}
