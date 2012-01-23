class ClippingsController < ApplicationController
  protect_from_forgery :except => [:create, :bulk_create]
  skip_before_filter :authenticate_user!, :only => [:index, :create]

  def index
    if user_signed_in? && current_user.clippings.present?
      @clippings = current_user.clippings.with_preloaded_articles
      @document_numbers = current_user.clippings.for_javascript
    elsif !user_signed_in? && cookies[:document_numbers].present?
      @clippings = Clipping.all_preloaded_from_cookie( JSON.parse(cookies[:document_numbers]) )
      @document_numbers = JSON.parse(cookies[:document_numbers])
    else
      @clippings = []
    end
  end

  def create
    if user_signed_in?
      # create a clipping unless one already exists for this document
      Clipping.persist_document(params[:entry][:document_number], current_user)
    else
      # stash the document id in the session if the user isn't logged in
      add_document_id_to_session( params[:entry][:document_number] )
    end

    if request.xhr?
      render :text => cookies[:document_numbers].to_json.html_safe
    else
      redirect_to clippings_url
    end
    
  end

  def bulk_create
    document_numbers = params[:document_numbers]

    if document_numbers.present?
      clipping_details = []
      document_numbers.each do |document_number|
        unless Clipping.find_by_document_number_and_user_id(document_number, current_user.id)
          clipping = Clipping.new(:document_number => document_number,
                                  :user_id => current_user.id)
          clipping.save
          
          clipping_details << { :doc_type   => clipping.article.type,
                                :title      => clipping.article.title,
                                :url        => clipping.article.html_url,
                                :pub_date   => clipping.article.publication_date.to_formatted_s(:date),
                                :created_at => clipping.created_at.to_formatted_s(:date) }
        end
      end
    end

    render :json => {:clippings => clipping_details}
  end

  private

  def add_document_id_to_session(document_number)
    if cookies[:document_numbers].present?
      cookies[:document_numbers] = JSON.parse(cookies[:document_numbers]).merge!( {document_number => [0]} ).to_json
    else
      cookies[:document_numbers] = {document_number => [0]}.to_json
    end
  end
end
