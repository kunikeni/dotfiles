vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- 行番号の表示
vim.opt.number = true
vim.wo.number = true
vim.wo.relativenumber = false

-- タブとインデントの設定
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

-- 検索設定
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ビジュアル設定
vim.opt.cursorline = true

-- spell check
vim.opt.spell = true

-- カーソル移動
vim.opt.whichwrap = 'b,s,<,>,[,]'
--マウス操作を有効化
vim.opt.mouse = 'a'

vim.opt.title = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 2
vim.opt.laststatus = 2
vim.opt.scrolloff = 10
vim.opt.shell = 'fish'
vim.opt.inccommand = 'split'
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.wrap = true
vim.opt.helplang = 'ja', 'en'
vim.opt.updatetime = 300
vim.opt.showtabline = 2
vim.opt.clipboard = 'unnamedplus' --クリップボードとレジスタを共有
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes' --行数表示の横に余白を追加
vim.opt.hidden = true
vim.opt.swapfile = false --スワップファイルを生成しない


local keymap = vim.keymap
-- キーバインド
-- 画面分割
keymap.set('n', 'ss', ':split<Return><C-w>w')
keymap.set('n', 'sv', ':vsplit<Return><C-w>w')
-- アクティブウィンドウの移動
keymap.set('n', 'sh', '<C-w>h')
keymap.set('n', 'sk', '<C-w>k')
keymap.set('n', 'sj', '<C-w>j')
keymap.set('n', 'sl', '<C-w>l')

-- Emacs風
keymap.set('i', '<C-f>', '<Right>')
-- jjでEscする
keymap.set('i','jj','<Esc>')
-- 設定ファイルを開く
keymap.set('n','<F1>',':edit $MYVIMRC<CR>')
