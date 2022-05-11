local platform = ...
platform = platform or "unknown-unknown"

local OS, ARCH = platform:match "^([^-]+)-([^-]+)$"

local json = {
    name = "lua-debug",
    version = "1.55.1",
    publisher = "actboy168",
    displayName = "Lua Debug",
    description = "VSCode debugger extension for Lua",
    icon = "images/logo.png",
    private = true,
    author = {
        name = "actboy168",
    },
    bugs = {
        url = "https://github.com/actboy168/lua-debug/issues",
    },
    repository = {
        type = "git",
        url = "https://github.com/actboy168/lua-debug",
    },
    keywords = {
        "lua",
        "debug",
        "debuggers",
    },
    categories = {
        "Debuggers",
    },
    engines = {
        vscode = "^1.61.0",
    },
    extensionKind = {
        "workspace",
    },
    main = "./js/extension.js",
    activationEvents = {
        "onCommand:extension.lua-debug.runEditorContents",
        "onCommand:extension.lua-debug.debugEditorContents",
        "onCommand:extension.lua-debug.pickProcess",
        "onDebugInitialConfigurations",
        "onDebugDynamicConfigurations",
        "onDebugResolve:lua",
    },
    capabilities = {
        untrustedWorkspaces = {
            description = "Debugging is disabled in Restricted Mode.",
            supported = false,
        },
    },
    contributes = {
        breakpoints = {
            {
                language = "lua",
            },
            {
                language = "html",
            },
        },
        commands = {
            {
                command = "extension.lua-debug.runEditorContents",
                icon = "$(play)",
                title = "Run File",
            },
            {
                command = "extension.lua-debug.debugEditorContents",
                icon = "$(debug-alt-small)",
                title = "Debug File",
            },
            {
                command = "extension.lua-debug.showIntegerAsDec",
                title = "Show as Dec",
            },
            {
                command = "extension.lua-debug.showIntegerAsHex",
                title = "Show as Hex",
            },
        },
        configuration = {
            properties = {
                ["lua.debug.variables.showIntegerAsHex"] = {
                    default = false,
                    description = "Show integer as hex.",
                    type = "boolean",
                },
            },
        },
        debuggers = {
            {
                configurationSnippets = {
                    {
                        body = {
                            arg = {
                            },
                            consoleCoding = "utf8",
                            cpath = "^\"\\${workspaceFolder}/?.dll\"",
                            cwd = "^\"\\${workspaceFolder}\"",
                            name = "${1:launch}",
                            path = "^\"\\${workspaceFolder}/?.lua\"",
                            program = "^\"\\${workspaceFolder}/${2:main.lua}\"",
                            request = "launch",
                            stopOnEntry = true,
                            type = "lua",
                        },
                        description = "A new configuration for launching a lua debug program",
                        label = "Lua Debug: Launch Script",
                    },
                    {
                        body = {
                            consoleCoding = "utf8",
                            name = "${1:launch process}",
                            request = "launch",
                            runtimeArgs = "^\"\\${workspaceFolder}/${2:main.lua}\"",
                            runtimeExecutable = "^\"\\${workspaceFolder}/lua.exe\"",
                            stopOnEntry = true,
                            type = "lua",
                        },
                        description = "A new configuration for launching a lua process",
                        label = "Lua Debug: Launch Process",
                    },
                    {
                        body = {
                            address = "127.0.0.1:4278",
                            name = "${1:attach}",
                            request = "attach",
                            stopOnEntry = true,
                            type = "lua",
                        },
                        description = "A new configuration for attaching a lua debug program",
                        label = "Lua Debug: Attach",
                    },
                    {
                        body = {
                            name = "${1:attach}",
                            processId = "^\"\\${command:pickProcess}\"",
                            request = "attach",
                            stopOnEntry = true,
                            type = "lua",
                        },
                        description = "A new configuration for attaching a lua debug program",
                        label = "Lua Debug: Attach Process",
                    },
                },
                label = "Lua Debug",
                languages = {
                    "lua",
                },
                type = "lua",
                variables = {
                    pickProcess = "extension.lua-debug.pickProcess",
                },
            },
        },
        menus = {
            ["debug/variables/context"] = {
                {
                    command = "extension.lua-debug.showIntegerAsDec",
                    group = "1_view",
                    when = "debugConfigurationType == 'lua' && debugProtocolVariableMenuContext == 'integer/hex'",
                },
                {
                    command = "extension.lua-debug.showIntegerAsHex",
                    group = "1_view",
                    when = "debugConfigurationType == 'lua' && debugProtocolVariableMenuContext == 'integer/dec'",
                },
            },
            ["editor/title/run"] = {
                {
                    command = "extension.lua-debug.runEditorContents",
                    when = "resourceLangId == lua",
                },
                {
                    command = "extension.lua-debug.debugEditorContents",
                    when = "resourceLangId == lua",
                },
            },
        },
    },
}

