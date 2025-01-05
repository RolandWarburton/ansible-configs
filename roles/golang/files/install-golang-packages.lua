-- returns 98 when changes where made
-- returns 0 if nothing changed
local changed = false
local go_packages = {
  { name = "golang.org/x/tools/gopls",          version = "latest", test = "gopls" },
  { name = "github.com/go-delve/delve/cmd/dlv", version = "latest", test = "dlv" },
  { name = "github.com/google/gops",            version = "latest", test = "gops" }
}

local function getenv()
  local home = os.getenv("HOME")
  local gopath = string.format("%s/.local/go/pkg", home)
  local gobin = string.format("%s/.local/go/pkg/bin", home)
  local go = string.format("%s/.local/go/bin", home);
  local env_vars = string.format("GOPATH=%s PATH=%s:%s:%s",
    gopath, os.getenv("PATH"), gobin, go)
  return env_vars
end

-- function to check if a command exists
local function command_exists(cmd_string)
  local env_vars = getenv()
  local cmd = string.format("%s command -v %s 2>/dev/null", env_vars, cmd_string)
  local handle = io.popen(cmd)
  if handle == nil then os.exit(1, true) end
  local result = handle:read("*a") -- returns a path if it exists
  handle:close()
  return result ~= ""
end

-- Function to install a Go package
local function install_package(name, version)
  local env_vars = getenv()
  local cmd = string.format("%s go install %s@%s", env_vars, name, version)
  print(string.format("Installing %s@%s...", name, version))
  local result = os.execute(cmd)
  if result == 0 then
    changed = true
    print(string.format("%s@%s installed successfully.", name, version))
  else
    print(string.format("Failed to install %s@%s.", name, version))
    os.exit(1)
  end
end

-- Main logic
for _, pkg in ipairs(go_packages) do
  if command_exists(pkg.test) then
    print(string.format("%s is already installed.", pkg.name))
  else
    install_package(pkg.name, pkg.version)
  end
end

if changed then
  os.exit(98)
else
  os.exit(0)
end
