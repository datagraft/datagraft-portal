#
# Convert a Gridster.js layout JSON serialization to a Material Design Lite grid.
#
# Author: Antoine
# Based on gridster-bootstrap.js and ported to Ruby
# https://github.com/ncthis/gridster-bootstrap
#
# License Apache 2

  class Superlayout
    def initialize(layout, ratioGrid = 1, unitHeight = 50, gridClasses = '', boxClasses = '')

      # Sort layout by column
      @layout = layout.sort_by do |box|
        box["col"]
      end

      @ratioGrid = ratioGrid
      @unitHeight = unitHeight
      @gridClasses = gridClasses
      @boxClasses = boxClasses
    end

    def open_box(width, height, offset)

      className = "mdl-cell mdl-cell--#{width*@ratioGrid}-col"
      className += " " + @boxClasses unless @boxClasses.empty?
      className += " mdl-cell--#{offset*@ratioGrid}-offset" if offset > 0

      style = "min-height:" + (height * @unitHeight).to_s + "px"

      "<div class=\"#{className}\" style=\"#{style}\">"
    end

    def close_box
      "</div>"
    end

    def open_row
      "<div class=\"mdl-grid #{@gridClasses}\" style=\"height:#{@unitHeight}px\">"
    end

    def close_row
      "</div>"
    end

    def generate()
      groupedBoxes = @layout.group_by do |box|
        box["row"]
      end

      # sort by key
      groupedBoxes = groupedBoxes.sort.to_h

      maxRow = @layout.max_by do |box|
        box["row"]
      end

      html = ""

      groupedBoxes.each do |row, boxes|
        html += open_row

        [nil, *boxes].each_cons(2) do |immediateLeftBox,box|
          offset = 0

          if immediateLeftBox
            offset = box["col"] - immediateLeftBox["col"] - immediateLeftBox["size_x"]
          else
            offset = box["col"] - 1
          end

          html += open_box(box["size_x"], box["size_y"], offset)
          html += capture(&block)
          html += close_box
        end

        html += close_row
      end

      return html
    end
  end
