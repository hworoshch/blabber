%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/**/*"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"\.heex$"]
      },
      plugins: [],
      requires: [],
      strict: true,
      color: true,
      checks: [
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Readability.AliasOrder, false},
        {Credo.Check.Readability.ModuleDoc, []},
        {Credo.Check.Readability.FunctionNames, []}
      ]
    }
  ]
}
