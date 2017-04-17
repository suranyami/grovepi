defmodule GrovePi.UltrasonicTest do
  use ExUnit.Case, async: true
  @pin 5
  @moduletag report: [:prefix, :board]

  def start_ultrasonic(prefix) do
    with {:ok, _} <- GrovePi.Supervisor.start_link(0x40, prefix),
         {:ok, _} = GrovePi.Ultrasonic.start_link(@pin, prefix: prefix),
    do: :ok
  end

  setup do
    prefix = String.to_atom(Time.to_string(Time.utc_now))
    board = GrovePi.Board.i2c_name(prefix)

    start_ultrasonic(prefix)

    GrovePi.I2C.reset(board)

    {:ok, [prefix: prefix, board: board]}
  end

  test "gets distance",
    %{prefix: prefix, board: board} do
    distance = 20

    GrovePi.I2C.add_response(board, <<1, distance::big-integer-size(16)>>)

    assert distance == GrovePi.Ultrasonic.read_distance(@pin, prefix)
    assert <<7, @pin, 0, 0>> == GrovePi.I2C.get_last_write(board)
  end
end