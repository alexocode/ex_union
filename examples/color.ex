defmodule Color do
  import ExUnion

  defunion hex(string :: String.t)
           | rgb(red :: 0..255, green :: 0..255, blue :: 0..255)
           | rgba(red :: 0..255, green :: 0..255, blue :: 0..255, alpha :: float)
           | hsl(hue :: 0..360, saturation :: float, lightness :: float)
           | hsla(hue :: 0..360, saturation :: float, lightness :: float, alpha :: float)
end
