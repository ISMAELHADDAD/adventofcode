defmodule AdventOfCode.Mixfile do
  use Mix.Project

  def application do
    []
  end

  def project do
    [app: :advent_of_code, version: "1.0.0", deps: deps()]
  end

  defp deps do
    [{:priority_queue, "1.0.0"}]
  end
end
