```@meta
DocTestSetup = quote
    using Query, DataFrames, Statistics
    df = DataFrame(
        fruit    =  ["Apple", "Banana", "Cherry"],
        amount   =  [2, 6, 1000],
        price    =  [1.2, 2.0, 0.4],
        isyellow =  [false, true, false])
        pd = DataFrame(
            name=["mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune", "pluto"],
            mass=[0.33, 4.87, 5.97, 0.642, 1898.0, 568.0, 86.8, 102.0, 0.0146],
            diameter=[4879, 12104, 12756, 6792, 142984, 120536, 51118, 49528, 2370],
            gravity=[3.7, 8.9, 9.8, 3.7, 23.1, 9.0, 8.7, 11.0, 0.7],
            rotationperiod=[1407.6, -5832.5, 23.9, 24.6, 9.9, 10.7, -17.2, 16.1, -153.3],
            lengthday=[4222.6, 2802.0, 24.0, 24.7, 9.9, 10.7, 17.2, 16.1, 153.3],
            distancesun=[57.9, 108.2, 149.6, 227.9, 778.6, 1433.5, 2872.5, 4495.1, 5906.4],
            meantemperature=[167, 464, 15, -65, -110, -140, -195, -200, -225],
            surfacepressure=[0.0, 92.0, 1.0, 0.01, missing, missing, missing, missing, 1.0e-5],
            moons=[0, 0, 1, 2, 79, 62, 27, 14, 5],
            type=["rock", "rock", "rock", "rock", "gas", "gas", "ice", "ice", "ice"],
            rings=[false, false, false, false, true, true, true, true, false])
        pdo = DataFrame(
            name=["mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune", "pluto"],
            mass=[0.33, 4.87, 5.97, 0.642, 1898.0, 568.0, 86.8, 102.0, 0.0146],
            escapevelocity=[4.3, 10.4, 11.2, 5.0, 59.5, 35.5, 21.3, 23.5, 1.3],
            perihelion=[46.0, 107.5, 147.1, 206.6, 740.5, 1352.6, 2741.3, 4444.5, 4436.8],
            aphelion=[69.8, 108.9, 152.1, 249.2, 816.6, 1514.5, 3003.6, 4545.7, 7375.9],
            orbitalperiod=[88.0, 224.7, 365.2, 687.0, 4331.0, 10747.0, 30589.0, 59800.0, 90560.0],
            orbitalvelocity=[47.4, 35.0, 29.8, 24.1, 13.1, 9.7, 6.8, 5.4, 4.7],
            orbitalinclination=[7.0, 3.4, 0.0, 1.9, 1.3, 2.5, 0.8, 1.8, 17.2],
            orbitaleccentricity=[0.205, 0.007, 0.017, 0.094, 0.049, 0.057, 0.046, 0.011, 0.244],
            obliquitytoorbit=[0.034, 177.4, 23.4, 25.2, 3.1, 26.7, 97.8, 28.3, 122.5])

    end
# we can use these in any jldoctest now
```

# The Standalone Query Syntax

The standalone query syntax provides a set of commands starting with `@` that can be combined into a sequence or pipeline, using the pipe (`|>`) operator. The commands are:

- for selection and filtering: `@select` `@filter` `@take` `@drop` `@unique`  

- for mapping: `@map` `@mapmany`

- for grouping and joining: `@groupby` `@orderby` `@join` `@groupjoin`

- for changing columns and values: `@rename` `@mutate`

Here's a simple example, a DataFrame of fruits, amounts, and prices:

```
df = DataFrame(
    fruit    =  
    ["Apple", "Banana", "Cherry"],
    amount   =  [2, 6, 1000],
    price    =  [1.2, 2.0, 0.4],
    isyellow =  [false, true, false])

3×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 2      │ 1.2     │ 0        │
│ 2   │ Banana │ 6      │ 2.0     │ 1        │
│ 3   │ Cherry │ 1000   │ 0.4     │ 0        │
```

The following query pipes the rows of this dataframe first through the `@select` command to select just fruits and prices information, then through the `@filter` command to keep only the rows where the price is more than 1.5 \$€£.

```jldoctest
df |> @select(:fruit, :price) |> @filter(x -> x.price > 1.5) |> DataFrame

# output

1×2 DataFrame
│ Row │ fruit  │ price   │
│     │ String │ Float64 │
├─────┼────────┼─────────┤
│ 1   │ Banana │ 2.0     │
```

## Special syntax and shortcuts

As well as standard Julia macro calls and pipe operators, the query language provided in Query.jl features shortcuts that use syntax that's not currently available outside Query.jl.

### Shortcuts for anonymous functions

Instead of specifying an anonymous function in the form `x -> x > 5`, you can use a single underscore as the function's argument: `_` is converted to `_ -> _`. For example, `_.foo == 3` is converted to `_ -> _.foo==3`

