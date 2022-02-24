defmodule VeCollector.Repo do
  use Ecto.Repo,
    otp_app: :ve_collector,
    adapter:
     if(Mix.env() in [:dev, :test],
        do: Ecto.Adapters.SQLite3,
        else: Ecto.Adapters.Postgres
      )
end
