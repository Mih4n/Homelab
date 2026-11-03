# These CLIs' completions use -f (no files) but their args are often paths; -F adds files on top of their own suggestions
for cmd in dotnet npm pnpm yarn bun cargo go docker
    complete -c $cmd -F
end