The following two forms are equivalent:

```
df |> @filter(col -> col.price .> 1.5)
```

```
df |> @filter(_.price .> 1.5)
```

It's also possible to use a doubled underscore `__` to provide the second argument to an anonymous function that expects two.

### Shortcut for creating named tuples in Query

Query.jl allows a special form for defining named tuples that is available only inside query commands. This enhanced syntax is based on curly brackets `{}`, and is particularly useful in `@map` commands.

You can create a named tuple with the following syntax:

```
{fieldname = value, fieldname2 = value2, fieldname3 = value3}
```

which is equivalent to the standard Julia syntax:

```
(fieldname = value, fieldname2 = value2, fieldname3 = value3)
```

The next two lines produce the same result, with the second line using the more concise, enhanced syntax version. Notice that you don't have to supply fieldnames for the `name` and `mass` parts of the tuple.

```
pd |> @mapmany(i->i.gravity,
              (i, j) -> (name=i.name, mass=i.mass, earthmasses = j/9.8)) |>
        DataFrame

pd |> @mapmany(_.gravity, {_.name, _.mass, earthmasses=__/9.8}) |>
        DataFrame
```

With the curly bracket syntax, missing field names are replaced with the value in name form. The second fieldname in the second example will be `value2`, constructed from the value's name.

```
{fieldname1 = value1, fieldname2 = value2, fieldname3 = value3}
{fieldname1 = value1,              value2, fieldname3 = value3}
```

### Shortcut for generator syntax

You can use two periods to define a generator. For example:

```
x..y
```

is translated into

```
i.y for i in x
```

For example:

```
{mean(_..Acceleration)}
```

will apply `mean()` to every `.Acceleration` value in the element passed to it.

## Selection: @select

Use `@select` to pass one or more columns from the incoming source (a DataFrame) to the next part of the pipeline. Supply one or more clauses: each successive clause builds or modifies the selection.

You can select by name, by position, or using a predicate function. To select a single column (using the same `df` fruits DataFrame as before):

```jldoctest
df |> @select(:fruit) |> DataFrame

# output

3×1 DataFrame
│ Row │ fruit  │
│     │ String │
├─────┼────────┤
│ 1   │ Apple  │
│ 2   │ Banana │
│ 3   │ Cherry │
```

Select two columns by name (starting with a colon `:`).

```jldoctest
df |> @select(:fruit, :amount) |> DataFrame

# output

3×2 DataFrame
│ Row │ fruit  │ amount │
│     │ String │ Int64  │
├─────┼────────┼────────┤
│ 1   │ Apple  │ 2      │
│ 2   │ Banana │ 6      │
│ 3   │ Cherry │ 1000   │
```

Select all columns, but then deselect one of them by name:

```jldoctest
df |> @select(-:amount) |> DataFrame

# output

3×3 DataFrame
│ Row │ fruit  │ price   │ isyellow │
│     │ String │ Float64 │ Bool     │
├─────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 1.2     │ 0        │
│ 2   │ Banana │ 2.0     │ 1        │
│ 3   │ Cherry │ 0.4     │ 0        │
```

Select all but two named columns. Use `-` and `+` to remove or add columns to the selection.

```jldoctest
df |> @select(-:amount, -:isyellow) |> DataFrame

# output

3×2 DataFrame
│ Row │ fruit  │ price   │
│     │ String │ Float64 │
├─────┼────────┼─────────┤
│ 1   │ Apple  │ 1.2     │
│ 2   │ Banana │ 2.0     │
│ 3   │ Cherry │ 0.4     │

```

You can select columns by number (position). For example, to select columns 1 to 4 then deselect column 2

```jldoctest

df |> @select(1:4, -2) |> DataFrame

# output

3×3 DataFrame
│ Row │ fruit  │ price   │ isyellow │
│     │ String │ Float64 │ Bool     │
├─────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 1.2     │ 0        │
│ 2   │ Banana │ 2.0     │ 1        │
│ 3   │ Cherry │ 0.4     │ 0        │
```

It's possible to use a predicate function to select columns. Select a column that starts with a string:

```jldoctest
df |> @select(startswith("fru")) |> DataFrame

# output

3×1 DataFrame
│ Row │ fruit  │
│     │ String │
├─────┼────────┤
│ 1   │ Apple  │
│ 2   │ Banana │
│ 3   │ Cherry │

```
Select columns that start with either of two strings:

```jldoctest
df |> @select(startswith("fru"), startswith("amo")) |> DataFrame

# output

3×2 DataFrame
│ Row │ fruit  │ amount │
│     │ String │ Int64  │
├─────┼────────┼────────┤
│ 1   │ Apple  │ 2      │
│ 2   │ Banana │ 6      │
│ 3   │ Cherry │ 1000   │

```

