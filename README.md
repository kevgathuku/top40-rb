# top40-rb
A ruby script to display current UK Top 40 Charts and their Youtube links

This is the ruby port of my Python [`top-40`](https://github.com/kevgathuku/top40) program 

It simply fetches the songs in the current UK Top 40 charts and can also display their Youtube links on the command line


## Usage

`ruby top40`          - Displays the top 10 songs in the current UK Top 40 Charts  
`ruby top40 N`        - Displays the top `N` songs in the current UK Top 40 Charts i.e. up to a limit of 40  
`ruby top40 N links`  - Displays the top `N` songs in the charts along with their Youtube links  

## Why 

The script was rewritten in Ruby to avoid the need for a `DEVELOPER_KEY` when accessing YouTube.

The idea is to have as little dependencies as possible.

Youtube Access is instead enabled by the excellent [youtube_search](https://rubygems.org/gems/youtube_search) gem
since Google APIs have no native support for Ruby
