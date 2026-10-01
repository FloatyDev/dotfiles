-- =============================================================================
-- ftplugin/java.lua
-- Runs automatically when a Java file is opened.
-- =============================================================================

local env = require("user.env")

-- Guard: warn clearly if jdtls isn't installed yet instead of a cryptic error
if vim.fn.filereadable(env.paths.jdtls_bin) == 0 then
    vim.notify(
        "[jdtls] jdtls binary not found.\n  Run :MasonInstall jdtls to fix this.",
        vim.log.levels.WARN
    )
    return
end

require("jdtls").start_or_attach({
    cmd = { env.paths.jdtls_bin },
	root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw", "pom.xml", "build.gradle" })
		or vim.fn.getcwd(),
})
