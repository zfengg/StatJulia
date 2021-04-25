# m4_2t.jl

using Pkg, DrWatson

@quickactivate "StatisticalRethinkingTuring"
using Turing
using StatisticalRethinking
Turing.setprogress!(false)

# ### snippet 4.43

delim = ';'
df = CSV.read(sr_datadir("Howell1.csv"), DataFrame; delim)

# Use only adults and center the weight observations

df = filter(row -> row.age >= 18, df)
mean_weight = mean(df.weight)
df.weight_c = df.weight .- mean_weight
precis(df)

# Extract variables for Turing model

x = df.weight_c
y = df.height

# Define the regression model

@model ppl4_2(x, y) = begin
    #priors
    alpha ~ Normal(178.0, 100.0)
    beta ~ Normal(0.0, 10.0)
    s ~ Uniform(0, 50)

    #model
    mu = alpha .+ beta*x
    y .~ Normal.(mu, s)
end

# Draw the samples

m4_2t = ppl4_2(df.weight_c, df.height)
nchains = 4; sampler = NUTS(0.65); nsamples=2000
chns4_2t = mapreduce(c -> sample(m4_2t, sampler, nsamples), chainscat, 1:nchains)

# Compare with a previous result

clip_43s_example_output = "
Iterations = 1:1000
Thinning interval = 1
Chains = 1,2,3,4
Samples per chain = 1000

Empirical Posterior Estimates:
         Mean        SD       Naive SE       MCSE      ESS
alpha 154.597086 0.27326431 0.0043206882 0.0036304132 1000
 beta   0.906380 0.04143488 0.0006551430 0.0006994720 1000
sigma   5.106643 0.19345409 0.0030587777 0.0032035103 1000

Quantiles:
          2.5%       25.0%       50.0%       75.0%       97.5%
alpha 154.0610000 154.4150000 154.5980000 154.7812500 155.1260000
 beta   0.8255494   0.8790695   0.9057435   0.9336445   0.9882981
sigma   4.7524368   4.9683400   5.0994450   5.2353100   5.5090128
";

# End of `04/m4.2t.jl`
