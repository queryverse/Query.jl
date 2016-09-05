using JSON, Query, NamedTuples, DataFrames

s = """
{
    "Students": [
        {
            "Name": "John",
            "Parents": [ {"name": "Paul"}, {"name": "Mary"}]
        },
        {
            "Name": "Steward",
            "Parents": [ {"name": "George"} ]
        },
        {
            "Name": "Felix",
            "Parents": [ {"name": "Greg"}, {"name": "Susan"}]
        },
        {
            "Name": "Sara",
            "Parents": [ {"name": "Susan"}]
        }
    ]
}
"""

q = @from student in JSON.parse(s)["Students"] begin
    @from parent in student["Parents"]
    @select {Student=student["Name"], Parent=parent["name"]}
    @collect DataFrame
end

println(q)
