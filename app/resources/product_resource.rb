class ProductResource < JSONAPI::Resource
  attributes :name, :price, :category
end