Select all columns whose names contain a particular string:

```jldoctest
df |> @select(occursin("i")) |> DataFrame

# output

3×3 DataFrame
│ Row │ fruit  │ price   │ isyellow │
│     │ String │ Float64 │ Bool     │
├─────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 1.2     │ 0        │
│ 2   │ Banana │ 2.0     │ 1        │
│ 3   │ Cherry │ 0.4     │ 0        │
```

Notice that you can, in certain cases, use the alternative Julia format for supplying arguments to macros, ie using spaces rather than parentheses and commas:

```jldoctest
df |> @select occursin("i") startswith("fru") |> DataFrame

# output

3x3 query result
fruit  │ price │ isyellow
───────┼───────┼─────────
Apple  │ 1.2   │ false   
Banana │ 2.0   │ true    
Cherry │ 0.4   │ false   
```

Select column names that don't end with a particular string (so here the `:amount` column isn't selected):

```jldoctest
df |> @select(!endswith("t")) |> DataFrame

# output

3×2 DataFrame
│ Row │ price   │ isyellow │
│     │ Float64 │ Bool     │
├─────┼─────────┼──────────┤
│ 1   │ 1.2     │ 0        │
│ 2   │ 2.0     │ 1        │
│ 3   │ 0.4     │ 0        │

```

This deselects all columns that end with "t", then adds the `fruit` column (column 1) back:

```jldoctest
df |> @select(!endswith("t"), 1) |> DataFrame

# output

3×3 DataFrame
│ Row │ price   │ isyellow │ fruit  │
│     │ Float64 │ Bool     │ String │
├─────┼─────────┼──────────┼────────┤
│ 1   │ 1.2     │ 0        │ Apple  │
│ 2   │ 2.0     │ 1        │ Banana │
│ 3   │ 0.4     │ 0        │ Cherry │
```

Select columns 1 and 3, but not in that order:

```jldoctest
df |> @select(3, 1) |> DataFrame

# output

3×2 DataFrame
│ Row │ price   │ fruit  │
│     │ Float64 │ String │
├─────┼─────────┼────────┤
│ 1   │ 1.2     │ Apple  │
│ 2   │ 2.0     │ Banana │
│ 3   │ 0.4     │ Cherry │
```

Select two columns by supplying two strings that the column names contain:

```jldoctest
df |> @select(occursin("ui"), occursin("ice")) |> DataFrame

# output

3×2 DataFrame
│ Row │ fruit  │ price   │
│     │ String │ Float64 │
├─────┼────────┼─────────┤
│ 1   │ Apple  │ 1.2     │
│ 2   │ Banana │ 2.0     │
│ 3   │ Cherry │ 0.4     │

```

Select all columns containing one string but then remove any that contain another string:

```jldoctest
df |> @select(occursin("i"), -occursin("r")) |> DataFrame

# output

3×1 DataFrame
│ Row │ isyellow │
│     │ Bool     │
├─────┼──────────┤
│ 1   │ 0        │
│ 2   │ 1        │
│ 3   │ 0        │
```

## Filtering: @filter

Use the `@filter` operation to filter (which, as elsewhere in Julia, means "keep") items in the source, using an anonymous function that returns true or false. If the function returns true, the item is kept and passed on to the next stage of the pipeline.

In these examples, the `@filter` operation receives all the rows of the fruity dataframe `df`.

To keep all rows where the value for `:amount` is greater than 2:

```jldoctest
df |> @filter(col -> col.amount > 2) |> DataFrame

# output

2×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Banana │ 6      │ 2.0     │ 1        │
│ 2   │ Cherry │ 1000   │ 0.4     │ 0        │

```

To keep all rows where the name of the fruit starts with a consonant. This uses a regular expression.

```jldoctest
df |> @filter(col -> !startswith(col.fruit, r"A|E|I|O|U")) |> DataFrame

# output

2×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Banana │ 6      │ 2.0     │ 1        │
│ 2   │ Cherry │ 1000   │ 0.4     │ 0        │
```

To keep all rows where the amount is greater than 10:

```jldoctest
df |> @filter(col -> col.amount > 10) |> DataFrame

# output

1×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Cherry │ 1000   │ 0.4     │ 0        │
```

Using the shortcut syntax mentioned earlier, you could obtain the same results with:

```jldoctest
df |> @filter(_.amount > 10) |> DataFrame

# output

1×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Cherry │ 1000   │ 0.4     │ 0        │
```

### Combining @filter and @select

Typically you might want to pass the output of the `@filter` command to a `@select` command:

```jldoctest
df |> @filter(col -> col.amount > 2) |> @select(:fruit, :price) |> DataFrame

# output

2×2 DataFrame
│ Row │ fruit  │ price   │
│     │ String │ Float64 │
├─────┼────────┼─────────┤
│ 1   │ Banana │ 2.0     │
│ 2   │ Cherry │ 0.4     │
```

