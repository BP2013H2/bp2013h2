require(["libs/d3.v3"], ->
  

  # Make an SVG Container
  svgContainer = d3.select("body").append("svg") #.attr("width", width).attr("height", height)

  size = 50

  width = 10
  height = 100

  for i in [0...size]

    # Draw the Rectangle
    angle = i * 360 / size

    offsetX = 500
    offsetY = 500

    marginTop = - Math.cos(angle) * height + offsetY
    marginRight = Math.sin(angle) * width + offsetX
    rectangle = svgContainer.append("rect").attr("width", width).attr("height", height).attr("transform", "translate(#{marginTop}, #{marginRight}) rotate(#{angle})")
  

)