-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- ソフトラップ（画面端での折り返し）
vim.opt.wrap = true -- 画面端で折り返す
vim.opt.linebreak = true -- 単語の途中で折り返さない
vim.opt.breakindent = true -- 折り返し行のインデントを揃える

-- スペルチェック: 英語のtypoはチェックしつつ、日本語(CJK)は誤検出させない
vim.opt.spelllang = { "en", "cjk" }