Obviously, the order matters, because you can't filter by amount if that column wasn't selected in the previous stage of the pipeline.

```jldoctest
df |> @select(:fruit, :price) |> @filter(col -> col.price > 1.2)  |> DataFrame

# output

1×2 DataFrame
│ Row │ fruit  │ price   │
│     │ String │ Float64 │
├─────┼────────┼─────────┤
│ 1   │ Banana │ 2.0     │
```

## More selection: @unique, @take, @drop

### Unique

`@unique` passes only the unique rows through to the next command.

```jldoctest duplicaterow # keep this definition around for the next test
push!(df, df[1, :])

# output

4×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 2      │ 1.2     │ 0        │
│ 2   │ Banana │ 6      │ 2.0     │ 1        │
│ 3   │ Cherry │ 1000   │ 0.4     │ 0        │
│ 4   │ Apple  │ 2      │ 1.2     │ 0        │
```

```jldoctest duplicaterow
df |> @unique() |> DataFrame

# output

3×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 2      │ 1.2     │ 0        │
│ 2   │ Banana │ 6      │ 2.0     │ 1        │
│ 3   │ Cherry │ 1000   │ 0.4     │ 0        │

```

### Taking items

`@take(n)` selects the first `n` items from the source, with the syntax `source |> @take(n)`.

#### Examples

```jldoctest
df |> @take(2) |> DataFrame

# output

2×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Apple  │ 2      │ 1.2     │ 0        │
│ 2   │ Banana │ 6      │ 2.0     │ 1        │

```

The `source` is any source that can be queried. `n` must be an integer, and it specifies how many elements from the beginning of the source should be kept. The elements can be stored in an array using `collect()`.


```jldoctest
source = [1, 2, 3, 4, 5]

q = source |> @take(3) |> collect

println(q)

# output

[1, 2, 3]
```

```jldoctest
q = split("this is a string") |> @take(3) |> collect

# output

3-element Array{SubString{String},1}:
 "this"
 "is"  
 "a"   
```

### Dropping items

Use `@drop(n)` to drop `n` elements from the beginning of the source. The `@drop` command has the form `source |> @drop(n)`.

#### Example

```jldoctest
df |> @drop(2) |> DataFrame

# output

1×4 DataFrame
│ Row │ fruit  │ amount │ price   │ isyellow │
│     │ String │ Int64  │ Float64 │ Bool     │
├─────┼────────┼────────┼─────────┼──────────┤
│ 1   │ Cherry │ 1000   │ 0.4     │ 0        │
```

## Sorting data: @orderby, @thenby

To sort data, you can use the following commands:

- `@orderby` - primary sort in ascending order (so "A" before "a", 1 before 2)
- `@orderby_descending` - primary sort in descending order ("a" before "A", 2 before 1)
- `@thenby` - secondary sort in ascending order ("A"|"A" before "A"|"B")
- `@thenby_descending` - secondary sort in descending order ("A"|"B" before "A"|"A")

The general for sorting commands is `source |> @orderby(key_selector)`.

`source` is any source that can be queried. `key_selector` must be an anonymous function that returns a value for each element of `source`. The elements of the source are then sorted in ascending order by the value returned from the `key_selector` function.

In the following examples, we'll use some data about the planets in the solar system, stored in a DataFrame `pd`:

```
pd

9×12 DataFrame
│ Row │ name    │ mass    │ diameter │ gravity │ rotationperiod │ lengthday │ distancesun │ meantemperature │ surfacepressure │ moons │ type   │ rings │
│     │ String  │ Float64 │ Int64    │ Float64 │ Float64        │ Float64   │ Float64     │ Int64           │ Float64⍰        │ Int64 │ String │ Bool  │
├─────┼─────────┼─────────┼──────────┼─────────┼────────────────┼───────────┼─────────────┼─────────────────┼─────────────────┼───────┼────────┼───────┤
│ 1   │ mercury │ 0.33    │ 4879     │ 3.7     │ 1407.6         │ 4222.6    │ 57.9        │ 167             │ 0.0             │ 0     │ rock   │ 0     │
│ 2   │ venus   │ 4.87    │ 12104    │ 8.9     │ -5832.5        │ 2802.0    │ 108.2       │ 464             │ 92.0            │ 0     │ rock   │ 0     │
│ 3   │ earth   │ 5.97    │ 12756    │ 9.8     │ 23.9           │ 24.0      │ 149.6       │ 15              │ 1.0             │ 1     │ rock   │ 0     │
│ 4   │ mars    │ 0.642   │ 6792     │ 3.7     │ 24.6           │ 24.7      │ 227.9       │ -65             │ 0.01            │ 2     │ rock   │ 0     │
│ 5   │ jupiter │ 1898.0  │ 142984   │ 23.1    │ 9.9            │ 9.9       │ 778.6       │ -110            │ missing         │ 79    │ gas    │ 1     │
│ 6   │ saturn  │ 568.0   │ 120536   │ 9.0     │ 10.7           │ 10.7      │ 1433.5      │ -140            │ missing         │ 62    │ gas    │ 1     │
│ 7   │ uranus  │ 86.8    │ 51118    │ 8.7     │ -17.2          │ 17.2      │ 2872.5      │ -195            │ missing         │ 27    │ ice    │ 1     │
│ 8   │ neptune │ 102.0   │ 49528    │ 11.0    │ 16.1           │ 16.1      │ 4495.1      │ -200            │ missing         │ 14    │ ice    │ 1     │
│ 9   │ pluto   │ 0.0146  │ 2370     │ 0.7     │ -153.3         │ 153.3     │ 5906.4      │ -225            │ 1.0e-5          │ 5     │ ice    │ 0     │
```  

