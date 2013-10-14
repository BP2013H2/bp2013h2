require.config(
  baseUrl: 'js/libs'
)

require(["jquery", "d3.v3"],  ->
  
  duration = 250
  amount = 299
  width = 3
  height = 100
  increasedHeight = 150
  radius = 250
  offset = radius + increasedHeight

  fitMapToCircle = ->
    map = d3.select("#map")
    mapBB = map[0][0].getBBox()
    h = mapBB.height
    w = mapBB.width
    magicIncreasement = 1.25
    scale = magicIncreasement * Math.sqrt(2)*radius / h

    diff = scale*(h - w)

    # debugger
    # translate
    offsetMap = (offset - radius/Math.sqrt(2)) / magicIncreasement
    map.attr("transform",
      "translate(#{offsetMap + diff/2}, #{offsetMap})
       scale(#{scale}, #{scale})")

  lineMouseover = (data, index, indirect) ->

    line = d3.select("#line_#{index}")
    line.transition()
        .duration(duration)
        .attr("height", increasedHeight)

    unless indirect
      # cut "line_" away
      id = line.attr("id").slice(5)
      countyMouseover(null, id, true)

  lineMouseout = (data, index, indirect) ->

    line = d3.select("#line_#{index}")
    line
      .transition()
        .delay(duration/2)
        .duration(duration)
        .attr("height", data * height / 100)

    unless indirect
      id = line.attr("id").slice(5)
      countyMouseout(null, id, true)


  countyMouseover = (data, index, indirect) ->
    county = d3.select("#county_#{index}")
    county.transition()
        .duration(duration/2)
        .attr("fill", "blue")

    unless indirect
      id = county.attr("id").slice(7)
      lineMouseover(d3.select("#line_#{id}").data(), id, true)

  countyMouseout = (data, index, indirect) ->
    county = d3.select("#county_#{index}")
    county.transition()
        .duration(duration)
        .attr("fill", "white")

    unless indirect
      id = county.attr("id").slice(7)
      lineMouseout(d3.select("#line_#{id}").data(), id, true)

  genericMouseHandler = ->
    return (data, index, indirect) ->

  getDataset = ->
    
    dataset = []
    for i in [0...amount]
      dataset.push(Math.random() * 100)

    dataset.sort( (a, b) -> a - b )
    return dataset

  
  drawLines = (dataset) ->

    d3.select("svg").append("g")
      .selectAll("rect")
      .data(dataset)
      .enter()
      .append("rect")
      .attr("width", width)
      .attr("height", (d, i) -> d * height / 100)
      .attr("fill", "black")
      .attr("transform", (d, i) ->
        angleRad = i * 2 * Math.PI / amount
        angleDegree = i * 360 / amount

        marginTop = Math.cos(angleRad) * radius + offset
        marginRight = - Math.sin(angleRad) * radius + offset

        return "translate( #{marginRight}, #{marginTop} )   rotate(#{angleDegree})"
      )
      .attr("id", (d, i) -> return "line_" + i)
      .on("mouseover", lineMouseover)
      .on("mouseout", lineMouseout)

  addCountyMouseEvents = (dataset) ->

    d3.selectAll("path").data(dataset).on("mousemove", countyMouseover).on("mouseout", countyMouseout)

  setUp = ->

    dataset = getDataset()
    drawLines(dataset)
    addCountyMouseEvents(dataset)

    fitMapToCircle()

  setUp()

)