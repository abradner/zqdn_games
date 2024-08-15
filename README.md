# Alex's Games Server

Currently this is a backend for select puzzles from 最强大脑 (The Biggest Brain)

## Puzzles

### Grid Puzzle

```text
⌜            ⌝
⚔️🔺🔺🔺🔺🔵
🔺🔺🔵🔵🔵⚔️
⚔️🔵🌲🌲🌲⚔️
⚔️🔺🔵🔵🔵⚔️
🔵🔺🔵🔵🔵🔵
⚔️🔺🔺🔺🔺🔵
⌞            ⌟
```

S11E03 @ 16:45ish - https://youtu.be/DWWATa2CkW8?t=1000
Rules:
- 6x6 Grid
- You can place 7 squares of different sizes (two each of 1x1, 2x2, 3x3, and one 4x4)
- You need to find a combination of squares that match the 'heatmap' of the supplied grid
- The heatmap is a 6x6 grid with different symbols in each cell
- Symbols are as follows, note: **Some symbols are ambiguous**:
    - ⚔: Empty _[NB: currently displays as '0']_
    - 🔺: Covered by either 1 or 3 squares _[NB: currently displays as '1']_
    - 🔵: Covered by either 0 or 2 squares _[NB: currently displays as '2']_
    - 🌲: Covered by 4 squares _[NB: currently displays as '4']_


## CLI

The game is playable in a rails console - launch with `rails c`

eg:

```ruby
>> g = Grid.new(seed: 123, size: 6)
# placement algorithm recognises an invalid placement and retries
seed 123 failed to place a 2x2 component at [2, 3], retrying... 
=> #<Grid:0x0000000161107180 @construction=[
# {:size=>4, :top_left=>[2, 1]},
# {:size=>3, :top_left=>[2, 2]},
# {:size=>3, :top_left=>[0, 2]},
# {:size=>2, :top_left=>[1, 3]},
# {:size=>2, :top_left=>[1, 1]},
# {:size=>1, :top_left=>[0, 1]},
# {:size=>1, :top_left=>[1, 0]}],
# @matrix=Matrix[
# [0, 1, 1, 1, 1, 0],
# [1, 1, 2, 2, 2, 0],
# [0, 2, 4, 4, 4, 0],
# [0, 1, 2, 2, 2, 0],
# [0, 1, 2, 2, 2, 0],
# [0, 1, 1, 1, 1, 0]
# ],
# @proposed=Matrix[
# [0, 0, 0, 0, 0, 0],
# [0, 0, 0, 0, 0, 0], 
# [0, 0, 0, 0, 0, 0], 
# [0, 0, 0, 0, 0, 0], 
# [0, 0, 0, 0, 0, 0], 
# [0, 0, 0, 0, 0, 0]],
# @rng=#<Random:0x0000000160fd94e8>,
# @size=6 >

>> g.show # Show the current grid to the console
Seed: 123
⌜            ⌝
 ⚔️🔺🔺🔺🔺🔵 
 🔺🔺🔵🔵🔵⚔️ 
 ⚔️🔵🌲🌲🌲⚔️ 
 ⚔️🔺🔵🔵🔵⚔️ 
 🔵🔺🔵🔵🔵🔵 
 ⚔️🔺🔺🔺🔺🔵 
⌞            ⌟
=> nil

>> g.add_to_proposed_solution!(4, [0, 1]) # Add a valid placement to the solution, in this case a 4x4 at row 0, column 1
=> Matrix[
    [0, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0]
  ]

>> g.add_to_proposed_solution!(3, [1, 3]) # Showing error handling (and also a bug in plcement)
app/services/grid.rb:53:in 'add_to_proposed_solution!': bad solution (ArgumentError)

      raise ArgumentError, "bad solution".freeze
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	from (games):5:in '<main>'

>> g.add_to_proposed_solution!(3, [1, 2]) # Add a second valid placement to the solution
=> Matrix[
    [0, 1, 1, 1, 1, 0],
    [0, 1, 2, 2, 2, 0],
    [0, 1, 2, 2, 2, 0],
    [0, 1, 2, 2, 2, 0],
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0]
  ]

>> g.solved?
=> false
```

## API

### Docs will move to a separate file soon

### `GET /grid` New game

#### Query Params
```ruby
size: Integer # optional, eg 6
seed: BigInt # optional, eg 123
```

