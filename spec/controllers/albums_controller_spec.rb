require 'spec_helper'

describe AlbumsController do
  context "PATCH #update" do
    let!(:album) { create(:album) }

    it "can update an album" do
      patch :update, { id: album.id }
      expect(response).to redirect_to(root_path)
    end
  end
end
