require.config(
  baseUrl: 'js/libs'
)

require(["jquery", "d3.v3"],  ->

  class Category

    constructor: () ->

      @drawSquare()

    drawSquare: ->

      data2 = [{"label":"Wahlenscheidung"},
              {"label":"Ost/West"},
              {"label":"Alter"},
              {"label":"Tätigkeit"},
              {"label":"Geschlecht"},
              {"label":"Beruf"},
              {"label":"Schulabschluss"},
              {"label":"Haushaltseinkommen"}]

      rects = d3.select("svg").append("g")
        .selectAll("rect")
        .data(data2)
        .enter()
        .append("rect")

      rects
        .append("svg:text")        
        .attr("width", 100)
        .attr("height", 300 )
        .text((d, i) => data2[i].label)

     #

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
  c = new Category()

)