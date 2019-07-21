class ProductResource < JSONAPI::Resource
  attributes :name, :price, :category

  filter :name
end
