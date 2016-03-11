class Widget < Thing

  has_many :data_pages_widgets
  has_many :data_pages, :through => :data_pages_widgets

  @@allowed_widget_classes = %w(web map chart)
  cattr_accessor :allowed_widget_classes

  validates :widget_class, presence: true, inclusion: {in: @@allowed_widget_classes}
  validates :url, url: {allow_blank: true}

  default_scope do 
    order created_at: :asc, id: :asc
  end

  def url
    metadata["url"] if metadata
  end

  def url=(val)
    touch_metadata!
    metadata["url"] = val
  end

  def widget_class 
    metadata["widget_class"] if metadata
  end

  def widget_class=(val)
    touch_metadata!
    metadata["widget_class"] = val
  end

end