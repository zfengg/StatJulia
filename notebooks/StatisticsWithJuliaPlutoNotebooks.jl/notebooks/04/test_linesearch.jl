using Pkg, DrWatson

@quickactivate "StatisticsWithJuliaPlutoNotebooks"

function lineSearch(inputFilename, outputFilename, keyword)
    infile  = open(inputFilename, "r")
    outfile = open(outputFilename,"w")

    for (index, line) in enumerate(split(read(infile, String), "\n"))
        if occursin(keyword, line)
            println(outfile, "$index: $line")
        end
    end
    close(infile)
    close(outfile)
end

lineSearch(datadir("earth.txt"), datadir("waterLines.txt"), "water") |> display
