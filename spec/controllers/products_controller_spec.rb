require 'rails_helper'

RSpec.describe ProductsController do
  describe 'GET #index', type: :request do
    subject(:call) { get endpoint }

    let(:endpoint) { '/products' }

    context 'without any products' do
      it_behaves_like 'proper status code', 200

      it 'contains empty data array in the response body' do
        call
        expect(json_response_body).to eq('data' => [])
      end
    end

    context 'with existing products' do
      let!(:first) { create :product, name: 'MacbookPro', price: '2000', category: 'laptops' }
      let!(:second) { create :product, name: 'iPhone', price: '1000', category: 'smartphones' }

      let(:json_serialized_products) do
        [
          {
            'id' => first.id.to_s,
            'type' => 'products',
            'links' => {
              'self' => "http://www.example.com/products/#{first.id}"
            },
            'attributes' => {
              'name' => 'MacbookPro',
              'price' => 2000,
              'category' => 'laptops'
            }
          },
          {
            'id' => second.id.to_s,
            'type' => 'products',
            'links' => {
              'self' => "http://www.example.com/products/#{second.id}"
            },
            'attributes' => {
              'name' => 'iPhone',
              'price' => 1000,
              'category' => 'smartphones'
            }
          }
        ]
      end

      it_behaves_like 'proper status code', 200

      it 'contains all the products in the body data' do
        call
        expect(json_response_body['data']).to match_array(json_serialized_products)
      end
    end
  end

  describe 'GET #show', type: :request do
    subject(:call) { get endpoint }

    let(:endpoint) { "/products/#{id}" }

    context "when the product doesn't exist" do
      let(:id) { 100 }

      it_behaves_like 'proper status code', 404
    end

    context 'when the product exists' do
      let(:first) { create :product, name: 'MacbookPro', price: '2000', category: 'laptops' }
      let(:id) { first.id }
      let(:json_serialized_product) do
        {
          'id' => first.id.to_s,
          'type' => 'products',
          'links' => {
            'self' => "http://www.example.com/products/#{first.id}"
          },
          'attributes' => {
            'name' => 'MacbookPro',
            'price' => 2000,
            'category' => 'laptops'
          }
        }
      end

      it 'contains the serialized product in the body data' do
        call
        expect(json_response_body['data']).to eq(json_serialized_product)
      end
    end
  end

  describe 'DELETE #destroy', type: :request do
    subject(:call) { get endpoint }

    let(:endpoint) { "/products/#{id}" }

    context "when the product doesn't exist" do
      let(:id) { 100 }

      it_behaves_like 'proper status code', 404
    end

    context 'when the product exists' do
      let(:laptop) { create :product, name: 'MacbookPro', price: '2000', category: 'laptops' }
      let(:id) { laptop.id }

      it_behaves_like 'proper status code', 200
    end
  end

  describe 'PATCH #update', type: :request do
    subject(:call) { patch endpoint, params: params, as: :json, headers: headers }

    let(:endpoint) { "/products/#{id}" }
    let(:headers) { { 'Accept' => JSONAPI::MEDIA_TYPE, 'Content-Type' => JSONAPI::MEDIA_TYPE } }
    let(:params) do
      { data: {
        type: 'products',
        id: laptop.id,
        attributes: {
          name: 'MacbookPro',
          price: 2500,
          category: 'laptops'
        }
      } }
    end
    let(:laptop) { create :product, name: 'MacbookPro', price: '2000', category: 'laptops' }
    let(:id) { laptop.id }

    it_behaves_like 'proper status code', 200
    it { expect { call }.to change { laptop.reload.price }.from(2000).to(2500) }
  end

  describe 'PUT #create', type: :request do
    subject(:call) { post endpoint, params: params, as: :json, headers: headers }
    let(:endpoint) { '/products' }
    let(:params) do
      { data: {
        type: 'products',
        attributes: {
          name: 'laptop',
          price: 100,
          category: 'computers'
        }
      } }
    end
    let(:headers) { { 'Accept' => JSONAPI::MEDIA_TYPE, 'Content-Type' => JSONAPI::MEDIA_TYPE } }

    it_behaves_like 'proper status code', 201
    it { expect { call }.to change { Product.count }.from(0).to(1) }
  end
end