local attributes = {}

attributes.common = {
    consoleCoding = {
        default = "utf8",
        enum = {
            "utf8",
            "ansi",
            "none",
        },
        markdownDescription = "%lua.debug.launch.consoleCoding.description%",
        type = "string",
    },
    luaVersion = {
        default = "5.4",
        enum = {
            "5.1",
            "5.2",
            "5.3",
            "5.4",
            "latest",
        },
        markdownDescription = "%lua.debug.launch.luaVersion.description%",
        type = "string",
    },
    outputCapture = {
        default = {
        },
        items = {
            enum = {
                "print",
                "io.write",
                "stdout",
                "stderr",
            },
        },
        markdownDescription = "From where to capture output messages: print or stdout/stderr streams.",
        type = "array",
    },
    pathFormat = {
        default = "path",
        enum = {
            "path",
            "linuxpath",
        },
        markdownDescription = "Path format",
        type = "string",
    },
    skipFiles = {
        default = {
        },
        items = {
            type = "string",
        },
        markdownDescription = "An array of glob patterns for files to skip when debugging.",
        type = "array",
    },
    sourceCoding = {
        default = "utf8",
        enum = {
            "utf8",
            "ansi",
        },
        markdownDescription = "%lua.debug.launch.sourceCoding.description%",
        type = "string",
    },
    sourceFormat = {
        default = "path",
        enum = {
            "path",
            "string",
            "linuxpath",
        },
        markdownDescription = "Source format",
        type = "string",
    },
    sourceMaps = {
        default = {
            {
                "./*",
                "${workspaceFolder}/*",
            },
        },
        markdownDescription = "The source path of the remote host and the source path of local.",
        type = "array",
    },
    stopOnEntry = {
        default = false,
        markdownDescription = "Automatically stop after entry.",
        type = "boolean",
    },
    stopOnThreadEntry = {
        default = true,
        markdownDescription = "Automatically stop after thread entry.",
        type = "boolean",
    },
    useWSL = {
        default = true,
        description = "Use Windows Subsystem for Linux.",
        type = "boolean",
    },
}

attributes.attach = {
    address = {
        default = "127.0.0.1:4278",
        markdownDescription = [[
Debugger address.
1. IPv4 e.g. `127.0.0.1:4278`
2. IPv6 e.g. `[::1]:4278`
3. Unix domain socket e.g. `@c:\\unix.sock`]],
        type = "string",
    },
    client = {
        default = true,
        markdownDescription = "Choose whether to `connect` or `listen`.",
        type = "boolean",
    },
}

