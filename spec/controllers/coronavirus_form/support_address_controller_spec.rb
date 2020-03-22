# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::SupportAddressController, type: :controller do
  let(:current_template) { "coronavirus_form/support_address" }
  let(:session_key) { :support_address }
  let(:next_page) { coronavirus_form_contact_details_path }

  describe "GET show" do
    it "renders the form" do
      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    let(:params) do
      {
        "building_and_street_line_1" => "<script></script>Ministry of Magic",
        "building_and_street_line_2" => "1 Horse Guards Road<script></script>",
        "town_city" => "<script></script>London",
        "county" => "United Kingdom",
        "postcode" => "SW1A 2HQ",
      }
    end
    let(:address) do
      {
        "building_and_street_line_1" => "Ministry of Magic",
        "building_and_street_line_2" => "1 Horse Guards Road",
        "town_city" => "London",
        "county" => "United Kingdom",
        "postcode" => "SW1A 2HQ",
      }
    end

    it "sets session variables" do
      post :submit, params: params

      expect(session[session_key]).to eq address
    end

    # [1st line, Town, postcode] OR [1st line, Town, County]
    it "does not require address line 2" do
      post :submit, params: params.except("building_and_street_line_2")

      expect(session[session_key]).to eq address.merge("building_and_street_line_2" => nil)
      expect(response).to redirect_to(next_page)
    end

    it "redirects to next page when provided address line 1, town and postcode" do
      post :submit, params: params.except("building_and_street_line_2", "county")

      expect(session[session_key]).to eq address.merge({
        "building_and_street_line_2" => nil,
        "county" => nil,
        })

      expect(response).to redirect_to(next_page)
    end

    it "redirects to next page when provided address line 1, town and county" do
      post :submit, params: params.except("building_and_street_line_2", "postcode")

      expect(session[session_key]).to eq address.merge({
        "building_and_street_line_2" => nil,
        "postcode" => nil,
        })

      expect(response).to redirect_to(next_page)
    end

    it "redirects to next step when all fields are provided" do
      post :submit, params: params

      expect(response).to redirect_to(next_page)
    end

    described_class::REQUIRED_FIELDS.each do |field|
      it "requires that key #{field} be provided" do
        post :submit, params: params.except(field)

        expect(response).to render_template(current_template)
      end
    end
  end
end
