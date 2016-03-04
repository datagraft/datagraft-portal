class Widget < Thing

  has_many :data_pages_widgets
  has_many :data_pages, :through => :data_pages_widgets, 
end