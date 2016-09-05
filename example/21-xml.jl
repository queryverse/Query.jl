using XMLDict, Query, NamedTuples, DataFrames

s = """
<Students>
    <Student name="John">
        <Parents>
            <Parent name="Paul"/>
            <Parent name="Mary"/>
        </Parents>
    </Student>
    <Student name="Steward">
        <Parents>
            <Parent name="George"/>
        </Parents>
    </Student>
    <Student name="Felix">
        <Parents>
            <Parent name="Greg"/>
            <Parent name="Susan"/>
        </Parents>
    </Student>
    <Student name="Sara">
        <Parents>
            <Parent name="Susan"/>
        </Parents>
    </Student>
</Students>
"""
x = parse_xml(s)

x["Student"][1]["Parents"]["Parent"][2]

q = @from student in x["Student"] begin
    @from parent in student["Parents"]
    #@select {Student=student["Name"], Parent=parent["name"]}
    @select student
    @collect
end

println(q)
