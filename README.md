# top40-rb
A ruby script to display current UK Top 40 Charts and their Youtube links

This is the ruby port of the Python [`top-40`](https://github.com/kevgathuku/top40) program

It fetches the songs in the current UK Top 40 charts and can optionally display
their Youtube links on the command line

## Installation

Clone the repository:

```sh
git clone https://github.com/kevgathuku/top40-rb
```

Install the package dependencies:

```sh
cd top40-rb
bundle install
```

Create a `.env` file where we will store our API Key to enable accessing YouTube data.

```
YOUTUBE_DEVELOPER_KEY='add-your-api-key-here'
```

To obtain one, please follow the instructions [here](https://developers.google.com/youtube/registering_an_application#Create_API_Keys)

## Usage

`ruby top40.rb`                  - Displays the top 10 songs in the current UK Top 40 Charts  
`ruby top40.rb -n NUM`           - Displays the top `NUM` songs in the current UK Top 40 Charts
                                   i.e. up to a limit of 40  
`ruby top40.rb --links`   - Displays the top 10 songs in the charts along with their Youtube links
`ruby top40.rb -n NUM --links`   - Displays the top `NUM` songs in the charts along with their Youtube links  

## Why

The main purpose of this script is to be able to access the current UK Top 40 Charts
from the command line, and without having to search YouTube for every song individually,
when you can just do this from the comfort of the command line 😄 

Youtube Access is instead enabled by the excellent
[yt](https://rubygems.org/gems/yt) gem.
This script also utilizes the awesome [Moneta](https://rubygems.org/gems/moneta) and [APICache](https://rubygems.org/gems/api_cache) gems for caching results.
