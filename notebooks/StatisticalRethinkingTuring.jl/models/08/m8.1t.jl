# ### m8.1t

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingTuring"
using Turing
using StatisticalRethinking
Turing.setprogress!(false)

# Read in the `rugged` data as a DataFrame

df = CSV.read(sr_datadir("rugged.csv"), DataFrame)

# Apply log() to each element in rgdppc_2000 column and add it as a new column

df = hcat(df, map(log, df[!, Symbol("rgdppc_2000")]));

# Rename our col x1 => log_gdp

DataFrames.rename!(df, :x1 => :log_gdp);

# Now we need to drop every row where rgdppc_2000 == missing

# When this (https://github.com/JuliaData/DataFrames.jl/pull/1546) hits DataFrame it'll be conceptually easier: i.e., completecases!(d, :rgdppc_2000)

notisnan(e) = !ismissing(e)
dd = df[map(notisnan, df[:, :rgdppc_2000]), :];

# Define the Turing model

@model ppl8_1(y, x₁, x₂) = begin
    σ ~ truncated(Cauchy(0, 2), 0, Inf)
    βR ~ Normal(0, 10)
    βA ~ Normal(0, 10)
    βAR ~ Normal(0, 10)
    α ~ Normal(0, 100)

    for i ∈ 1:length(y)
        y[i] ~ Normal(α + βR * x₁[i] + βA * x₂[i] + βAR * x₁[i] * x₂[i], σ)
    end

    # alternative formulation using broadcasting
    # y .~ Normal.(α .+ βR * x₁ .+ βA * x₂ .+ βAR * x₁ .* x₂, σ)
end;

# Use Turing mcmc

m8_1t = ppl8_1(dd.log_gdp, dd.rugged, dd.cont_africa)
nchains = 4; sampler = NUTS(0.65); nsamples=2000
chns8_1t = mapreduce(c -> sample(m8_1t, sampler, nsamples), chainscat, 1:nchains)
    
# Here's the ulam() output from rethinking 

m8_1s_cmdstan = "
Iterations = 1:1000
Thinning interval = 1
Chains = 1,2,3,4
Samples per chain = 1000

Empirical Posterior Estimates:
          Mean         SD       Naive SE       MCSE      ESS
    a  9.22360053 0.139119116 0.0021996664 0.0034632816 1000
   bR -0.20196346 0.076106388 0.0012033477 0.0018370185 1000
   bA -1.94430980 0.227080488 0.0035904578 0.0057840746 1000
  bAR  0.39071684 0.131889143 0.0020853505 0.0032749642 1000
sigma  0.95036370 0.052161768 0.0008247500 0.0009204073 1000

Quantiles:
          2.5%       25.0%       50.0%      75.0%        97.5%   
    a  8.95307475  9.12719750  9.2237750  9.31974000  9.490234250
   bR -0.35217930 -0.25334425 -0.2012855 -0.15124725 -0.054216855
   bA -2.39010825 -2.09894500 -1.9432550 -1.78643000 -1.513974250
  bAR  0.13496995  0.30095575  0.3916590  0.47887625  0.650244475
sigma  0.85376115  0.91363250  0.9484920  0.98405750  1.058573750
";

# End of `08/m8.1t.jl`
