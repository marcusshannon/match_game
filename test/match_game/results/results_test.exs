defmodule MatchGame.ResultsTest do
  use MatchGame.DataCase

  alias MatchGame.Results

  describe "results" do
    alias MatchGame.Results.Result

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def result_fixture(attrs \\ %{}) do
      {:ok, result} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Results.create_result()

      result
    end

    test "list_results/0 returns all results" do
      result = result_fixture()
      assert Results.list_results() == [result]
    end

    test "get_result!/1 returns the result with given id" do
      result = result_fixture()
      assert Results.get_result!(result.id) == result
    end

    test "create_result/1 with valid data creates a result" do
      assert {:ok, %Result{} = result} = Results.create_result(@valid_attrs)
    end

    test "create_result/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Results.create_result(@invalid_attrs)
    end

    test "update_result/2 with valid data updates the result" do
      result = result_fixture()
      assert {:ok, %Result{} = result} = Results.update_result(result, @update_attrs)
    end

    test "update_result/2 with invalid data returns error changeset" do
      result = result_fixture()
      assert {:error, %Ecto.Changeset{}} = Results.update_result(result, @invalid_attrs)
      assert result == Results.get_result!(result.id)
    end

    test "delete_result/1 deletes the result" do
      result = result_fixture()
      assert {:ok, %Result{}} = Results.delete_result(result)
      assert_raise Ecto.NoResultsError, fn -> Results.get_result!(result.id) end
    end

    test "change_result/1 returns a result changeset" do
      result = result_fixture()
      assert %Ecto.Changeset{} = Results.change_result(result)
    end
  end
end
