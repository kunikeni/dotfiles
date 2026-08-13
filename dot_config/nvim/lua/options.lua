vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- 行番号の表示
vim.opt.number = true
vim.wo.number = true
vim.wo.relativenumber = false

-- タブとインデントの設定
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

-- 検索設定
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ビジュアル設定
vim.opt.cursorline = true

-- spell check
vim.opt.spell = false

-- カーソル移動
vim.opt.whichwrap = 'b,s,h,l,<,>,[,],~'
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
-- マウスドラッグでvisualモードに入らないようにする
keymap.set({ 'n', 'v', 'o' }, '<LeftDrag>', '<LeftMouse>')
keymap.set({ 'i', 'c' }, '<LeftDrag>', '<LeftMouse>')

-- ファイルを上書きする前にバックアップを作ることを無効化
vim.opt.writebackup = false
-- vim の矩形選択で文字が無くても右へ進める
vim.opt.virtualedit = 'block'
-- 全角文字専用の設定
vim.opt.ambiwidth = 'double'
-- Windowsでパスの区切り文字をスラッシュで扱う
vim.opt.shellslash = true
-- 対応する括弧やブレースを表示
vim.opt.showmatch = true
vim.opt.matchtime = 1
-- インデント方法の変更
vim.opt.cinoptions:append(':0')
-- タブ文字を CTRL-I で表示し、行末に $ で表示する
vim.opt.list = true
-- 行末のスペースを可視化
vim.opt.listchars = { tab = '^ ', trail = '~' }
-- 検索にマッチした行以外を折りたたむ(フォールドする)機能
vim.opt.foldenable = false
-- すべての数を10進数として扱う
vim.opt.nrformats = ''
-- コメントの色を水色
vim.cmd('highlight Comment ctermfg=3')

-- Escの2回押しでハイライト消去
keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>')

-- auto reload vimrc
vim.api.nvim_create_augroup('source_vimrc', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  group = 'source_vimrc',
  pattern = { '*vimrc', 'init.lua', 'options.lua' },
  callback = function()
    vim.cmd('source $MYVIMRC')
    vim.opt.foldmethod = 'marker'
  end,
})

-- auto comment off
vim.api.nvim_create_augroup('auto_comment_off', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = 'auto_comment_off',
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions:remove('r')
    vim.opt_local.formatoptions:remove('o')
  end,
})

-- HTML/XML閉じタグ自動補完
vim.api.nvim_create_augroup('my_xml', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = 'my_xml',
  pattern = { 'xml', 'html' },
  callback = function()
    vim.keymap.set('i', '</', '</<C-x><C-o>', { buffer = true })
  end,
})

-- 編集箇所のカーソルを記憶
vim.api.nvim_create_augroup('redhat', { clear = true })
vim.api.nvim_create_autocmd('BufRead', {
  group = 'redhat',
  pattern = '*.txt',
  command = 'setlocal textwidth=78',
})
vim.api.nvim_create_autocmd('BufReadPost', {
  group = 'redhat',
  pattern = '*',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.cmd, 'normal! g`"')
    end
  end,
})