For example, to sort the planets in ascending order of name, use `@orderby` like this:

```jldoctest
pd |> @orderby(p -> p.name) |> @select(:name, :mass, :diameter) |> DataFrame

# output

9×3 DataFrame
│ Row │ name    │ mass    │ diameter │
│     │ String  │ Float64 │ Int64    │
├─────┼─────────┼─────────┼──────────┤
│ 1   │ earth   │ 5.97    │ 12756    │
│ 2   │ jupiter │ 1898.0  │ 142984   │
│ 3   │ mars    │ 0.642   │ 6792     │
│ 4   │ mercury │ 0.33    │ 4879     │
│ 5   │ neptune │ 102.0   │ 49528    │
│ 6   │ pluto   │ 0.0146  │ 2370     │
│ 7   │ saturn  │ 568.0   │ 120536   │
│ 8   │ uranus  │ 86.8    │ 51118    │
│ 9   │ venus   │ 4.87    │ 12104    │

```
The `@orderby_descending` command works in the same way, but sorts things in descending order.

Any sort has to start with either a `@orderby` or `@orderby_descending` command. You can then use `@thenby` and `@thenby_descending` commands to do secondary (and tertiary) sorts. These must directly follow a previous sorting command, and they specify how tied results from the previous sort are to be ordered.

#### Examples

This example sorts the planets first by `type` (the primary key), and then, within each type, by name (the secondary key):

```jldoctest
pd |> @orderby(p -> p.type) |> @thenby(p -> p.name) |> @select(:type, :name, :mass) |> DataFrame

# output

9×3 DataFrame
│ Row │ type   │ name    │ mass    │
│     │ String │ String  │ Float64 │
├─────┼────────┼─────────┼─────────┤
│ 1   │ gas    │ jupiter │ 1898.0  │
│ 2   │ gas    │ saturn  │ 568.0   │
│ 3   │ ice    │ neptune │ 102.0   │
│ 4   │ ice    │ pluto   │ 0.0146  │
│ 5   │ ice    │ uranus  │ 86.8    │
│ 6   │ rock   │ earth   │ 5.97    │
│ 7   │ rock   │ mars    │ 0.642   │
│ 8   │ rock   │ mercury │ 0.33    │
│ 9   │ rock   │ venus   │ 4.87    │

```

This example sorts the source by the length of the `name`.

```jldocset
pd |> @orderby(length(_.name)) |> @select(1:3) |> DataFrame

# output

9×3 DataFrame
│ Row │ name    │ mass    │ diameter │
│     │ String  │ Float64 │ Int64    │
├─────┼─────────┼─────────┼──────────┤
│ 1   │ mars    │ 0.642   │ 6792     │
│ 2   │ venus   │ 4.87    │ 12104    │
│ 3   │ earth   │ 5.97    │ 12756    │
│ 4   │ pluto   │ 0.0146  │ 2370     │
│ 5   │ saturn  │ 568.0   │ 120536   │
│ 6   │ uranus  │ 86.8    │ 51118    │
│ 7   │ mercury │ 0.33    │ 4879     │
│ 8   │ jupiter │ 1898.0  │ 142984   │
│ 9   │ neptune │ 102.0   │ 49528    │
```

## Mapping: @map, @mapmany

### The `@map` command

`@map` transforms a single element of a datasource, using an anonymous function.

The `@map` command has the form `source |> @map(element_selector)`. `source` is any source that can be queried. `element_selector` must be an anonymous function that accepts one element of the element type of the source and applies some transformation to this single element.

#### Example

In this example, each number from the source is squared and cubed, and named tuples (essentially a table) are constructed, using the special `{}` syntax.

