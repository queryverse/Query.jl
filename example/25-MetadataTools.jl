using MetadataTools, Query, DataFrames

pkg = values(get_all_pkg())

# This query creates a list of packages on which at least one other
# package depends, and orders that list by the number of packages that
# depend on a given package.

q = @from i in pkg begin
    @where length(i.versions)>0
    @let j = last(i.versions)
    @from k in j.requires
    @group k by String(k.package) into g
    @where g.key!="julia"
    @let num_deps = length(g)
    @orderby descending(num_deps)
    @select {Name=g.key, Num_Deps=num_deps}
    @collect DataFrame
end

println(q)
