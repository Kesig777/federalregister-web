class SectionsController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: :navigation


  def show
    begin
    @presenter = SectionPagePresenter.new(params[:section], Date.current)

    rescue SectionPagePresenter::InvalidSection
      raise ActiveRecord::RecordNotFound
    end
  end

  # def old_show_action
  #   @presenter = SectionPresenter.new(params[:section])
  #   @section = @presenter.section

  #   respond_to do |wants|
  #     wants.html
  #     wants.rss do
  #       base_url = 'https://www.federalregister.gov/articles/search.rss?'
  #       options = "conditions[sections]=#{@section.id}&order=newest.com"
  #       redirect_to base_url + options, status: :moved_permanently
  #     end
  #   end
  # end
  
  def significant_entries
    cache_for 1.day
    @presenter = SectionPresenter.new(params[:section])
    @section = @presenter.section

    respond_to do |wants|
      wants.rss do
        base_url = 'https://www.federalregister.gov/articles/search.rss?'
        options = "conditions[sections]=#{@section.id}&order=newest.com&conditions[significant]=1"
        redirect_to base_url + options, status: :moved_permanently
      end
    end
  end

  def navigation
    cache_for 1.day

    @sections = SectionPresenter::SECTIONS
  end
end
