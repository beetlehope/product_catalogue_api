shared_examples 'proper status code' do |code|
  it 'returns proper status code' do
    call
    expect(response).to have_http_status(code)
  end
end
