require.config(
  baseUrl: 'js/libs'
)

require(["jquery", "d3.v3"],  ->

  class InfinitePie

    WIDTH: 50

    constructor: (@inner_radius, @outer_radius) ->
      
      @drawPie()


    drawPie: ->

      getColor = d3.scale.category20c()

      data = [{"label":"one", "value":20},
               {"label":"two", "value":50},
               {"label":"three", "value":30}]


      pie = d3.layout.pie().value( (d) -> d.value ).endAngle(Math.PI)
      arc = d3.svg.arc().outerRadius(@outer_radius).innerRadius(@inner_radius)

      arcContainer = d3.select("svg")
        .append("g")
        .data([data])
        .attr("transform", "translate(" + @outer_radius + "," + @outer_radius + ")")

      arcs = arcContainer
              .selectAll("g.slice")
              .data(pie)
              .enter()
              .append("g")
              .attr("class", "slice")

      arcs.append("path")
          .attr("d", arc)
          .attr("fill", (d, i) => getColor(i))


      # captions doesn't work?

      # arcs.append("svg:text")
      #     .attr("transform", (d) ->
      #         d.innerRadius = 0
      #         d.outerRadius = 100
      #         return "translate" + arc.centroid(d) + ")"
      #     )
      #     .attr("text-anchor", "middle")
      #     .text((d, i) => data[i].label)

    stackPie: ->

      
      data = [{"label":"one", "value":20},
               {"label":"two", "value":50},
               {"label":"three", "value":30}]

      new InfinitePie(@outer_radius, @outer_radius + @WIDTH)


  pie = new InfinitePie(50, 100)
  pie.stackPie()

)