```jldoctest
1:10 |> @map({x=_, xsquared=_^2, xcubed=_^3})

# output

10x3 query result
x  │ xsquared │ xcubed
───┼──────────┼───────
1  │ 1        │ 1     
2  │ 4        │ 8     
3  │ 9        │ 27    
4  │ 16       │ 64    
5  │ 25       │ 125   
6  │ 36       │ 216   
7  │ 49       │ 343   
8  │ 64       │ 512   
9  │ 81       │ 729   
10 │ 100      │ 1000    
```

### The @mapmany command

The `@mapmany` command has the form `source |> @mapmany(collection_selector, result_selector)`. `source` is any source that can be queried.

`collection_selector` must be an anonymous function that takes one argument and returns a collection.

`result_selector` must be an anonymous function that takes two arguments. It will be applied to each element of the intermediate collection.   You can indicate the first and second argument using `_` and `__`.

#### Examples

This example applies a simple division (by the mass of the Earth) to the mass of each of the planets, currently in multiples of 10²⁴ kilograms:

```jldoctest earthmass
earthmass = pd[pd[:, :name] .== "earth", :mass][1]

# or

earthmass = first(pd |> @select(:name, :mass) |> @filter(_.name.=="earth") |> collect).mass

pd |> @mapmany(_.mass, {Planet=_.name, Earth_Masses=__/earthmass}) |> DataFrame

# output

9×2 DataFrame
│ Row │ Planet  │ Earth_Masses │
│     │ String  │ Float64      │
├─────┼─────────┼──────────────┤
│ 1   │ mercury │ 0.0552764    │
│ 2   │ venus   │ 0.815745     │
│ 3   │ earth   │ 1.0          │
│ 4   │ mars    │ 0.107538     │
│ 5   │ jupiter │ 317.923      │
│ 6   │ saturn  │ 95.1424      │
│ 7   │ uranus  │ 14.5394      │
│ 8   │ neptune │ 17.0854      │
│ 9   │ pluto   │ 0.00244556   │

```

```jldoctest earthmass
pd |> @mapmany(_.mass, (Planet=_.name, Earth_Masses=__/earthmass)) |> DataFrame

# output

9×2 DataFrame
│ Row │ Planet  │ Earth_Masses │
│     │ String  │ Float64      │
├─────┼─────────┼──────────────┤
│ 1   │ mercury │ 0.0552764    │
│ 2   │ venus   │ 0.815745     │
│ 3   │ earth   │ 1.0          │
│ 4   │ mars    │ 0.107538     │
│ 5   │ jupiter │ 317.923      │
│ 6   │ saturn  │ 95.1424      │
│ 7   │ uranus  │ 14.5394      │
│ 8   │ neptune │ 17.0854      │
│ 9   │ pluto   │ 0.00244556   │
```

`@mapmany` is useful when combined with `@groupby`. The first argument is an anonymous function that will be called for each group, and returns a collection for each group. `@mapmany` calls the second anonymous function for each item in the collection that was returned by the first anonymous function. The call to this second anonymous function will take the group as argument `i` (`_`), and the individual row as argument `j` (`__`).

In this next example, the `mean` function is used to find the average number of moons for each type of planet.

```
pd |> @groupby(_.type) |>
      @mapmany(i -> i.name, (i, j) ->
        (Planet=j, Average_moonness=mean(i.moons))) |> DataFrame

# output

9×2 DataFrame
│ Row │ Planet  │ Average_moonness │
│     │ String  │ Float64          │
├─────┼─────────┼──────────────────┤
│ 1   │ mercury │ 0.75             │
│ 2   │ venus   │ 0.75             │
│ 3   │ earth   │ 0.75             │
│ 4   │ mars    │ 0.75             │
│ 5   │ jupiter │ 70.5             │
│ 6   │ saturn  │ 70.5             │
│ 7   │ uranus  │ 15.3333          │
│ 8   │ neptune │ 15.3333          │
│ 9   │ pluto   │ 15.3333          │

```

## Grouping and joining data: @join, @groupjoin, @groupby

### Group and join: @join, @groupjoin, @groupby

The  `@join` and `@group` commands can be used to join and combine two data sources that share information.

For example, suppose we have another DataFrame, `pdo`, that contains additional information about planetary orbits:

