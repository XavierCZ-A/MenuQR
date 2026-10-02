# frozen_string_literal: true

module Navbar
  class Component < ViewComponent::Base
    attr_reader :user

    def initialize(user:)
      super()

      @user = user
    end
  end
end
