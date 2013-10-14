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

  lineMouseover = (id, indirect) ->

    if id
      line = d3.select("#{id}")
    else
      line = d3.select(this)

    line.transition()
        .duration(duration)
        .attr("height", increasedHeight)


    unless indirect
      # cut "line_" away
      id = line.attr("id").slice(5)

      countyMouseover("path_#{id}", true)

  lineMouseout = (id, indirect) ->

    if id
      line = d3.select("#{id}")
    else
      line = d3.select(this)

    line
      .transition()
        .delay(duration/2)
        .duration(duration)
        .attr("height", height)

    unless indirect
      id = line.attr("id").slice(5)
      countyMouseout("path_#{id}", true)

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

  countyMouseover = (id, indirect) ->
    if id
      county = d3.select("##{id}")
    else
      county = d3.select(this)

    county.transition()
        .duration(duration/2)
        .attr("fill", "blue")

    unless indirect
      id = county.attr("id").slice(5)
      lineMouseover("#line_#{id}", true)

  countyMouseout = (id, indirect) ->
    if id
      county = d3.select("##{id}")
    else
      county = d3.select(this)

    county.transition()
        .duration(duration)
        .attr("fill", "white")

    unless indirect
      id = county.attr("id").slice(5)
      lineMouseout("#line_#{id}", true)


  drawLines = ->
    # Make an SVG Container
    svgContainer = d3.select("svg").append("g") #.attr("width", width).attr("height", height)

    for i in [0...amount]

      # Draw the Rectangle
      angleRad = i * 2 * Math.PI / amount
      angleDegree = i * 360 / amount

      marginTop = Math.cos(angleRad) * radius + offset
      marginRight = - Math.sin(angleRad) * radius + offset
      rectangle = svgContainer.
        append("rect").
        attr("width", width).
        attr("height", height - 30*i/amount).
        attr("fill", "black").
        attr("transform",
            "translate(#{marginRight}, #{marginTop}) rotate(#{angleDegree})"
        ).
        on("mouseover", lineMouseover).
        on("mouseout", lineMouseout)

    d3.selectAll("rect").attr("id", (d, i) -> return "line_" + i)

  addCountyMouseEvents = ->

    d3.selectAll("path").each( ->
      d3.select(this).on("mousemove", countyMouseover).on("mouseout", countyMouseout)
    )

  setUp = ->
    drawLines()
    addCountyMouseEvents()

    fitMapToCircle()

  setUp()

)