```
│ Row │ name    │ mass    │ escapevelocity │ perihelion │ aphelion │ orbitalperiod │ orbitalvelocity │
│     │ String  │ Float64 │ Float64        │ Float64    │ Float64  │ Float64       │ Float64         │
├─────┼─────────┼─────────┼────────────────┼────────────┼──────────┼───────────────┼─────────────────┤
│ 1   │ mercury │ 0.33    │ 4.3            │ 46.0       │ 69.8     │ 88.0          │ 47.4            │
│ 2   │ venus   │ 4.87    │ 10.4           │ 107.5      │ 108.9    │ 224.7         │ 35.0            │
│ 3   │ earth   │ 5.97    │ 11.2           │ 147.1      │ 152.1    │ 365.2         │ 29.8            │
│ 4   │ mars    │ 0.642   │ 5.0            │ 206.6      │ 249.2    │ 687.0         │ 24.1            │
│ 5   │ jupiter │ 1898.0  │ 59.5           │ 740.5      │ 816.6    │ 4331.0        │ 13.1            │
│ 6   │ saturn  │ 568.0   │ 35.5           │ 1352.6     │ 1514.5   │ 10747.0       │ 9.7             │
│ 7   │ uranus  │ 86.8    │ 21.3           │ 2741.3     │ 3003.6   │ 30589.0       │ 6.8             │
│ 8   │ neptune │ 102.0   │ 23.5           │ 4444.5     │ 4545.7   │ 59800.0       │ 5.4             │
│ 9   │ pluto   │ 0.0146  │ 1.3            │ 4436.8     │ 7375.9   │ 90560.0       │ 4.7             │

```

With the `@join` and `@group` commands, we can create output that matches and merges data from these two sources `pd` and `pdo` into a single result, if they have a column in common.

### The `@join` command

The `@join` command has the form `outer |> @join(inner, outer_selector, inner_selector, result_selector)`.

`outer` and `inner` are the sources that are being queried. `outer_selector` and `inner_selector` must be anonymous functions that extract the values from the outer and inner sources. The `result_selector` must be an anonymous function that takes two arguments. It will be called for each element in the result set: the first argument will hold the element from the outer source, and the second argument will hold the element from the inner source.

#### Examples

In the next example, the `pd` data source is the _outer_ source, the `pdo` is the _inner_. Both tables have a column in common - the column containing the planets' names. The following join command outputs a combination of the two tables, using the name to join them:

```jldoctest
pd |> @join(pdo,
      outer -> outer.name,
      inner -> inner.name, # matches name in outer source
      (outer, inner) -> (outer.name, inner.perihelion, inner.orbitalperiod)
      ) |> DataFrame

# output

9×3 DataFrame
│ Row │ 1       │ 2       │ 3       │
│     │ String  │ Float64 │ Float64 │
├─────┼─────────┼─────────┼─────────┤
│ 1   │ mercury │ 46.0    │ 88.0    │
│ 2   │ venus   │ 107.5   │ 224.7   │
│ 3   │ earth   │ 147.1   │ 365.2   │
│ 4   │ mars    │ 206.6   │ 687.0   │
│ 5   │ jupiter │ 740.5   │ 4331.0  │
│ 6   │ saturn  │ 1352.6  │ 10747.0 │
│ 7   │ uranus  │ 2741.3  │ 30589.0 │
│ 8   │ neptune │ 4444.5  │ 59800.0 │
│ 9   │ pluto   │ 4436.8  │ 90560.0 │
```

The alternative syntax for defining the result selector is like this:

```jldoctest
pd |> @join(pdo,
   _.name,
   _.name, # matches :name column in outer source
   {__.name, __.perihelion, __.orbitalperiod}) |> DataFrame

# output

9×3 DataFrame
│ Row │ name    │ perihelion │ orbitalperiod │
│     │ String  │ Float64    │ Float64       │
├─────┼─────────┼────────────┼───────────────┤
│ 1   │ mercury │ 46.0       │ 88.0          │
│ 2   │ venus   │ 107.5      │ 224.7         │
│ 3   │ earth   │ 147.1      │ 365.2         │
│ 4   │ mars    │ 206.6      │ 687.0         │
│ 5   │ jupiter │ 740.5      │ 4331.0        │
│ 6   │ saturn  │ 1352.6     │ 10747.0       │
│ 7   │ uranus  │ 2741.3     │ 30589.0       │
│ 8   │ neptune │ 4444.5     │ 59800.0       │
│ 9   │ pluto   │ 4436.8     │ 90560.0       │

```

### The @groupby command

`@groupby` returns groups of items from a data source.

There are two versions of the `@groupby` command. The simple version has the form `source |> @groupby(key_selector)`. `source` is any source that can be queried. `key_selector` must be an anonymous function that returns a value for each element of `source` by which the source elements should be grouped.

The second variant has the form `source |> @groupby(source, key_selector, element_selector)`. The definition of `source` and `key_selector` is the same as in the simple variant. `element_selector` must be an anonymous function that is applied to each element of the `source` before that element is placed into a group, i.e. this is a _projection_ function.

#### The key field

The return value of `@groupby` is an iterable of groups. Each group is itself a collection of data rows, and has a `key` field that is equal to the value the rows were grouped by. Often the next step in the pipeline will be to use `@map` with a function that acts on each group, summarizing it in a new data row.

#### Example

This example groups the planets according to their type (rocky, gaseous, or icy):

