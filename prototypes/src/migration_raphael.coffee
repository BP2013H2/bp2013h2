partyData = {nodes: [{name: "CDU/CSU","class": "cdu-csu", "color": "#000000"}, {name: "SPD","class": "spd", "color": "#ff0000"}, {name: "FDP","class": "fdp", "color": "#ffcc00"}, {name: "Die Linke","class": "die-linke", "color": "#800080"}, {name: "Die Grünen","class": "die-gruenen", "color": "#008000"}, {name: "Andere","class": "andere", "color": "#0000ff"}, {name: "Nichtwähler","class": "nichtwaehler", "color": "#c0c0c0"}, {name: "Erstwähler","class": "erstwaehler", "color": "#ff00ff"}, {name: "Zugezogene","class": "zugezogene", "color": "#808080"}, {name: "CDU/CSU","class": "cdu-csu", "color": "#000000"}, {name: "SPD","class": "spd", "color": "#ff0000"}, {name: "FDP","class": "fdp", "color": "#ffcc00"}, {name: "Die Linke","class": "die-linke", "color": "#800080"}, {name: "Die Grünen","class": "die-gruenen", "color": "#008000"}, {name: "Andere","class": "andere", "color": "#0000ff"}, {name: "Nichtwähler","class": "nichtwaehler", "color": "#c0c0c0"}, {name: "Gestorbene","class": "gestorbene", "color": "#808080"}],links: [{source: 0,target: 9,value: "10550000"}, {source: 1,target: 9,value: "1340000"}, {source: 2,target: 9,value: "750000"}, {source: 3,target: 9,value: "120000"}, {source: 4,target: 9,value: "170000"}, {source: 5,target: 9,value: "190000"}, {source: 6,target: 9,value: "960000"}, {source: 7,target: 9,value: "510000"}, {source: 8,target: 9,value: "60000"}, {source: 0,target: 10,value: "460000"}, {source: 1,target: 10,value: "7650000"}, {source: 2,target: 10,value: "190000"}, {source: 3,target: 10,value: "180000"}, {source: 4,target: 10,value: "500000"}, {source: 5,target: 10,value: "40000"}, {source: 6,target: 10,value: "560000"}, {source: 7,target: 10,value: "370000"}, {source: 8,target: 10,value: "40000"}, {source: 0,target: 11,value: "1890000"}, {source: 1,target: 11,value: "720000"}, {source: 2,target: 11,value: "2650000"}, {source: 3,target: 11,value: "80000"}, {source: 4,target: 11,value: "110000"}, {source: 5,target: 11,value: "100000"}, {source: 6,target: 11,value: "480000"}, {source: 7,target: 11,value: "280000"}, {source: 8,target: 11,value: "20000"}, {source: 0,target: 12,value: "160000"}, {source: 1,target: 12,value: "1280000"}, {source: 2,target: 12,value: "60000"}, {source: 3,target: 12,value: "2570000"}, {source: 4,target: 12,value: "270000"}, {source: 5,target: 12,value: "130000"}, {source: 6,target: 12,value: "430000"}, {source: 7,target: 12,value: "230000"}, {source: 8,target: 12,value: "3000000"}, {source: 0,target: 13,value: "220000"}, {source: 1,target: 13,value: "1370000"}, {source: 2,target: 13,value: "80000"}, {source: 3,target: 13,value: "130000"}, {source: 4,target: 13,value: "2150000"}, {source: 5,target: 13,value: "40000"}, {source: 6,target: 13,value: "290000"}, {source: 7,target: 13,value: "330000"}, {source: 8,target: 13,value: "20000"}, {source: 0,target: 14,value: "210000"}, {source: 1,target: 14,value: "360000"}, {source: 2,target: 14,value: "130000"}, {source: 3,target: 14,value: "130000"}, {source: 4,target: 14,value: "210000"}, {source: 5,target: 14,value: "940000"}, {source: 6,target: 14,value: "300000"}, {source: 7,target: 14,value: "320000"}, {source: 8,target: 14,value: "20000"}, {source: 0,target: 15,value: "2040000"}, {source: 1,target: 15,value: "2600000"}, {source: 2,target: 15,value: "550000"}, {source: 3,target: 15,value: "730000"}, {source: 4,target: 15,value: "320000"}, {source: 5,target: 15,value: "350000"}, {source: 6,target: 15,value: "10830000"}, {source: 7,target: 15,value: "1340000"}, {source: 8,target: 15,value: "40000"}, {source: 0,target: 16,value: "1080000"}, {source: 1,target: 16,value: "880000"}, {source: 2,target: 16,value: "230000"}, {source: 3,target: 16,value: "200000"}, {source: 4,target: 16,value: "120000"}, {source: 5,target: 16,value: "70000"}, {source: 6,target: 16,value: "720000"}]};


