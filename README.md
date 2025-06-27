# Dev Tool Configurations

This repo contains some handy configuration files to assist with setting up your favorite IDEs and editors for Objective C/Gershwin


## Clangd (Required)

Put the following files in the root directory of your repo

- .clangd
- .clang-tidy
- .clang-format

These files will provide the linting and formatting to make code style consistent. You need these regardless of what editor you are using

## Neovim

The put the contents of the nvim directory where your nvim configs live on your platform. On Gershwin it will be `$HOME/.config/nvim`

## VSCode

For VSCode users you need to make sure you have the following extensions installed

- `C/C++` by Microsoft (ms-vscode.cpptools)
- `Clangd` (llvm-vs-code-extensions.vscode-clangd)

Then drop the `vscode` directory from this repo into the root directory of your project repo


## Git Hook

If you want to enforce these with each commit you can install the pre-commit file into `$YOUR_REPO_ROOT/.git/hooks/pre-commit`
