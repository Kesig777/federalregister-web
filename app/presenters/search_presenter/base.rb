class SearchPresenter::Base
  attr_accessor :params
  def initialize(params)
    @params = params.symbolize_keys.except(:controller, :action)
  end

  def supported_orders
    %w(Relevant Newest Oldest)
  end

  def agencies
    @agencies ||= FederalRegister::Agency.all
  end

  def agency_ids
    agencies.map(&:id)
  end
end
