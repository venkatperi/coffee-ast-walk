module.exports = class Location
  constructor : ( opts = {} ) ->
    @from = opts.first_line or opts.from
    @to = opts.last_line or opts.to
    @startCol = opts.first_column or opts.startCol
    @endCol = opts.last_column or opts.endCol
    @isMultiline = @startCol == @endCol and @from < @to

  @union : ( locations... ) ->
    [min,max] = [ Number.MAX_VALUE, Number.MIN_VALUE ]
    for item in locations
      min = item.from if item.from < min
      max = item.to if item.to > max
    new Location from : min, to : max

  @sort : ( locations... ) ->
    locations.sort ( a, b ) -> a.from - b.from

  @gaps : ( locations... ) ->
    sorted = locations.sort ( a, b ) -> a.from - b.from
    gaps = []
    if sorted.length > 1
      for i in [ 0..sorted.length - 2 ]
        unless sorted[ i ].to is sorted[ i + 1 ].from
          gaps.push new Location
            from : sorted[ i ].to + 1, to : sorted[ i + 1 ].from - 1
    gaps
    
  
      
      

  
