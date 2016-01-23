require 'rails_helper'

describe Song do

  # validations
  it { should validate_presence_of(:album) }

end
