using DataStreams

function collect{TSink<:Data.Sink}(enumerable::Enumerable, sink::TSink)
    source = IterableTables.get_datastreams_source(enumerable)

    Data.stream!(source, sink)
    
    return sink
end
