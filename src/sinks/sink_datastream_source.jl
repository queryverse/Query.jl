datastreams_integration_is_loaded = false

@require CSV begin

if !datastreams_integration_is_loaded
    include("sink_datastream_source_part2.jl")
    datastreams_integration_is_loaded = true
end

end

@require Feather begin

if !datastreams_integration_is_loaded
    include("sink_datastream_source_part2.jl")
    datastreams_integration_is_loaded = true
end

end

@require SQLite begin

if !datastreams_integration_is_loaded
    include("sink_datastream_source_part2.jl")
    datastreams_integration_is_loaded = true
end

end

@require ODBC begin

if !datastreams_integration_is_loaded
    include("sink_datastream_source_part2.jl")
    datastreams_integration_is_loaded = true
end

end