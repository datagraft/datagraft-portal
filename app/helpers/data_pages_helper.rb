module DataPagesHelper
  def data_pages_path(user = current_user)
    "/#{user.username}/data_pages" if user
  end

  def new_data_page_path
    "/#{current_user.username}/data_pages/new" if user_signed_in?
  end


  def show_the_fucking_layout(layout, ratioGrid = 1, unitHeight = 50, gridClasses = '', cellClasses = '', &block)
    return if layout.nil?

    layout = layout.each_with_index do |box,index|
      box["index"] = index
    end

    # Sort layout by column
    layout = layout.sort_by do |box|
      box["col"]
    end

    # Group by row and sort theim by key
    groupedBoxes = layout.group_by do |box|
      box["row"]
    end
    groupedBoxes = groupedBoxes.sort.to_h

    # Get maximum row height
    maxRow = layout.max_by do |box|
      box["row"] + box["size_y"]
    end

    maxRowHeight = (maxRow["row"] + maxRow["size_y"] - 1)*unitHeight

    content_tag :div, style: "min-height:#{maxRowHeight}px" do
      groupedBoxes.each do |row, boxes|
        concat(fuck_you_row(boxes, ratioGrid, unitHeight, gridClasses, cellClasses, block))
      end
    end

  end

  private

  def fuck_you_row(boxes, ratioGrid, unitHeight, gridClasses, cellClasses, block)
    maxBox = boxes.max_by do |box|
      box["size_y"]
    end

    maxRowHeight = maxBox["size_y"] * unitHeight

    content_tag(:div, class: "mdl-grid #{gridClasses} sin-fucking-layout-row--#{maxRowHeight}") do
      [nil, *boxes].each_cons(2) do |immediateLeftBox,box|
        offset = 0

        if immediateLeftBox
          offset = box["col"] - immediateLeftBox["col"] - immediateLeftBox["size_x"]
        else
          offset = box["col"] - 1
        end

        concat(fuck_you_cell(box, offset, ratioGrid, unitHeight, cellClasses, block))
      end
    end
  end

  def fuck_you_cell(box, offset, ratioGrid, unitHeight, cellClasses, block)
    width = box["size_x"]
    height = box["size_y"]

    className = "mdl-cell mdl-cell--#{width*ratioGrid}-col-desktop"
    className += " " + cellClasses unless cellClasses.empty?
    className += " mdl-cell--#{offset*ratioGrid}-offset-desktop" if offset > 0

    style = "min-height:" + (height * unitHeight).to_s + "px"

    content_tag(:div, class: className, style: style) do
      block.call(box)
    end
  end
end