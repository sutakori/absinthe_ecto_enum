defmodule Absinthe.EctoEnum do
  @moduledoc """
  Documentation for Absinthe.EctoEnum.
  """

  defmacro __using__(_opt) do
    quote do
      import unquote(__MODULE__), only: :macros
    end
  end

  defmacro import_ecto_enum(enum_module_ast, opts \\ []) do
    env = __CALLER__

    enum_module_ast
    |> Macro.expand(env)
    |> do_import_ecto_enum(env, opts)
  end

  defp do_import_ecto_enum({{:., _, [root_ast, :{}]}, _, modules_ast_list}, env, opts) do
    {:__aliases__, _, root} = root_ast

    root_module = Module.concat(root)
    root_module_with_alias = Keyword.get(env.aliases, root_module, root_module)

    for {_, _, leaf} <- modules_ast_list do
      type_module = Module.concat([root_module_with_alias | leaf])

      if Code.ensure_loaded?(type_module) do
        do_import_ecto_enum(type_module, env, opts)
      else
        raise ArgumentError, "module #{type_module} is not available"
      end
    end
  end

  defp do_import_ecto_enum(module, env, opts) do
    name = module |> to_string() |> String.split(".") |> List.last |> Macro.underscore |> String.to_atom()
    value_list = Enum.map(module.__enum_map__(), & &1 |> elem(0))

    ast = quote do
      enum unquote(name) do
        values unquote(value_list)
      end
    end
    Module.eval_quoted(env, ast)

    []
  end
end
