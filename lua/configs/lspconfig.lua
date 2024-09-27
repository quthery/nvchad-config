local configs = require "nvchad.configs.lspconfig"

local on_attach = configs.on_attach
local on_init = configs.on_init
local capabilities = configs.capabilities

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

local servers = { "html", "cssls", "ts_ls", "clangd", "gopls", "gradle_ls" }

lspconfig.pyright.setup {
  on_attach    = nvlsp.on_attach,
  on_init      = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  filetypes    = {"python"},
  root_dir = function (fname)
    local root_files = {
      'pyproject.toml',
      'pyrightconfig.json'
    }
    return lspconfig.util.root_pattern(table.unpack(root_files))(fname)
      or lspconfig.util.find_git_ancestor(fname)
      or lspconfig.util.path.dirname(fname)
  end
}

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
  }
  vim.lsp.buf.execute_command(params)
end

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    commands = {
      OrganizeImports = {
        organize_imports,
        description = "Organize Imports",
      },
    },
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
        },
      },
    },
  }
  lspconfig.prismals.setup {}
  lspconfig.volar.setup {
    on_attach = on_attach,
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    init_options = {
      vue = {
        hybridMode = false,
      },
    },
  }
end
