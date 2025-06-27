-- BOOTSTRAP lazy.nvim if it isn't installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.termguicolors = true
vim.opt.number = true

vim.filetype.add({
  extension = {
    m  = "objc",
    mm = "objcpp"
  }
})

-- Keymapping
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "LSP Hover" })
vim.keymap.set("n", "<leader>e", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Show diagnostics" })
vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next diagnostic" })

-- Automatically show diagnostics
vim.o.updatetime = 300
vim.cmd([[
  autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

-- Code Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99  -- all open by default
vim.opt.fillchars = { foldopen = "▼", foldclose = "▶", fold = " " }
-- Remap default folding keymap
vim.keymap.set("n", "<leader>d", "za", { desc = "Toggle fold" })
vim.keymap.set("n", "<leader>s", "zo", { desc = "Open fold" })
vim.keymap.set("n", "<leader>w", "zc", { desc = "Close fold" })
vim.keymap.set("n", "<leader>S", "zR", { desc = "Open all folds" })
vim.keymap.set("n", "<leader>W", "zM", { desc = "Close all folds" })
-- Help detect Objective C methods
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "objc", "objcpp" },
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.ObjCFoldExpr()"
    vim.opt_local.foldenable = true
    vim.opt_local.foldlevel = 99
  end,
})

function _G.ObjCFoldExpr()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)

  -- Start of a method implementation
  if line:match("^%s*[-+]%s*%b()%s*{") then
    return "a1"
  end

  -- End of a method or block
  if line:match("^%s*}%s*$") then
    return "s1"
  end

  return "=" -- keep previous fold level
end





-- PLUGINS
-- Load plugins using lazy.nvim
require("lazy").setup({
  { "nvim-lua/plenary.nvim" },

  -- Color Scheme
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("dracula")
    end
  },

  -- LSP Config for clangd
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").clangd.setup({
        cmd = {
          "clangd-gnustep",
          "--clang-tidy",             -- enables clang-tidy diagnostics
          "--header-insertion=never", -- optional: cleaner includes
          "--completion-style=detailed",
          "--all-scopes-completion",
          "--background-index",
        },
        filetypes = { "objc", "objcpp", "c", "cpp" },
      })
    end
  },

  -- Tree-sitter for Objective-C syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "objc", "c", "cpp", "lua" },
        -- highlight = { enable = true },
	highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end
  },

  -- Error Tooltips
  {
    "nvim-lualine/lualine.nvim" -- optional but nice with lsp progress
  },

  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("lspsaga").setup({
        lightbulb = { enable = false },
        symbol_in_winbar = { enable = false },
      })
    end
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
        })
      })
    end
  },
})

-- Diagnostic float window config
vim.diagnostic.config({
  float = {
    border = "rounded",
    source = "always",
    format = function(diagnostic)
      return "  " .. diagnostic.message .. "  "  -- adds left/right padding
    end,
  },
})

-- Contrast border and background for the popup
vim.cmd([[
  highlight! NormalFloat guibg=#1e1e2e guifg=white
  highlight! FloatBorder guibg=#1e1e2e guifg=#bd93f9
]])

-- Automatic Formatting for Objective C
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.m", "*.mm", "*.h" },
  callback = function()
    vim.lsp.buf.format()
  end,
})
vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format()
end, { desc = "Format current buffer with LSP" })

-- Reset terminal modes on exit
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    -- Disable modifyOtherKeys
    io.write("\27[>4;0m")
    -- Restore TTY state
    os.execute("stty sane")
  end,
})


