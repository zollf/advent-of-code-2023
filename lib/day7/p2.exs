# 251004838
# 251004838
# 250825971
defmodule Hand do
  defstruct [:cards, :bid, :value, :secondary_value, :debug]

  @letter_ranks %{
    "T" => 10,
    "J" => 1,
    "Q" => 12,
    "K" => 13,
    "A" => 14
  }

  def parse(input) do
    [card_input, bid_input] =
      input
      |> String.split(" ", trim: true)

    cards =
      card_input
      |> String.split("", trim: true)
      |> Enum.map(fn card ->
        case Integer.parse(card) do
          {num, _} -> num
          _ -> card
        end
      end)

    bid =
      bid_input
      |> String.to_integer()

    %Hand{cards: cards, bid: bid}
    |> put_value
    |> put_secondary_value
  end

  def put_value(%Hand{cards: cards} = hand) do
    card_values =
      cards
      |> Enum.reduce(%{}, fn card, acc ->
        acc |> Map.put(card, Map.get(acc, card, 0) + 1)
      end)

    joker_amount = Map.get(card_values, "J", 0)

    value =
      card_values
      |> Map.delete("J")
      |> Map.values()
      |> get_value(joker_amount)

    hand
    |> Map.put(:value, value)
    |> Map.put(:debug, {cards, card_values, joker_amount, value})
  end

  def put_secondary_value(%Hand{cards: cards} = hand) do
    ranks =
      cards
      |> Enum.map(&get_rank/1)

    hand
    |> Map.put(:secondary_value, ranks)
  end

  def is_hand_better(%Hand{} = hand1, %Hand{} = hand2) do
    cond do
      hand1.value > hand2.value ->
        true

      hand1.value < hand2.value ->
        false

      true ->
        compare_hand(hand1.secondary_value, hand2.secondary_value)
    end
  end

  def compare_hand([head1 | tail1], [head2 | tail2]) when head1 > head2, do: true
  def compare_hand([head1 | tail1], [head2 | tail2]) when head1 < head2, do: false

  def compare_hand([head1 | tail1], [head2 | tail2]) do
    compare_hand(tail1, tail2)
  end

  def compare_hand([], []) do
    false
  end

  defp get_value(card_amounts, joker_amount) do
    cond do
      # Five of a kind
      Enum.member?(card_amounts, 5) ->
        6

      can_joker_win?(card_amounts, joker_amount, 5) ->
        6

      # Four of a kind
      Enum.member?(card_amounts, 4) ->
        5

      can_joker_win?(card_amounts, joker_amount, 4) ->
        5

      # Full house
      Enum.member?(card_amounts, 3) && Enum.member?(card_amounts, 2) ->
        4

      Enum.count(card_amounts, &(&1 == 2)) == 2 && joker_amount == 1 ->
        4

      # Three of a kind
      Enum.member?(card_amounts, 3) ->
        3

      can_joker_win?(card_amounts, joker_amount, 3) ->
        3

      # Two pair
      Enum.count(card_amounts, &(&1 == 2)) == 2 ->
        2

      # One pair
      Enum.member?(card_amounts, 2) ->
        1

      can_joker_win?(card_amounts, joker_amount, 2) ->
        1

      # High card
      true ->
        0
    end
  end

  def can_joker_win?(card_amounts, joker_amount, target),
    do: joker_amount + Enum.max(card_amounts, &>=/2, fn -> 0 end) == target

  defp get_rank(card) when is_integer(card), do: card
  defp get_rank(card), do: Map.get(@letter_ranks, card)
end

defmodule AdventOfCode.Day7.P2 do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Hand.parse/1)
  end

  def sort(hands) do
    hands
    |> Enum.sort(&Hand.is_hand_better(&2, &1))
  end

  def get_hand_strength({%Hand{bid: bid}, rank}), do: bid * (rank + 1)
end

File.read!("lib/day7/input.txt")
|> AdventOfCode.Day7.P2.parse()
|> AdventOfCode.Day7.P2.sort()
|> Enum.with_index()
|> Enum.reverse()
|> Enum.map(&AdventOfCode.Day7.P2.get_hand_strength/1)
|> Enum.sum()
