#!/usr/local/bin/julia -q --color=yes

using Requests
using DataFrames

JLS = Pkg.dir(homedir(), ".stk.jls")
fields = [
  "stock_nm", "dividend_rate", "dividend_rate2", "dividend_rate_base", "increase_rt", "pe", "pb", "roe", "revenue_average", "profit_average", "roe_average", "pre_dividend", "aft_dividend"
]

saveData(data) = begin
  open(f->serialize(f, data), JLS, "w")
end

loadData() = begin
  open(deserialize, JLS)
end

init() = begin
  data = DataFrame()

  for field in fields
    data[Symbol(field)] = []
  end

  return data
end

update() = begin
  url = "https://www.jisilu.cn/data/stock/dividend_rate_list/"
  ts = floor(typeof(1), time()*1000)
  res = post("$(url)?___t=$(ts)", data = Dict(
    "market" => "sz",
    "type" => "dividend_rate",
    "rp" => "500"
  ))

  body = Dict(
    "json" => Requests.json(res),
    "data" => init()
  )

  saveData(body)
end

format() = begin
  body = loadData()
  rows = body["json"]["rows"]

  for row in rows
    for field in fields
      push!(body["data"][Symbol(field)], row["cell"][field])
    end
  end

  println(body["data"])
end

# update()
format()
