module Query

using Requires
using NamedTuples
using DataStructures
import FunctionWrappers: FunctionWrapper
using SimpleTraits

import Base.start
import Base.next
import Base.done
import Base.collect
import Base.length
import Base.eltype
import Base.join
import Base.count
import MacroTools
import ChainRecursive

export @from, @count, @where, @select, Grouping, null, @NT, DataValue

include("traits.jl")

include("operators.jl")

include("enumerable/enumerable.jl")
include("enumerable/enumerable_groupby.jl")
include("enumerable/enumerable_join.jl")
include("enumerable/enumerable_groupjoin.jl")
include("enumerable/enumerable_orderby.jl")
include("enumerable/enumerable_select.jl")
include("enumerable/enumerable_where.jl")
include("enumerable/enumerable_selectmany.jl")
include("enumerable/enumerable_defaultifempty.jl")
include("enumerable/enumerable_count.jl")

include("queryable/queryable.jl")
include("queryable/queryable_select.jl")
include("queryable/queryable_where.jl")

include("sources/source_array.jl")
include("sources/source_iterable.jl")
include("sources/source_dataframe.jl")
include("sources/source_datatable.jl")
include("sources/source_sqlite.jl")
include("sources/source_typedtable.jl")
include("sources/source_datastream.jl")
include("sources/source_indexedtables.jl")

include("sinks/sink_array.jl")
include("sinks/sink_dict.jl")
include("sinks/sink_dataframe.jl")
include("sinks/sink_datatable.jl")
include("sinks/sink_csvfile.jl")
include("sinks/sink_datastream_source.jl")

include("macros.jl")
include("query_translation.jl")

end