Response
```json
{
  "seed": 123,
  "size": 6,
  "solution": false,
  "grid": {
    "seed": 123,
    "size": 6,
    "sub_grids": [1, 1, 2, 2, 3, 3, 4],
    "matrix": [
      [0, 1, 1, 1, 1, 2],
      [1, 1, 2, 2, 2, 0],
      [0, 2, 4, 4, 4, 0],
      [0, 1, 2, 2, 2, 0],
      [2, 1, 2, 2, 2, 2],
      [0, 1, 1, 1, 1, 2]
    ]
  }
}
```

### `GET /grid/:id` Show Solution

URL Params
```ruby
id: Integer # eg 123
```

Query Params 
```ruby
size: Integer # optional, eg 6
```

Response
```json
{
  "seed": 123,
  "size": 6,
  "solution": true,
  "grid": {
    "seed": 123,
    "size": 6,
    "sub_grids": [1, 1, 2, 2, 3, 3, 4],
    "matrix": [
      [0, 1, 1, 1, 1, 0],
      [1, 1, 2, 2, 2, 0],
      [0, 2, 4, 4, 4, 0],
      [0, 1, 2, 2, 2, 0],
      [0, 1, 2, 2, 2, 0],
      [0, 1, 1, 1, 1, 0]
    ],
    "construction": [
      {
        "size": 4,
        "top_left": [2, 1]
      },
      {
        "size": 3,
        "top_left": [2, 2]
      },
      {
        "size": 3,
        "top_left": [0, 2]
      },
      {
        "size": 2,
        "top_left": [1, 3]
      },
      {
        "size": 2,
        "top_left": [1, 1]
      },
      {
        "size": 1,
        "top_left": [0, 1]
      },
      {
        "size": 1,
        "top_left": [1, 0]
      }
    ]
  }
}
```

#### `PATCH /grid/:id` Attempt to solve 

URL Params
```ruby
id: Integer # eg 123
```

Body
```json
{
  "size": 6,
  "proposals": [
    {
      "size": 4,
      "top_left": [0, 1]
    },
    {
      "size": 3,
      "top_left": [2, 2]
    },
    {
      "size": 3,
      "top_left": [0, 2]
    },
    {
      "size": 2,
      "top_left": [2, 1]
    },
    {
      "size": 2,
      "top_left": [3, 2]
    },
    {
      "size": 1,
      "top_left": [2, 1]
    },
    {
      "size": 1,
      "top_left": [3, 1]
    }
  ]
}
```

Response
```json
{
  "seed": 123,
  "size": 1,
  "proposed_solution": [
    [0, 1, 1, 1, 1, 0],
    [0, 1, 1, 1, 1, 0],
    [0, 2, 2, 2, 2, 0],
    [0, 1, 2, 2, 2, 0],
    [0, 0, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 0]
  ],
  "solved": false,
  "grid": {
    "seed": 123,
    "size": 6,
    "sub_grids": [1, 1, 2, 2, 3, 3, 4],
    "matrix": [
      [0, 1, 1, 1, 1, 2],
      [1, 1, 2, 2, 2, 0],
      [0, 2, 4, 4, 4, 0],
      [0, 1, 2, 2, 2, 0],
      [2, 1, 2, 2, 2, 2],
      [0, 1, 1, 1, 1, 2]
    ]
  },
  "errors": [
    [
      {
        "size": 3,
        "top_left": [0, 2]
      },
      "bad solution"
    ],
    [
      {
        "size": 2,
        "top_left": [2, 1]
      },
      "bad solution"
    ],
    [
      {
        "size": 2,
        "top_left": [3, 2]
      },
      "bad solution"
    ],
    [
      {
        "size": 1,
        "top_left": [3, 1]
      },
      "bad solution"
    ]
  ]
}
```

## Development Setup

### Prerequisites

- Ruby ~> 3.3.4
- Rails ~> 7.2.0rc1
- PostgreSQL >= 15.0 (currently unutilized, but will be soon)

### Client

The web client for this project can be found [here](https://github.com/abradner/zqdn_client)

### Installation

#### Environment
1. Clone the repository
2. Copy .env.example to .env and update the values as needed
3. Run `bundle install` to install dependencies

#### Database
1. Have a look in config/database.yml to ensure the settings are sane for your setup
2. Launch an instance of postgres if needed
   - `docker run --name zqdn_postgres -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres`
3. Run `rails db:create db:migrate` to create and migrate the database

#### Launch
Run `rails s` to start the development server

## Contributing

1. Fork the repository
2. Follow the code style and conventions (rubocop your code before committing)
3. Create a new PR from your fork, tagging me (@abradner) for review
