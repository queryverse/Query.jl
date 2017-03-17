using Query, DataFrames, GLM, RCall

R"""
library(gapminder)
library(ggplot2)
x <- gapminder
"""

df = @rget x
df[:country] = convert(Array{String,1},df[:country])
df[:continent] = convert(Array{String,1},df[:continent])

residuals2(mm::DataFrames.DataFrameRegressionModel) = residuals(mm.model)
lm2(f,d) = convert(DataFrames.DataFrameRegressionModel{GLM.LinearModel{GLM.LmResp{Array{Float64,1}},GLM.DensePredQR{Float64}},Array{Float64,2}},lm(f, d))

q = @from i in df begin
    @group i by i.country into g
    @let model = lm2(lifeExp ~ year, g)
    @let residuals = residuals2(model)
    @select {country=g.key, data=zip(residuals, g)} into i
    @from j in i.data
    @select {i.country, j[2].continent, j[2].year, j[2].lifeExp, resid=j[1]}
    @collect DataFrame
end

print(q)

R"""
ggplot($q, aes(year, resid, group = country)) +
    geom_line(alpha = 1 / 3) + 
    facet_wrap(~continent)
"""
