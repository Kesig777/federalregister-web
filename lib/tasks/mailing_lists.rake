namespace :mailing_lists do
  namespace :documents do
    desc "Enqueue the document mailing lists for a given day"
    task :deliver, [:date] => :environment do |t, args|
      date = Date.parse(args[:date])
      DocumentSubscriptionQueuePopulator.perfom(date)
    end

    desc "renames MailingList::Article to MailingList::Document"
    task :rename_article_to_document => :environment do
      MailingList.connection.execute("UPDATE mailing_lists
        SET mailing_lists.type = 'MailingList::Document'
        WHERE mailing_lists.type = 'MailingList::Article'")
    end
  end

  namespace :public_inspection do
    desc "Enqueue the PI mailing lists for the specified documents"
    task :deliver, [:date, :document_numbers] => :environment do |t, args|
      date = args[:date]
      document_numbers = args[:document_numbers].split(',')
      PublicInspectionDocumentSubscriptionQueuePopulator.perform(date, document_numbers)
    end
  end

  desc "recalculate active subscriptions for this environment"
  task :recalculate_counts => :environment do
    MailingList.connection.execute("UPDATE mailing_lists SET active_subscriptions_count = 0")
    MailingList.connection.execute("UPDATE mailing_lists,
          (
           SELECT mailing_list_id, COUNT(subscriptions.id) AS count
           FROM subscriptions
           WHERE subscriptions.environment = '#{Rails.env}'
             AND subscriptions.confirmed_at IS NOT NULL
             AND subscriptions.unsubscribed_at IS NULL
             AND subscriptions.deleted_at IS NULL
           GROUP BY subscriptions.mailing_list_id
          ) AS subscription_counts
       SET mailing_lists.active_subscriptions_count = subscription_counts.count
       WHERE mailing_lists.id = subscription_counts.mailing_list_id AND mailing_lists.deleted_at IS NULL")
  end

  desc "flattens parameters to remove :conditions key, removes invalid searches"
  task :clean_parameters => :environment do
    cleaner = MailingListCleaner.new

    MailingList::Document.find_in_batches(batch_size: 1000) do |mailing_lists|
      mailing_lists.each do |mailing_list|
        mailing_list.parameters = cleaner.clean_parameters(mailing_list.parameters)

        if cleaner.valid_search?(mailing_list.parameters, Search::Document)
          mailing_list.save
        else
          deleted_at = Time.now
          mailing_list.deleted_at = deleted_at
          mailing_list.subscriptions.each{|s| s.updated_attributes(deleted_at: deleted_at)}
          mailing_list.save
        end
      end
    end

    MailingList::PublicInspectionDocument.find_in_batches(batch_size: 1000) do |mailing_lists|
      mailing_lists.each do |mailing_list|
        mailing_list.parameters = cleaner.clean_parameters(mailing_list.parameters)

        if cleaner.valid_search?(mailing_list.parameters, Search::PublicInspection)
          mailing_list.save
        else
          deleted_at = Time.now
          mailing_list.deleted_at = deleted_at
          mailing_list.subscriptions.each{|s| s.update_attributes(deleted_at: deleted_at)}
          mailing_list.save
        end
      end
    end
  end

  desc "collapses mailing lists with the same parameters and updates their subscriptions"
  task :collapse_duplicates => :environment do
    cleaner = MailingListCleaner.new

    cleaner.collapse_duplicates('MailingList::Document')
    cleaner.collapse_duplicates('MailingList::PublicInspectionDocument')
  end

  class MailingListCleaner
    require "#{Rails.root}/app/helpers/conditions_helper"
    include ConditionsHelper

    def clean_parameters(parameters)
      parameters = extract_conditions(parameters)
      parameters = clean_conditions(parameters)
      parameters
    end

    def valid_search?(parameters, klass)
      klass.new(conditions: parameters).valid_search?
    end

    def extract_conditions(parameters)
      if parameters
        if parameters.present?
          if parameters["conditions"]
            # convert nil values to empty parameters
            parameters["conditions"].nil? ? {} : parameters["conditions"]
          else
            parameters
          end
        else
          {} # ensure no nil or "" parameters
        end
      else
        {} # ensure no nil parameters
      end
    end

    def collapse_duplicates(type)
      # select all the duplicates and then update their subscriptions to point
      # to the oldest mailing list of the group
      # NOTE: there are some subscriptions that appear to be dups but have
      #       special characters in them this won't collapse them
      MailingList.connection.execute("
        SELECT COUNT(*) as count, id
        FROM mailing_lists
        WHERE type = '#{type}' and deleted_at IS NULL
        GROUP BY parameters
        HAVING count > 1
        ORDER BY id
      ").each do |count, id|
        mailing_list = MailingList.find(id)

        binding.pry
        duplicates = MailingList.
          where(parameters: mailing_list.parameters.to_json).
          where(type: type).
          where(MailingList.arel_table[:id].not_eq(mailing_list.id))

        duplicates.each do |ml|
          Subscription.
            where(mailing_list_id: ml.id).
            update_all(mailing_list_id: mailing_list.id)

          ml.update_attributes({
            deleted_at: Time.now,
            active_subscriptions_count: 0
          })
        end
      end
    end
  end
end
