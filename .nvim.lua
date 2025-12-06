require("conform").setup({
  formatters_by_ft = {
    nix = { "nixfmt" },
    verilog = { "verible" },
    systemverilog = { "verible" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})

vim.lsp.config('lua_ls', {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc" },
  settings = {
    Lua = {
      signatureHelp = { enabled = true },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        }
      },
    }
  }
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function()
    vim.lsp.buf.format({
      async = false,
      filter = function(client)
        return client.name == "lua_ls"
      end,
    })
  end,
})

vim.lsp.enable("lua_ls")
vim.lsp.enable('verible')
