defmodule VeCollectorWeb.Templates.Metric do

  def labels(name, data) when is_binary(name) and is_map(data) do
    "device=\"#{name}\",product=\"#{Map.get(data, "product", "Unknown")}\",serial=\"#{Map.get(data, "SER#", "Unknown")}\""
  end

end
