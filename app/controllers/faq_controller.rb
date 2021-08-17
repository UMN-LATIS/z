class FaqController < ApplicationController
  def index
    @faqs = FrequentlyAskedQuestion.all
  end
end
