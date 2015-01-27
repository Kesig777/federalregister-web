class PublicInspectionDocumentsController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: :navigation

  def index
    cache_for 1.day

    render
  end

  def current
    cache_for 1.day
    @documents = []

    render template: 'public_inspection/index'
  end

  def public_inspection
    redirect_to current_public_inspection_documents_path, status: :moved_permanently
  end

  def navigation
    #cache_for 1.day
    @presenter = PublicInspectionIssuePresenter.new
  end
end
