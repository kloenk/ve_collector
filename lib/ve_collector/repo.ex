defmodule VeCollector.Repo do
  use Ecto.Repo,
    otp_app: :ve_collector,
    adapter: Ecto.Adapters.Postgres
end
