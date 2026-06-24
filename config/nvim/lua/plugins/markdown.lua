local config = vim.fn.stdpath("config") .. "/markdownlint.yaml"
return {
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
  -- MarkdownPreview の最大幅 900px を撤廃するカスタム CSS を適用
  {
    "iamcco/markdown-preview.nvim",
    optional = true,
    init = function()
      vim.g.mkdp_markdown_css = vim.fn.stdpath("config") .. "/markdown-preview.css"
    end,
  },
}