require(["libs/raphael-min", "libs/lodash.min"], (Raphael) ->

  WIDTH = HEIGHT = 700
  BEZIER_DISTANCE = 300
  RECT_WIDTH = 100
  RECT_MARGIN = 20
  NUM_PARTIES = 9
  
  paper = Raphael("chart", WIDTH, HEIGHT)

  curve = (x1, y1, x2, y2, width, color) ->

    path = [["M", x1, y1], ["C", x1 + BEZIER_DISTANCE, y1, x2 - BEZIER_DISTANCE, y2, x2, y2]]
    paper.path(path).attr({"stroke": color, "stroke-width": width})

  rect = (x1, y1, width, height, color, caption) ->

    rectangleSet = paper.set()
    rectangleSet.push(paper.rect(x1, y1, width, height).attr({"fill": color, "stroke": color}))
    rectangleSet.push(paper.text(x1 + width / 2, y1 + height / 2, caption).attr({"font-family": "Titillium Web", "font-size": 15, "fill": "#ffffff"}))
    rectangleSet

  hoverStart = ->

    _(partyData.links).forEach( (link) =>

      if this.type == "path"
        if this isnt link.curve
          link.curve.attr("opacity", 0.1)
      else
        if link.source != this.index and link.target != this.index
          link.curve.attr("opacity", 0.1)
      )

  hoverEnd = ->

    _(partyData.links).forEach( (link) ->

      link.curve.attr("opacity", 1)
    )

  # calculate number of voters for all parties
  overallSum = 0
  for i in [0...partyData.nodes.length]

    overallSum += partyData.nodes[i]["sum"] = _.reduce(partyData.links, ((sum, link) ->
      if (link.source == i and i < 9) or (link.target == i and i >= 9)
        return sum + +link.value
      else
        return sum
    ), 0)

  overallSum /= 2

  # draw rectangle for each party with the height of the rectangle corresponding to number of voters
  currentX = currentY = 0
  for i in [0...partyData.nodes.length]

    # percentual height for every party with margin of RECT_MARGIN px below parties
    height = partyData.nodes[i].sum / overallSum * (HEIGHT - NUM_PARTIES * RECT_MARGIN)
    rectangleSet = rect(currentX, currentY, RECT_WIDTH, height, partyData.nodes[i].color, partyData.nodes[i].name)
    rectangleSet.hover(hoverStart, hoverEnd)
    rectangleSet[0].index = rectangleSet[1].index = i
    partyData.nodes[i].rect = rectangleSet[0]

    currentY += RECT_MARGIN + height

    if i == NUM_PARTIES - 1

      currentX = WIDTH - RECT_WIDTH
      currentY = 0

  # draw migration lines, thickness corresponds to number of migrating voters
  for link in partyData.links

    height = link.value / overallSum * (HEIGHT - NUM_PARTIES * RECT_MARGIN)

    currentStartY = partyData.nodes[link.source].currentY or 0
    currentEndY = partyData.nodes[link.target].currentY or 0

    startY = partyData.nodes[link.source].rect.attr("y") + currentStartY + height / 2
    endY = partyData.nodes[link.target].rect.attr("y") + currentEndY + height / 2

    link.curve = curve(RECT_WIDTH, startY, WIDTH - RECT_WIDTH, endY, height, partyData.nodes[link.source].color)
    link.curve.hover(hoverStart, hoverEnd)

    partyData.nodes[link.source].currentY = currentStartY + height
    partyData.nodes[link.target].currentY = currentEndY + height

)