```jldoctest
pd |> @groupby(_.type) |> @map({Type=key(_), Count=length(_)}) |> DataFrame

# output

3×2 DataFrame
│ Row │ Type   │ Count │
│     │ String │ Int64 │
├─────┼────────┼───────┤
│ 1   │ rock   │ 4     │
│ 2   │ gas    │ 2     │
│ 3   │ ice    │ 3     │
```
This example calculates the mean mass for planets of each type.

```jldoctest
pd |> @groupby(_.type) |> @map({Type=key(_), Mean_mass=mean(_.mass)})

# output

3x2 query result
Type │ Mean_mass
─────┼──────────
rock │ 2.953    
gas  │ 1233.0   
ice  │ 62.9382  
```

### The @groupjoin command

The `@groupjoin` command has the form `outer |> @groupjoin(inner, outer_selector, inner_selector, result_selector)`.

`outer` and `inner` are the sources to be queried. `outer_selector` and `inner_selector` must be anonymous functions that extract the value from the outer and inner source respectively on which the join should be run. The `result_selector` must be an anonymous function that takes two arguments; first, the element from the `outer` source, and second, an array of those elements from the second source that are grouped together.

#### Example

```jldoctest
df1 = DataFrame(a=[1,2,3], b=[1.,2.,3.])
df2 = DataFrame(c=[2,4,2], d=["John", "Jim","Sally"])

x = df1 |> @groupjoin(df2, _.a, _.c, {t1=_.a, t2=length(__)}) |> DataFrame

println(x)

# output

3×2 DataFrame
│ Row │ t1    │ t2    │
│     │ Int64 │ Int64 │
├─────┼───────┼───────┤
│ 1   │ 1     │ 0     │
│ 2   │ 2     │ 2     │
│ 3   │ 3     │ 0     │
```

## Renaming columns and changing values: @rename and @mutate

### The @rename command

The `@rename` command has the form `source |> @rename(args...)`.

`source` is any source that can be queried. Each argument from `args...` must specify the name or index of the element, as well as the new name for the element. All `args...` are executed in order, and the result set of the previous renaming is the source of each current operation.

#### Example

This example renames two columns, and shows them in the result:

```jldoctest
pd |> @rename(:surfacepressure => :atmospheric_pressure,
              :name            => :planet)   |>
      @select(:planet, startswith("atm"))    |> DataFrame

# output

9×2 DataFrame
│ Row │ planet  │ atmospheric_pressure │
│     │ String  │ Float64⍰             │
├─────┼─────────┼──────────────────────┤
│ 1   │ mercury │ 0.0                  │
│ 2   │ venus   │ 92.0                 │
│ 3   │ earth   │ 1.0                  │
│ 4   │ mars    │ 0.01                 │
│ 5   │ jupiter │ missing              │
│ 6   │ saturn  │ missing              │
│ 7   │ uranus  │ missing              │
│ 8   │ neptune │ missing              │
│ 9   │ pluto   │ 1.0e-5               │

```

### The @mutate command

Use `@mutate` to modify values coming from the source.

The `@mutate` command has the form `source |> @mutate(args...)`. `source` is any source that can be queried.

Each `args` clause must specify the name of the element and the formula by which its values are transformed. The formula can contain elements of `source`. All `args` are executed in order, and the result set of the previous mutation is the source of each current mutation.

#### Example

This example makes a new column with every planet’s rotation period converted from hours to days, using the existing value in `rotationperiod`, and titlecases the planet's name.

```jldoctest

pd |> @mutate(rotation_days = (_.rotationperiod * 60)/ 1440,
              name = titlecase(_.name)) |>
      @select(1, 2, startswith("ro"))   |> DataFrame

# output

9×4 DataFrame
│ Row │ name    │ mass    │ rotationperiod │ rotation_days │
│     │ String  │ Float64 │ Float64        │ Float64       │
├─────┼─────────┼─────────┼────────────────┼───────────────┤
│ 1   │ Mercury │ 0.33    │ 1407.6         │ 58.65         │
│ 2   │ Venus   │ 4.87    │ -5832.5        │ -243.021      │
│ 3   │ Earth   │ 5.97    │ 23.9           │ 0.995833      │
│ 4   │ Mars    │ 0.642   │ 24.6           │ 1.025         │
│ 5   │ Jupiter │ 1898.0  │ 9.9            │ 0.4125        │
│ 6   │ Saturn  │ 568.0   │ 10.7           │ 0.445833      │
│ 7   │ Uranus  │ 86.8    │ -17.2          │ -0.716667     │
│ 8   │ Neptune │ 102.0   │ 16.1           │ 0.670833      │
│ 9   │ Pluto   │ 0.0146  │ -153.3         │ -6.3875       │

```

## Other commands

### The @count command

Use `@count` to return the number of elements in source, as an integer.

```jldoctest
pd |> @filter(_.mass .<= 1) |> @count

# output

3
```
