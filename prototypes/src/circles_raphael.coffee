require(["libs/raphael-min"], (Raphael) ->

  width = 1920
  height = 1080
  radius = 10

  paper = Raphael("chart", width, height)

  # create some circles and save them in an array
  circles = []

  for i in [0..Math.random() * 200]

    circle = paper.circle(
      Math.random() * (width - radius)
      Math.random() * (height - radius)
      radius
    )

    # creates a random hex color (16777215 == ffffff in decimal)
    randomColor = '#'+Math.floor(Math.random() * 16777215).toString(16)

    circle.attr({"fill" : randomColor, "fill-opacity" : 0.5, "stroke" : randomColor})

    circles.push(circle)


  animateBegin = {}
  animateEnd = {}

  pointer = paper.circle(0, 0, 10).attr({"stroke" : "#01dfd7", "stroke-width" : 4, "stroke-opacity" : 0.5})

  # add a nice little fade effect once the pointer reaches a circle
  fade = (id) ->
    -> 
      circles[id].attr({"fill" : "#fff", "r" : 12}).animate({"fill" : "#666", "r" : 8}, 500)

  # animate the pointer to visit all circles
  for j in [0...circles.length]

    c = circles[j]

    animateBegin["" + Math.floor(100 * j / circles.length) + "%"] = {
      "cy" : c.attr("cy")
      "easing" : "ease in"
      "callback" : fade(j)
    }
    animateEnd["" + Math.floor(100 * j / circles.length) + "%"] = {
      "cx" : c.attr("cx")
      "easing" : "ease in"
    }

    pointer.stop().animate(animateBegin, 1000 * circles.length).animate(animateEnd, 1000 * circles.length)
)