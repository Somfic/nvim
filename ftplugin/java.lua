local jdtls = require("jdtls")

-- Set 4-space indentation for Java
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true

-- Find root of project
local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)

-- Eclipse workspace (unique per project)
local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- Find jdtls from Mason
local mason_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local launcher_jar = vim.fn.glob(mason_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

-- Lombok support
local lombok_jar = mason_path .. "/lombok.jar"

-- DAP bundles (java-debug-adapter + java-test, installed via Mason)
local mason_base = vim.fn.stdpath("data") .. "/mason/packages"
local bundles = {}
vim.list_extend(bundles, vim.split(vim.fn.glob(
    mason_base .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
), "\n", { trimempty = true }))
vim.list_extend(bundles, vim.split(vim.fn.glob(
    mason_base .. "/java-test/extension/server/*.jar"
), "\n", { trimempty = true }))

-- Determine OS config
local os_config = "linux"
if vim.fn.has("mac") == 1 then
  os_config = "mac"
elseif vim.fn.has("win32") == 1 then
  os_config = "win"
end

local config_path = mason_path .. "/config_" .. os_config

-- Resolve the Eclipse formatter profile jdtls should use. A repo may ship its
-- own eclipse-formatter.xml (checked first); otherwise fall back to the bundled
-- BOS profile (derived from Google style: 4-space indent, 8-space continuation,
-- 120-col line split — see jdtls/bos-java-style.xml). The profile name is read
-- straight out of the file so any project's own profile name works too.
local function resolve_java_formatter(root)
  local candidates = {}
  if root then
    table.insert(candidates, root .. "/eclipse-formatter.xml")
    table.insert(candidates, root .. "/.eclipse-formatter.xml")
  end
  table.insert(candidates, vim.fn.expand("~/.config/nvim/jdtls/bos-java-style.xml"))
  for _, path in ipairs(candidates) do
    if vim.uv.fs_stat(path) then
      local name = "BOS"
      local f = io.open(path, "r")
      if f then
        local content = f:read("*a")
        f:close()
        name = content:match('<profile[^>]-name="([^"]+)"') or name
      end
      return "file://" .. path, name
    end
  end
  return nil, nil
end

local format_url, format_profile = resolve_java_formatter(root_dir)

local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.level=WARN",
    "-Xms4g",
    "-Xmx8g",
    -- Throughput-tuned GC (the upstream jdtls launcher defaults); the workspace
    -- build cares about total CPU, not pause times, and string dedup costs more
    -- than it saves here.
    "-XX:+UseParallelGC",
    "-XX:GCTimeRatio=4",
    "-XX:AdaptiveSizePolicyWeight=90",
    "-Dsun.zip.disableMemoryMapping=true",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. lombok_jar,
    "-jar", launcher_jar,
    "-configuration", config_path,
    "-data", workspace_dir,
  },

  root_dir = root_dir,

  init_options = {
    bundles = bundles,
    extendedClientCapabilities = {
      progressReportProvider = false,
      classFileContentsSupport = true,
      generateToStringPromptSupport = true,
      hashCodeEqualsPromptSupport = true,
      advancedExtractRefactoringSupport = true,
      advancedOrganizeImportsSupport = true,
      generateConstructorsPromptSupport = true,
      generateDelegateMethodsPromptSupport = true,
      moveRefactoringSupport = true,
      overrideMethodsPromptSupport = true,
      inferSelectionSupport = { "extractMethod", "extractVariable", "extractConstant" },
    },
  },

  settings = {
    java = {
      jdt = {
        ls = {
          java = {
            home = vim.env.JAVA_HOME,
          },
        },
      },
      configuration = {
        -- Do not silently re-run the Gradle import on every build-file save.
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-21",
            path = vim.env.JAVA_HOME,
            default = true,
          },
        },
      },
      signatureHelp = { enabled = true },
      inlayHints = {
        parameterNames = { enabled = "all" },
      },
      contentProvider = { preferred = "fernflower" },
      -- Autobuild recompiles the whole workspace on every save, which on BOS means
      -- re-running querydsl-apt + jpamodelgen over 3.5k files. Project-wide errors
      -- come from an explicit <leader>jb/<leader>jB build instead (see on_attach).
      autobuild = { enabled = false },
      -- Build the Gradle modules in parallel instead of one at a time.
      maxConcurrentBuilds = 4,
      references = { includeDecompiledSources = false },
      implementationsCodeLens = { enabled = false },
      referencesCodeLens = { enabled = false },
      project = {
        referencedLibraries = {
          "lib/**/*.jar",
        },
      },
      import = {
        gradle = {
          enabled = true,
          offline = { enabled = true },
        },
        maven = { enabled = true },
        exclusions = {
          "**/node_modules/**",
          "**/.metadata/**",
          "**/archetype-resources/**",
          "**/META-INF/maven/**",
        },
      },
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
      },
      format = {
        settings = {
          url = format_url,
          profile = format_profile,
        },
      },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.Assume.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.mockito.Mockito.*",
          "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
          "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
    },
  },

  capabilities = require("blink.cmp").get_lsp_capabilities(),
  on_attach = function(client, bufnr)
    -- jdtls now owns Java formatting, using the BOS Eclipse profile resolved
    -- above. conform (formatters_by_ft has no java) falls back to this on save.

    -- shared LSP keymaps come from the LspAttach autocmd in lua/lsp/init.lua

    -- jdtls specific keymaps
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "<leader>co", jdtls.organize_imports, vim.tbl_extend("force", opts, { desc = "Organize imports" }))
    vim.keymap.set("n", "<leader>cv", jdtls.extract_variable, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
    vim.keymap.set("v", "<leader>cv", function() jdtls.extract_variable(true) end, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
    vim.keymap.set("n", "<leader>cc", jdtls.extract_constant, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
    vim.keymap.set("v", "<leader>cc", function() jdtls.extract_constant(true) end, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
    vim.keymap.set("v", "<leader>cm", function() jdtls.extract_method(true) end, vim.tbl_extend("force", opts, { desc = "Extract method" }))

    -- Build the workspace on demand (IntelliJ's "Build Project"). Results land in
    -- the quickfix list, so <leader>xq shows project-wide errors in Trouble.
    vim.keymap.set("n", "<leader>jb", function() jdtls.compile("incremental") end,
      vim.tbl_extend("force", opts, { desc = "Build project (incremental)" }))
    vim.keymap.set("n", "<leader>jB", function() jdtls.compile("full") end,
      vim.tbl_extend("force", opts, { desc = "Build project (full)" }))

    -- DAP integration: register Spring Boot / main-class launch configs, hook test commands
    local ok_dap = pcall(require, "jdtls.dap")
    if ok_dap then
      require("jdtls").setup_dap({ hotcodereplace = "auto" })
      require("jdtls.dap").setup_dap_main_class_configs()
    end

    vim.keymap.set("n", "<leader>bt", function() require("jdtls").test_nearest_method() end,
      vim.tbl_extend("force", opts, { desc = "Debug nearest test" }))
    vim.keymap.set("n", "<leader>bT", function() require("jdtls").test_class() end,
      vim.tbl_extend("force", opts, { desc = "Debug test class" }))
  end,
}

jdtls.start_or_attach(config)
