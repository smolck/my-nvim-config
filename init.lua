require('paq') {
    'savq/paq-nvim'; -- Let Paq manage itself
    'folke/tokyonight.nvim';
    'tpope/vim-surround';
    'nvim-treesitter/nvim-treesitter';

    'nvim-tree/nvim-web-devicons';
    'akinsho/bufferline.nvim';

    'nvim-lualine/lualine.nvim';

    -- LSP stuff
    'neovim/nvim-lspconfig';
    'hrsh7th/cmp-nvim-lsp';
    'hrsh7th/cmp-buffer';
    'hrsh7th/cmp-path';
    -- <insert other pointless comment here>
    'hrsh7th/nvim-cmp';
    'ray-x/lsp_signature.nvim';

    -- WHAT IF I DON'T WANT SNIPPETS LSP???
    -- WHAT IF I LIKE TYPING THINGS OUT
    -- HAVE YOU THOUGHT ABOUT THAT???
    'L3MON4D3/LuaSnip';
    'saadparwaiz1/cmp_luasnip';

    -- treesitter bb let's go
    {'nvim-treesitter/nvim-treesitter', run = function() vim.cmd[[TSUpdate]] end };

    'numToStr/FTerm.nvim';
    'nvim-tree/nvim-tree.lua';
}

local helpers = require('helpers')

vim.cmd[[colorscheme tokyonight-night]]

helpers.set_opts()
    'termguicolors'
    'relativenumber'
    'splitright'
    'splitbelow'
    'expandtab'
    'autoindent'
    -- 'autochdir'
    'smarttab'
    'list' -- TODO(smolck): why do i have this i don't remember
    'hidden'
    {'shiftwidth', 4}
    {'textwidth', 120}
    {'signcolumn', 'yes'}
    {'laststatus', 3} -- global statusline bb
    {'cmdheight', 0} -- this is cool
    {'clipboard', 'unnamedplus'} -- idk if its necessary but copy paste bb
    {'foldmethod', 'marker'}
    {'guifont', 'JetBrains Mono:h18:b'}
    {'fillchars', { eob = ' ' }} -- lol what
    {'completeopt', { 'menu', 'menuone', 'noselect' }}
    {'listchars', {
      tab = ' ',
      conceal = '┊',
      nbsp = 'ﮊ',
      extends = '>',
      precedes = '<',
      trail = '·',
      eol = '﬋',
    }}
    -- https://neovim.discourse.group/t/help-needed-customizing-nvim-terminal-title/721/6
    {'titlestring', [[%f %h%m%r%w %{v:progname} (%{tabpagenr()} of %{tabpagenr('$')})]]}

require('bufferline').setup{}
require('lualine').setup()
require('nvim-tree').setup()

vim.g.mapleader  = ';'
vim.g.maplocalleader = ';'
vim.g.tokyonight_italic_functions = true

-- https://matrix.to/#/!QHgmceKOqurJYyEVbD:matrix.org/$sEDa8Vb2lXfywk3ZEU9XfsVdAXd_ZBZ_8smrkDoKb2g?via=matrix.org&via=fabi.dev&via=smittie.de
vim.opt.shada = "'10,:10,/10,f0"

helpers.set_keymaps({
  default_opts = { noremap = true },

  [{ 'n', '<Leader>n' }] = '<cmd>bn<cr>',
  [{ 'n', '<Leader>p' }] = '<cmd>bp<cr>',
  [{ 'n', '<Leader>init' }] = '<cmd>e ~/.config/nvim/init.lua<cr>',
  [{ 'n', '<Leader>d' }] = '<cmd>bd<cr>',
  [{ 'n', '<Leader>tg' }] = '<cmd>Telescope git_files<cr>',
  [{ 'n', '<Leader>tf' }] = '<cmd>Telescope find_files<cr>',

  -- Floaterm
  [{ 'n', '<Leader>ff' }] = "<cmd>lua require('FTerm').toggle()<cr>",
  [{ 't', '<Leader>ff' }] = "<cmd>lua require('FTerm').toggle()<cr>",

  -- Esc out of terminal easily
  [{ 't', '<Esc>' }] = '<C-\\><C-n>',

  [{ 'n', '<Leader>tt' }] = '<cmd>NvimTreeToggle<cr>',

  [{ 'n', '<Leader>gd' }] = '<cmd>:lua vim.lsp.buf.definition()<cr>',
  [{ 'i', '<Leader>sh' }] = '<cmd>:lua vim.lsp.buf.signature_help()<cr>',
  [{ 'n', '<Leader>h' }] = '<cmd>:HopWord<cr>',
})

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

local cmp = require('cmp')
local cmp_types = require('cmp.types')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item()),
    ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item()),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    -- ['<CR>'] = cmp.config.disable,
    -- ['<Tab>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', max_item_count = 20 },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer', max_item_count = 10 },
  }),
  sorting = {
    comparators = {
      function(entry1, entry2)
        local kind1 = entry1:get_kind()
        kind1 = kind1 == cmp_types.lsp.CompletionItemKind.Text and 100 or kind1
        local kind2 = entry2:get_kind()
        kind2 = kind2 == cmp_types.lsp.CompletionItemKind.Text and 100 or kind2
        if kind1 ~= kind2 then
          if kind1 == cmp_types.lsp.CompletionItemKind.Snippet then
            return true
          end
          if kind2 == cmp_types.lsp.CompletionItemKind.Snippet then
            return false
          end

          if kind1 == cmp_types.lsp.CompletionItemKind.Field then
              return true
          end
          if kind2 == cmp_types.lsp.CompletionItemKind.Field then
              return false
          end

          local diff = kind1 - kind2
          if diff < 0 then
            return true
          elseif diff > 0 then
            return false
          end
        end
      end,
    },
  }
})

require('lsp_signature').setup()

local lspconfig = require('lspconfig')
lspconfig.clangd.setup{}

local sumneko_dir = os.getenv('HOME') .. '/dev/lua/lua-language-server'
lspconfig.sumneko_lua.setup({
  cmd = { sumneko_dir .. '/bin/lua-language-server' },

  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        -- path = runtime_path,
      },
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
        maxPreload = 1000,
        preloadFileSize = 350,
        checkThirdParty = false,
      },
      diagnostics = {
        globals = { 'vim' },
        disable = { 'lowercase-global' },
      },
      completion = {
        callSnippet = 'Replace',
        showWord = 'Disable',
      },
      telemetry = {
        enable = false,
      },
    },
  },
})
