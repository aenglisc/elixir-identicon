defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_colour
    |> build_grid
    |> filter_odd
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
    Turns the input string into a hash and stores it in the image struct as `hex:`

  ## Examples

    iex(1)> Identicon.hash_input("asdf")
    %Identicon.Image{colour: nil, grid: nil,
    hex: [145, 46, 200, 3, 178, 206, 73, 228, 165, 65, 6, 141, 73, 90, 181, 112],
    pixel_map: nil}
  
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_colour(%Identicon.Image{hex: [r, g, b | _tail]} = image_struct) do
    %Identicon.Image{image_struct | colour: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image_struct) do
    grid = hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image_struct | grid: grid}
  end

  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  def filter_odd(%Identicon.Image{grid: grid} = image_struct) do
    grid = Enum.filter grid, fn({value, _index}) ->
      rem(value, 2) == 0
    end

    %Identicon.Image{image_struct | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image_struct) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      
      {top_left, bottom_right}
    end
    
    %Identicon.Image{image_struct | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{colour: colour, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(colour)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