attributes.launch = {
    luaexe = {
        default = "${workspaceFolder}/lua.exe",
        markdownDescription = "Absolute path to the lua exe.",
        type = "string",
    },
    program = {
        default = "${workspaceFolder}/main.lua",
        markdownDescription = "Lua program to debug - set this to the path of the script",
        type = "string",
    },
    arg = {
        default = {
        },
        markdownDescription = "Command line argument, arg[1] ... arg[n]",
        type = "array",
    },
    arg0 = {
        default = {
        },
        markdownDescription = "Command line argument, arg[-n] ... arg[0]",
        type = {
            "string",
            "array",
        },
    },
    path = {
        default = "${workspaceFolder}/?.lua",
        markdownDescription = "%lua.debug.launch.path.description%",
        type = {
            "string",
            "array",
            "null",
        },
    },
    cpath = {
        default = "${workspaceFolder}/?.dll",
        markdownDescription = "%lua.debug.launch.cpath.description%",
        type = {
            "string",
            "array",
            "null",
        },
    },
    luaArch = {
        default = "x86_64",
        enum = {
        },
        markdownDescription = "%lua.debug.launch.luaArch.description%",
        type = "string",
    },
    cwd = {
        default = "${workspaceFolder}",
        markdownDescription = "Working directory at program startup",
        type = {
            "string",
            "null",
        },
    },
    env = {
        additionalProperties = {
            type = {
                "string",
                "null",
            },
        },
        default = {
            PATH = "${workspaceFolder}",
        },
        markdownDescription = "Environment variables passed to the program. The value `null` removes thevariable from the environment.",
        type = "object",
    },
    console = {
        default = "integratedTerminal",
        enum = {
            "internalConsole",
            "integratedTerminal",
            "externalTerminal",
        },
        enummarkdownDescriptions = {
            "%lua.debug.launch.console.internalConsole.description%",
            "%lua.debug.launch.console.integratedTerminal.description%",
            "%lua.debug.launch.console.externalTerminal.description%",
        },
        markdownDescription = "%lua.debug.launch.console.description%",
        type = "string",
    },
}

if OS == "win32" then
    attributes.attach.processId = {
        default = "${command:pickProcess}",
        markdownDescription = "Id of process to attach to.",
        type = "string",
    }
    attributes.attach.processName = {
        default = "lua.exe",
        markdownDescription = "Name of process to attach to.",
        type = "string",
    }
    attributes.launch.runtimeExecutable = {
        default = "${workspaceFolder}/lua.exe",
        markdownDescription = "Runtime to use. Either an absolute path or the name of a runtime availableon the PATH.",
        type = {
            "string",
            "null",
        },
    }
    attributes.launch.runtimeArgs = {
        default = "${workspaceFolder}/main.lua",
        markdownDescription = "Arguments passed to the runtime executable.",
        type = {
            "string",
            "array",
            "null",
        },
    }
end

local function SupportedArchs()
    if OS == "win32" then
        if ARCH == "x64" then
            return "x86", "x86_64"
        else
            return "x86"
        end
    elseif OS == "darwin" then
        if ARCH == "arm64" then
            return "x86_64", "arm64"
        else
            return "x86_64"
        end
    elseif OS == "linux" then
        if ARCH == "arm64" then
            return "arm64"
        else
            return "x86_64"
        end
    end
end

attributes.launch.luaArch.enum = {SupportedArchs()}

for k, v in pairs(attributes.common) do
    attributes.attach[k] = v
    attributes.launch[k] = v
end
json.contributes.debuggers[1].configurationAttributes = {
    launch = {properties=attributes.launch},
    attach = {properties=attributes.attach},
}

local configuration = json.contributes.configuration.properties
for _, name in ipairs {"luaArch", "luaVersion","sourceCoding","consoleCoding", "path", "cpath","console"} do
    local cfg = {}
    local attr = attributes.launch[name] or attributes.attach[name]
    for k, v in pairs(attr) do
        if k == 'markdownDescription' then
            k = 'description'
        end
        if k == 'enummarkdownDescriptions' then
            k = 'enumDescriptions'
        end
        cfg[k] = v
    end
    configuration["lua.debug.settings."..name] = cfg
end

return json
