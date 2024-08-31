require "controllers/api/v1/test"

class Api::V1::SaloonsControllerTest < Api::Test
  def setup
    # See `test/controllers/api/test.rb` for common set up for API tests.
    super

    @saloon = build(:saloon, team: @team)
    @other_saloons = create_list(:saloon, 3)

    @another_saloon = create(:saloon, team: @team)

    # 🚅 super scaffolding will insert file-related logic above this line.
    @saloon.save
    @another_saloon.save

    @original_hide_things = ENV["HIDE_THINGS"]
    ENV["HIDE_THINGS"] = "false"
    Rails.application.reload_routes!
  end

  def teardown
    super
    ENV["HIDE_THINGS"] = @original_hide_things
    Rails.application.reload_routes!
  end

  # This assertion is written in such a way that new attributes won't cause the tests to start failing, but removing
  # data we were previously providing to users _will_ break the test suite.
  def assert_proper_object_serialization(saloon_data)
    # Fetch the saloon in question and prepare to compare it's attributes.
    saloon = Saloon.find(saloon_data["id"])

    assert_equal_or_nil saloon_data['name'], saloon.name
    # 🚅 super scaffolding will insert new fields above this line.

    assert_equal saloon_data["team_id"], saloon.team_id
  end

  test "index" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/teams/#{@team.id}/saloons", params: {access_token: access_token}
    assert_response :success

    # Make sure it's returning our resources.
    saloon_ids_returned = response.parsed_body.map { |saloon| saloon["id"] }
    assert_includes(saloon_ids_returned, @saloon.id)

    # But not returning other people's resources.
    assert_not_includes(saloon_ids_returned, @other_saloons[0].id)

    # And that the object structure is correct.
    assert_proper_object_serialization response.parsed_body.first
  end

  test "show" do
    # Fetch and ensure nothing is seriously broken.
    get "/api/v1/saloons/#{@saloon.id}", params: {access_token: access_token}
    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    get "/api/v1/saloons/#{@saloon.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "create" do
    # Use the serializer to generate a payload, but strip some attributes out.
    params = {access_token: access_token}
    saloon_data = JSON.parse(build(:saloon, team: nil).api_attributes.to_json)
    saloon_data.except!("id", "team_id", "created_at", "updated_at")
    params[:saloon] = saloon_data

    post "/api/v1/teams/#{@team.id}/saloons", params: params
    assert_response :success

    # # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # Also ensure we can't do that same action as another user.
    post "/api/v1/teams/#{@team.id}/saloons",
      params: params.merge({access_token: another_access_token})
    assert_response :not_found
  end

  test "update" do
    # Post an attribute update ensure nothing is seriously broken.
    put "/api/v1/saloons/#{@saloon.id}", params: {
      access_token: access_token,
      saloon: {
        name: 'Alternative String Value',
        # 🚅 super scaffolding will also insert new fields above this line.
      }
    }

    assert_response :success

    # Ensure all the required data is returned properly.
    assert_proper_object_serialization response.parsed_body

    # But we have to manually assert the value was properly updated.
    @saloon.reload
    assert_equal @saloon.name, 'Alternative String Value'
    # 🚅 super scaffolding will additionally insert new fields above this line.

    # Also ensure we can't do that same action as another user.
    put "/api/v1/saloons/#{@saloon.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end

  test "destroy" do
    # Delete and ensure it actually went away.
    assert_difference("Saloon.count", -1) do
      delete "/api/v1/saloons/#{@saloon.id}", params: {access_token: access_token}
      assert_response :success
    end

    # Also ensure we can't do that same action as another user.
    delete "/api/v1/saloons/#{@another_saloon.id}", params: {access_token: another_access_token}
    assert_response :not_found
  end
end
