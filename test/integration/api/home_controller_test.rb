require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
    test 'Whe auth token is valid' do
        user = users(:one)
        api_token = user.api_tokens.create!
        get api_v1_home_index_path, headers: {HTTP_AUTHORIZATION: "Token token=#{api_token.token}"}
        assert_response :success
    end

    test 'Whe auth token is inactive' do
        user = users(:one)
        api_token = user.api_tokens.create!
        api_token.update!(active: false)
        get api_v1_home_index_path, headers: {HTTP_AUTHORIZATION: "Token token=#{api_token.token}"}
        assert_response :unauthorized
    end



end